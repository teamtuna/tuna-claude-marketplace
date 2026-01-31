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
| **review-pr** | PR 변경사항 코드 리뷰 | `/review:pr [branch] [--full] [--comment]` | git diff 기반, Critical/Warning/Suggestion 분류 |
| **review-compose** | Jetpack Compose 성능 검사 | `/review:compose [file\|dir] [--strict]` | Recomposition 최적화, State 관리, Side Effect |
| **review-architecture** | 클린 아키텍처 검증 | `/review:architecture [module] [--deps] [--layers]` | 의존성 방향, 레이어 분리, 패키지 구조 |
| **review-security** | 보안 취약점 검사 | `/review:security [dir] [--strict] [--secrets]` | 하드코딩 키, 민감정보 로깅, 암호화 누락 |
| **review-test** | 테스트 커버리지 검사 | `/review:test [module] [--coverage] [--run] [--missing]` | 테스트 누락, 실행, 커버리지 리포트 |

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
/review:pr main

# 2. Compose 최적화 검사 (엄격 모드)
/review:compose --strict

# 3. 보안 취약점 체크
/review:security --secrets

# 4. 테스트 커버리지 확인
/review:test --coverage

# 5. 아키텍처 검증
/review:architecture --deps
```

#### 특정 영역 집중 검사
```bash
# Compose 파일만 집중 검사
/review:compose feature/home/ui/

# 결제 모듈 보안 검사
/review:security feature/payment/

# 특정 모듈 테스트 실행
/review:test feature/home --run
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
/review:pr

# 보안 체크
/review:security

# 테스트 확인
/review:test --missing
```

### 시나리오 2: 릴리즈 전
```bash
# 전체 보안 검사
/review:security --strict

# 테스트 커버리지 확인
/review:test --coverage

# 아키텍처 검증
/review:architecture
```

### 시나리오 3: Compose 리팩토링 후
```bash
# Compose 성능 검사
/review:compose --strict

# UI 테스트 확인
/review:test --run
```

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
