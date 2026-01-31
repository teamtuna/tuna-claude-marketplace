# 🤖 Android Reviewer

Android/Kotlin 프로젝트를 위한 전문 코드 리뷰 Agent & Skills 모음

## 📦 포함 내용

### Agent
- **android-code-reviewer**: Android 코드베이스 전반을 이해하고 리뷰하는 전문 에이전트

### Skills (5개)

#### 1. review-pr
**용도:** PR 변경사항 코드 리뷰. git diff 기반으로 변경된 코드를 분석하고 리뷰 코멘트 생성.

**명령어:**
```bash
/review:pr [branch] [--full] [--comment]
```

**옵션:**
- `[branch]`: 비교할 브랜치 (기본값: main)
- `--full`: 전체 파일 컨텍스트 포함 리뷰
- `--comment`: 리뷰 결과를 파일로 저장 (CI 연동용)

**체크 항목:**
- 🔴 Critical: NPE 가능성, 메모리 누수, 스레드 안전성, 보안 이슈
- 🟡 Warning: 성능 이슈, Compose recomposition, 에러 핸들링, 테스트 누락
- 🟢 Suggestion: 네이밍 개선, 코드 중복 제거, Kotlin 관용구

**허용 도구:** Bash, Read, Grep, Glob, Write

---

#### 2. review-compose
**용도:** Jetpack Compose 성능 및 패턴 검사. Recomposition 최적화, State 관리, Side Effect 사용법 분석.

**명령어:**
```bash
/review:compose [file|directory] [--strict]
```

**옵션:**
- `[file|directory]`: 검사할 파일 또는 디렉토리
- `--strict`: 엄격 모드 (모든 Warning 포함)

**체크 항목:**
- 🔴 Critical: Unstable Lambda, collectAsState without Lifecycle, remember 미사용
- 🟡 Warning: LazyColumn key 누락, Derived State 미사용, Modifier 순서, LaunchedEffect key 오류
- 🟢 Suggestion: Preview 누락, State Hoisting, Immutable 파라미터

**허용 도구:** Bash, Read, Grep, Glob

**안티패턴 10가지:**
1. Unstable Lambda in Composable
2. collectAsState without Lifecycle
3. Object Creation without remember
4. LazyColumn without key
5. Derived State 미사용
6. Modifier 순서 오류
7. LaunchedEffect key 오류
8. Preview 함수 누락
9. State Hoisting 미적용
10. Immutable 파라미터 미사용

---

#### 3. review-architecture
**용도:** 클린 아키텍처 및 모듈 구조 검증. 의존성 방향, 레이어 분리, 패키지 구조 검사.

**명령어:**
```bash
/review:architecture [module] [--deps] [--layers]
```

**옵션:**
- `[module]`: 검사할 모듈 경로
- `--deps`: 의존성만 검사
- `--layers`: 레이어 구조만 검사

**체크 항목:**
- 🔴 Critical: 의존성 역전 위반, Domain에 Android 의존성, Presentation에서 Data 직접 접근
- 🟡 Warning: UseCase 미사용, Entity/DTO 미분리, Repository 인터페이스 위치 오류
- 🟢 Suggestion: 모듈 분리 권장, DI 모듈 분리

**허용 도구:** Bash, Read, Grep, Glob

**아키텍처 레이어:**
```
Presentation (UI, ViewModel, Compose)
     ↓
Domain (UseCase, Entity, Repository Interface)
     ↑
Data (Repository Impl, DataSource, API)
```

---

#### 4. review-security
**용도:** Android 보안 취약점 검사. 하드코딩된 키, 민감정보 로깅, 암호화 누락, 인증 우회 등 검출.

**명령어:**
```bash
/review:security [file|directory] [--strict] [--secrets]
```

**옵션:**
- `[file|directory]`: 검사할 파일 또는 디렉토리
- `--strict`: 엄격 모드 (모든 Warning 포함)
- `--secrets`: 시크릿 검사만 수행

**체크 항목:**
- 🔴 Critical: 하드코딩된 시크릿, 민감정보 로깅, 인증서 검증 우회, 평문 HTTP 통신
- 🟡 Warning: SharedPreferences 평문 저장, 입력값 미검증, WebView 보안, 디버그 정보 노출
- 🟢 Suggestion: ProGuard/R8 난독화, Root/Emulator 감지

**허용 도구:** Bash, Read, Grep, Glob

**Pre-Release 체크리스트:**
- [ ] 하드코딩된 시크릿 없음
- [ ] 프로덕션 로그에 민감정보 없음
- [ ] HTTPS만 사용
- [ ] 인증서 검증 활성화
- [ ] EncryptedSharedPreferences 사용
- [ ] ProGuard/R8 활성화
- [ ] debuggable=false (릴리즈)
- [ ] 입력값 검증 완료

---

#### 5. review-test
**용도:** 테스트 커버리지 및 품질 검사. 변경된 코드의 테스트 존재 여부, 테스트 실행, 커버리지 리포트 생성.

**명령어:**
```bash
/review:test [module] [--coverage] [--run] [--missing]
```

**옵션:**
- `[module]`: 검사할 모듈
- `--coverage`: 커버리지 리포트 생성
- `--run`: 테스트 실행
- `--missing`: 누락된 테스트만 확인

