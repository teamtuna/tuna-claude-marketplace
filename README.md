# 🐟 Tuna Claude Marketplace

Team Tuna의 Claude Code 플러그인 모음입니다.

## 설치 방법

Claude Code 터미널에서:

```bash
/plugin marketplace add teamtuna/tuna-claude-marketplace
```

## 플러그인 목록

### 🤖 android-reviewer
Android/Kotlin 코드 리뷰 전문 Agent & Skills

**포함된 Agent:**
- `android-code-reviewer`: Android 코드베이스 전문 리뷰 에이전트

**포함된 Skills (5개):**

| 스킬 | 설명 | 명령어 | 주요 기능 |
|-----|------|--------|----------|
| **review-pr** | PR 변경사항 코드 리뷰 | `/review-pr [branch] [--full] [--comment]` | git diff 기반, Critical/Warning/Suggestion 분류 |
| **review-compose** | Jetpack Compose 성능 검사 | `/review-compose [file\|dir] [--strict]` | Recomposition 최적화, State 관리, Side Effect |
| **review-architecture** | 클린 아키텍처 검증 | `/review-architecture [module] [--deps] [--layers]` | 의존성 방향, 레이어 분리, 패키지 구조 |
| **review-security** | 보안 취약점 검사 | `/review-security [dir] [--strict] [--secrets]` | 하드코딩 키, 민감정보 로깅, 암호화 누락 |
| **review-test** | 테스트 커버리지 검사 | `/review-test [module] [--coverage] [--run] [--missing]` | 테스트 누락, 실행, 커버리지 리포트 |

## 빠른 시작

### 1. Marketplace 추가
```bash
/plugin marketplace add teamtuna/tuna-claude-marketplace
```

### 2. Plugin 설치
```bash
/plugin install android-reviewer@tuna-marketplace
```

### 3. Agent 사용
```bash
/agent android-code-reviewer
# 또는 대화 중에 @android-code-reviewer 멘션
```

### 4. Skills 사용 예시

#### PR 리뷰 워크플로우
```bash
# 1. PR 변경사항 리뷰
/review-pr main

# 2. Compose 최적화 검사 (엄격 모드)
/review-compose --strict

# 3. 보안 취약점 체크
/review-security --secrets

# 4. 테스트 커버리지 확인
/review-test --coverage

# 5. 아키텍처 검증
/review-architecture --deps
```

#### 특정 영역 집중 검사
```bash
# Compose 파일만 집중 검사
/review-compose feature/home/ui/

# 결제 모듈 보안 검사
/review-security feature/payment/

# 특정 모듈 테스트 실행
/review-test feature/home --run
```

## 주요 특징

### 🎯 3단계 이슈 분류
- 🔴 **Critical**: 반드시 수정 (NPE, 보안 취약점, 메모리 누수)
- 🟡 **Warning**: 권장 수정 (성능 이슈, 테스트 누락)
- 🟢 **Suggestion**: 선택 수정 (네이밍, 코드 스타일)

### 🔧 다양한 옵션 지원
- `--full`: 전체 컨텍스트 포함 분석
- `--strict`: 엄격 모드 (모든 Warning 포함)
- `--coverage`: 커버리지 리포트 생성
- `--comment`: 리뷰 결과를 파일로 저장 (CI 연동)

### 📋 체크리스트 기반
각 스킬은 실무에서 검증된 체크리스트를 기반으로 일관된 리뷰를 제공합니다.

## 사용 시나리오

### 시나리오 1: PR 생성 전
```bash
# 셀프 리뷰
/review-pr

# 보안 체크
/review-security

# 테스트 확인
/review-test --missing
```

### 시나리오 2: 릴리즈 전
```bash
# 전체 보안 검사
/review-security --strict

# 테스트 커버리지 확인
/review-test --coverage

# 아키텍처 검증
/review-architecture
```

### 시나리오 3: Compose 리팩토링 후
```bash
# Compose 성능 검사
/review-compose --strict

# UI 테스트 확인
/review-test --run
```

## 버전 히스토리

### android-reviewer

| 버전 | 날짜 | 변경사항 |
|------|------|----------|
| **v1.2.1** | 2026-01-31 | 🔧 **Skill 구조 개선**<br>• 단일 파일 → 디렉토리 구조로 변경 (확장성 확보)<br>• 모든 skill 파일명을 SKILL.md로 통일<br>• 향후 예제/템플릿/스크립트 추가 가능 |
| v1.2.0 | 2026-01-31 | 🛠️ **버전 관리 자동화**<br>• bump-version.sh 스크립트 추가<br>• 자동 changelog 생성<br>• manifest 검증 오류 수정 |
| v1.1.0 | 2026-01-31 | 🎉 **5개 리뷰 스킬 추가**<br>• review-pr: PR 변경사항 코드 리뷰<br>• review-compose: Jetpack Compose 성능 검사<br>• review-architecture: 클린 아키텍처 검증<br>• review-security: 보안 취약점 검사<br>• review-test: 테스트 커버리지 검사<br>• 3단계 이슈 분류 (Critical/Warning/Suggestion)<br>• 다양한 옵션 지원 (--full, --strict, --coverage 등)<br>• CI/CD 통합 가이드 포함 |
| v1.0.0 | 2026-01-31 | 🚀 **초기 릴리즈**<br>• android-code-reviewer agent 추가<br>• Android/Kotlin 코드베이스 전문 리뷰 에이전트 |

---

## 개발자 가이드

### 버전 관리

플러그인 버전을 업데이트할 때는 자동화 스크립트를 사용합니다:

```bash
./scripts/bump-version.sh <plugin-name> <version-type> <changelog-message>
```

**예시:**

```bash
# Patch (버그 수정): 1.0.0 → 1.0.1
./scripts/bump-version.sh android-reviewer patch "Fix manifest validation error"

# Minor (기능 추가): 1.0.0 → 1.1.0
./scripts/bump-version.sh android-reviewer minor "Add review-performance skill"

# Major (Breaking Change): 1.0.0 → 2.0.0
./scripts/bump-version.sh android-reviewer major "Refactor skills API"
```

**자동으로 업데이트되는 항목:**
1. `plugins/{plugin}/.claude-plugin/plugin.json` - 플러그인 버전
2. `.claude-plugin/marketplace.json` - marketplace 및 플러그인 버전
3. `plugins/{plugin}/README.md` - Changelog에 새 버전 항목 추가

**Semantic Versioning 규칙:**
- **MAJOR**: 호환성이 깨지는 변경 (API 변경, 필수 파라미터 변경)
- **MINOR**: 하위 호환되는 기능 추가 (새 스킬, 새 옵션)
- **PATCH**: 하위 호환되는 버그 수정

상세 가이드: [scripts/README.md](scripts/README.md)

---

## 기여하기

PR 환영합니다! 🎉

### 새로운 스킬 추가하기
1. `plugins/android-reviewer/skills/` 에 `skill-name.md` 생성
2. frontmatter에 `name`, `description`, `allowed-tools` 명시
3. PR 생성

## 라이선스

MIT

---

**Made with ❤️ by Team Tuna**
