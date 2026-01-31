# Scripts

이 디렉토리는 Tuna Marketplace 관리를 위한 자동화 스크립트를 포함합니다.

## bump-version.sh

플러그인 버전을 업데이트하고 changelog를 자동으로 관리하는 스크립트입니다.

### 사용법

```bash
./scripts/bump-version.sh <plugin-name> <version-type> <changelog-message>
```

### 파라미터

- `<plugin-name>`: 플러그인 이름 (예: `android-reviewer`)
- `<version-type>`: 버전 타입
  - `major`: 주요 버전 업데이트 (1.0.0 → 2.0.0) - Breaking Changes
  - `minor`: 기능 추가 (1.0.0 → 1.1.0) - New Features
  - `patch`: 버그 수정 (1.0.0 → 1.0.1) - Bug Fixes
- `<changelog-message>`: 변경 사항 설명

### 예시

#### Patch (버그 수정)
```bash
./scripts/bump-version.sh android-reviewer patch "Fix manifest validation error"
```

결과:
- `1.0.0` → `1.0.1`
- README에 "#### Fixed" 섹션 추가

#### Minor (기능 추가)
```bash
./scripts/bump-version.sh android-reviewer minor "Add review-performance skill for performance analysis"
```

결과:
- `1.0.0` → `1.1.0`
- README에 "#### Added" 섹션 추가

#### Major (Breaking Changes)
```bash
./scripts/bump-version.sh android-reviewer major "Refactor all skills API to use new format"
```

결과:
- `1.0.0` → `2.0.0`
- README에 "#### Breaking Changes" 섹션 추가

### 자동으로 업데이트되는 파일

1. **plugins/{plugin-name}/.claude-plugin/plugin.json**
   - `version` 필드 업데이트

2. **/.claude-plugin/marketplace.json**
   - `plugins[].version` 업데이트 (해당 플러그인)
   - `metadata.version` 업데이트 (minor/major 변경 시)

3. **plugins/{plugin-name}/README.md**
   - Changelog 섹션에 새 버전 항목 자동 추가
   - 날짜 자동 기입 (YYYY-MM-DD)

### 워크플로우

#### 1. 코드 변경 후 버전 업데이트

```bash
# 1. 작업 완료 후 스크립트 실행
./scripts/bump-version.sh android-reviewer patch "Fix NPE in review-pr skill"

# 2. 변경 사항 확인
git diff

# 3. 커밋 & 푸시
git add .
git commit -m "chore: Bump version to 1.0.1"
git push
```

#### 2. 여러 개의 변경 사항 (상세한 changelog)

```bash
./scripts/bump-version.sh android-reviewer minor "Add review-performance skill with JVM profiler integration and memory leak detection"
```

이후 README를 직접 수정하여 bullet point를 추가할 수 있습니다:

```markdown
### [1.1.0] - 2026-01-31

#### Added
- Add review-performance skill with JVM profiler integration and memory leak detection
  - JVM heap dump 분석
  - ANR (Application Not Responding) 탐지
  - 메모리 누수 패턴 검사
  - CPU 프로파일링
```

### Semantic Versioning 규칙

이 프로젝트는 [Semantic Versioning 2.0.0](https://semver.org/)을 따릅니다.

**MAJOR.MINOR.PATCH**

- **MAJOR**: 호환성이 깨지는 API 변경
  - 스킬 명령어 형식 변경
  - 필수 파라미터 추가/제거
  - Agent behavior의 근본적 변경

- **MINOR**: 하위 호환되는 기능 추가
  - 새로운 스킬 추가
  - 새로운 옵션/플래그 추가
  - 기존 기능 개선

- **PATCH**: 하위 호환되는 버그 수정
  - 버그 수정
  - 문서 오타 수정
  - 성능 개선
  - 의존성 업데이트

### 트러블슈팅

#### 스크립트 실행 권한 오류
```bash
chmod +x scripts/bump-version.sh
```

#### Changelog 섹션을 찾을 수 없음
README.md에 다음 섹션이 있는지 확인:
```markdown
## 📋 변경 이력 (Changelog)
```

#### 파일을 찾을 수 없음
프로젝트 루트 디렉토리에서 스크립트를 실행했는지 확인:
```bash
cd /path/to/tuna-claude-marketplace
./scripts/bump-version.sh android-reviewer patch "Fix bug"
```

### 백업

스크립트는 자동으로 `.bak` 백업 파일을 생성하고, 성공 시 삭제합니다.
오류 발생 시 백업에서 복원됩니다.

### Git Hook 설정 (선택 사항)

버전 업데이트를 잊지 않도록 pre-commit hook을 설정할 수 있습니다:

```bash
# .git/hooks/pre-commit
#!/bin/bash

# 변경된 파일에 plugin.json이 있으면 경고
if git diff --cached --name-only | grep -q "plugin.json"; then
    echo "⚠️  Warning: plugin.json이 변경되었습니다."
    echo "   버전을 업데이트하셨나요?"
    echo "   ./scripts/bump-version.sh 사용을 권장합니다."
    echo ""
    read -p "계속하시겠습니까? (y/N): " confirm
    if [ "$confirm" != "y" ]; then
        exit 1
    fi
fi
```

---

**Made with ❤️ by Team Tuna**