**체크 항목:**
- 🔴 Critical: 비즈니스 로직(UseCase) 테스트 필수, ViewModel 테스트 필수, Repository 테스트 필수
- 🟡 Warning: Edge Case 누락, 테스트 이름 불명확, Assertion 부족
- 🟢 Suggestion: Parameterized Test 활용, Test Fixture 분리, Compose UI 테스트

**허용 도구:** Bash, Read, Grep, Glob, Write

**커버리지 목표:**
- 전체: 최소 70%
- UseCase/ViewModel: 80% 권장

---

## 🚀 사용 예시

### 시나리오 1: PR 생성 전 워크플로우
```bash
# 1. 셀프 리뷰
/review:pr

# 2. 테스트 누락 확인
/review:test --missing

# 3. 보안 체크
/review:security --secrets

# 4. 전체 테스트 실행
/review:test --run
```

### 시나리오 2: Compose UI 개발 후
```bash
# 1. Compose 최적화 검사
/review:compose feature/home/ui/ --strict

# 2. UI 테스트 확인
/review:test feature/home --run

# 3. 변경사항 리뷰
/review:pr develop
```

### 시나리오 3: 아키텍처 리팩토링 후
```bash
# 1. 레이어 분리 검증
/review:architecture --layers

# 2. 의존성 방향 확인
/review:architecture --deps

# 3. 전체 아키텍처 검증
/review:architecture
```

### 시나리오 4: 릴리즈 전 최종 점검
```bash
# 1. 보안 취약점 전체 검사
/review:security --strict

# 2. 테스트 커버리지 확인
/review:test --coverage

# 3. PR 최종 리뷰
/review:pr main --full

# 4. Agent 종합 분석
@android-code-reviewer 릴리즈 전 최종 점검해줘. 위험 요소와 개선 방안을 우선순위별로 정리해줘.
```

### 시나리오 5: CI/CD 파이프라인 통합
```bash
# GitHub Actions 예시
- name: Code Review
  run: |
    /review:pr --comment > pr-review.md
    gh pr comment --body-file pr-review.md

- name: Security Check
  run: |
    /review:security --strict
    if [ $? -ne 0 ]; then exit 1; fi

- name: Test Coverage
  run: |
    /review:test --coverage
    /review:test --run
```

---

## 🎯 Best Practice

### Agent vs Skills 언제 사용할까?

**Agent (`@android-code-reviewer`) 사용:**
- 복잡한 코드 리뷰 요청
- 여러 파일/모듈을 종합적으로 분석
- 자유로운 대화 형식으로 피드백 필요
- 컨텍스트 이해가 중요한 경우

**Skills 사용:**
- 특정 체크리스트 기반 빠른 검사
- CI/CD 파이프라인 통합
- 일관된 형식의 리포트 필요
- 자동화된 검증 프로세스

### 조합 사용 예시
```bash
# 1. Skills로 자동화된 검사
/review:pr main
/review:compose --strict
/review:security
/review:test --coverage

# 2. Agent로 종합 분석
@android-code-reviewer 위 리뷰 결과를 종합해서:
1. 심각도별 이슈 정리
2. 우선순위별 개선 방안 제시
3. 리팩토링 방향 제안
```

---

## 📋 체크리스트 요약

| 카테고리 | 주요 체크 항목 | 담당 Skill | 우선순위 |
|---------|--------------|-----------|---------|
| **PR 리뷰** | NPE, 메모리 누수, 코드 품질 | review-pr | 🔴 High |
| **Compose** | Recomposition, State, Side Effect | review-compose | 🟡 Medium |
| **아키텍처** | 레이어 분리, 의존성 방향 | review-architecture | 🟡 Medium |
| **보안** | 하드코딩 키, 로깅, 암호화 | review-security | 🔴 High |
| **테스트** | 단위 테스트, 커버리지 | review-test | 🟡 Medium |

---

## 🔧 설치

```bash
# 1. Marketplace 추가
/plugin marketplace add teamtuna/tuna-claude-marketplace

# 2. Plugin 설치
/plugin install android-reviewer@tuna-marketplace

# 3. 설치 확인
/plugin list
```

---

## 📚 참고 자료

### 공식 문서
- [Jetpack Compose Best Practices](https://developer.android.com/jetpack/compose/performance)
- [Clean Architecture (Android)](https://developer.android.com/topic/architecture)
- [OWASP Mobile Top 10](https://owasp.org/www-project-mobile-top-10/)
- [Android Testing Guide](https://developer.android.com/training/testing)

### 권장 도구
- Compose Compiler Metrics: 리컴포지션 분석
- Layout Inspector: UI 성능 디버깅
- Jacoco: 테스트 커버리지
- Detekt/ktlint: 정적 분석

---

## 🤝 기여하기

새로운 체크리스트나 개선 사항이 있다면 PR을 보내주세요!

### 개발 가이드
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/new-skill`)
3. Add your skill in `skills/` directory
4. Update this README
5. Commit your changes (`git commit -m 'Add new skill'`)
6. Push to the branch (`git push origin feature/new-skill`)
7. Create a Pull Request

---

## 📝 License

MIT License

Copyright (c) 2026 Team Tuna

---

## 📞 Support

문제가 발생하거나 제안사항이 있다면:
- GitHub Issues: [tuna-claude-marketplace/issues](https://github.com/teamtuna/tuna-claude-marketplace/issues)
- Discussions: [tuna-claude-marketplace/discussions](https://github.com/teamtuna/tuna-claude-marketplace/discussions)

---

**Made with ❤️ by Team Tuna**
