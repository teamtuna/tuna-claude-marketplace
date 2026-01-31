#!/bin/bash

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 사용법 출력
usage() {
    echo -e "${YELLOW}사용법:${NC}"
    echo "  ./scripts/bump-version.sh <plugin-name> <version-type> <changelog-message>"
    echo ""
    echo "예시:"
    echo "  ./scripts/bump-version.sh android-reviewer patch 'Fix manifest validation error'"
    echo "  ./scripts/bump-version.sh android-reviewer minor 'Add new review-performance skill'"
    echo "  ./scripts/bump-version.sh android-reviewer major 'Breaking change: Refactor all skills API'"
    echo ""
    echo "version-type: major | minor | patch"
    exit 1
}

# 인자 검증
if [ $# -lt 3 ]; then
    usage
fi

PLUGIN_NAME=$1
VERSION_TYPE=$2
CHANGELOG_MESSAGE="${@:3}"

# 파일 경로
PLUGIN_JSON="plugins/${PLUGIN_NAME}/.claude-plugin/plugin.json"
MARKETPLACE_JSON=".claude-plugin/marketplace.json"
README="plugins/${PLUGIN_NAME}/README.md"

# 파일 존재 확인
if [ ! -f "$PLUGIN_JSON" ]; then
    echo -e "${RED}❌ Error: $PLUGIN_JSON not found${NC}"
    exit 1
fi

if [ ! -f "$MARKETPLACE_JSON" ]; then
    echo -e "${RED}❌ Error: $MARKETPLACE_JSON not found${NC}"
    exit 1
fi

if [ ! -f "$README" ]; then
    echo -e "${RED}❌ Error: $README not found${NC}"
    exit 1
fi

# 현재 버전 추출
CURRENT_VERSION=$(grep -o '"version": "[^"]*"' "$PLUGIN_JSON" | head -1 | cut -d'"' -f4)
echo -e "${GREEN}📦 Current version: $CURRENT_VERSION${NC}"

# 버전 분리
IFS='.' read -r -a VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR="${VERSION_PARTS[0]}"
MINOR="${VERSION_PARTS[1]}"
PATCH="${VERSION_PARTS[2]}"

# 새 버전 계산
case $VERSION_TYPE in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    *)
        echo -e "${RED}❌ Invalid version type: $VERSION_TYPE${NC}"
        usage
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
echo -e "${GREEN}🚀 New version: $NEW_VERSION${NC}"

# 날짜 (YYYY-MM-DD)
DATE=$(date +%Y-%m-%d)

# 백업 생성
echo -e "${YELLOW}📋 Creating backups...${NC}"
cp "$PLUGIN_JSON" "$PLUGIN_JSON.bak"
cp "$MARKETPLACE_JSON" "$MARKETPLACE_JSON.bak"
cp "$README" "$README.bak"

# 1. plugin.json 업데이트
echo -e "${YELLOW}📝 Updating $PLUGIN_JSON...${NC}"
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/" "$PLUGIN_JSON"
else
    # Linux
    sed -i "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/" "$PLUGIN_JSON"
fi

# 2. marketplace.json 업데이트
echo -e "${YELLOW}📝 Updating $MARKETPLACE_JSON...${NC}"
# marketplace metadata 버전 업데이트 (minor/major만)
if [ "$VERSION_TYPE" != "patch" ]; then
    MARKETPLACE_VERSION="$MAJOR.$MINOR.0"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/\"version\": \"[0-9]*\.[0-9]*\.[0-9]*\"/\"version\": \"$MARKETPLACE_VERSION\"/" "$MARKETPLACE_JSON" | head -1
    else
        sed -i "0,/\"version\": \"[0-9]*\.[0-9]*\.[0-9]*\"/s//\"version\": \"$MARKETPLACE_VERSION\"/" "$MARKETPLACE_JSON"
    fi
fi

# plugin 버전 업데이트
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/g" "$MARKETPLACE_JSON"
else
    sed -i "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/g" "$MARKETPLACE_JSON"
fi

# 3. README 업데이트 (Changelog에 새 버전 추가)
echo -e "${YELLOW}📝 Updating $README...${NC}"

# Changelog 섹션 찾기
CHANGELOG_LINE=$(grep -n "## 📋 변경 이력 (Changelog)" "$README" | cut -d: -f1)

if [ -z "$CHANGELOG_LINE" ]; then
    echo -e "${RED}❌ Error: Changelog section not found in README${NC}"
    # 백업 복원
    mv "$PLUGIN_JSON.bak" "$PLUGIN_JSON"
    mv "$MARKETPLACE_JSON.bak" "$MARKETPLACE_JSON"
    mv "$README.bak" "$README"
    exit 1
fi

# 첫 번째 버전 섹션 찾기 (예: ### [1.1.0])
FIRST_VERSION_LINE=$(grep -n "^### \[" "$README" | head -1 | cut -d: -f1)

# 버전 타입에 따른 섹션 제목
case $VERSION_TYPE in
    major)
        SECTION_TITLE="#### Breaking Changes"
        ;;
    minor)
        SECTION_TITLE="#### Added"
        ;;
    patch)
        SECTION_TITLE="#### Fixed"
        ;;
esac

# 새 changelog 항목 생성
NEW_CHANGELOG="### [$NEW_VERSION] - $DATE

$SECTION_TITLE
- $CHANGELOG_MESSAGE

"

# README에 삽입 (첫 번째 버전 섹션 바로 앞에)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    INSERT_LINE=$((FIRST_VERSION_LINE))
    {
        head -n $((INSERT_LINE - 1)) "$README"
        echo "$NEW_CHANGELOG"
        tail -n +$INSERT_LINE "$README"
    } > "$README.tmp"
    mv "$README.tmp" "$README"
else
    # Linux
    INSERT_LINE=$((FIRST_VERSION_LINE))
    sed -i "${INSERT_LINE}i\\${NEW_CHANGELOG}" "$README"
fi

# 백업 삭제
rm "$PLUGIN_JSON.bak" "$MARKETPLACE_JSON.bak" "$README.bak"

echo ""
echo -e "${GREEN}✅ Version bump complete!${NC}"
echo -e "${GREEN}   $CURRENT_VERSION → $NEW_VERSION${NC}"
echo ""
echo -e "${YELLOW}📋 Updated files:${NC}"
echo "   - $PLUGIN_JSON"
echo "   - $MARKETPLACE_JSON"
echo "   - $README"
echo ""
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "   1. Review the changes"
echo "   2. git add ."
echo "   3. git commit -m \"chore: Bump version to $NEW_VERSION\""
echo "   4. git push"
echo ""
