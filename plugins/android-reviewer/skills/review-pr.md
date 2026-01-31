---
name: review-pr
description: PR 변경사항 코드 리뷰. git diff 기반으로 변경된 코드를 분석하고 리뷰 코멘트 생성.
allowed-tools: Bash, Read, Grep, Glob, Write
argument-hint: "[branch] [--full] [--comment]"
---

# PR Review Skill

Git diff 기반으로 PR 변경사항을 분석하고 코드 리뷰를 수행하는 skill입니다.

## When to Use

- PR 생성 전 셀프 리뷰가 필요할 때
- 머지 전 최종 점검이 필요할 때
- 다른 사람의 PR을 리뷰할 때
- 변경사항이 많아 놓친 부분이 없는지 확인할 때

## Core Principles

1. **변경사항 중심**: 전체 파일이 아닌 변경된 부분만 집중 리뷰
2. **우선순위 구분**: Critical > Warning > Suggestion 순으로 분류
3. **구체적 피드백**: 문제점과 함께 수정 코드 제안
4. **컨텍스트 고려**: 변경 의도를 파악하고 리뷰

## Process

### 1. 변경사항 수집

```bash
# 현재 브랜치와 main 비교
git diff main...HEAD --name-only

# 변경된 Kotlin 파일만
git diff main...HEAD --name-only | grep "\.kt$"

# 상세 diff 확인
git diff main...HEAD -- "*.kt"

# 특정 브랜치와 비교
git diff feature/target...HEAD
```

### 2. 변경 통계 확인

```bash
# 파일별 변경 라인 수
git diff main...HEAD --stat

# 추가/삭제 라인 수
git diff main...HEAD --shortstat

# 변경된 함수/클래스 목록
git diff main...HEAD --name-only | xargs grep -l "fun \|class "
```

### 3. 리뷰 체크리스트

#### 🔴 Critical (반드시 수정)
- [ ] NPE 가능성 (`!!` 사용, nullable 미처리)
- [ ] 메모리 누수 (Context 참조, Coroutine scope)
- [ ] 스레드 안전성 (Main thread 블로킹)
- [ ] 보안 이슈 (하드코딩된 키, 민감정보 로깅)

#### 🟡 Warning (권장 수정)
- [ ] 성능 이슈 (N+1, 불필요한 객체 생성)
- [ ] Compose recomposition 문제
- [ ] 에러 핸들링 누락
- [ ] 테스트 누락

#### 🟢 Suggestion (선택 수정)
- [ ] 네이밍 개선
- [ ] 코드 중복 제거
- [ ] 더 나은 Kotlin 관용구
- [ ] 문서화 추가

### 4. 리뷰 결과 출력

```markdown
## 📋 PR Review: [브랜치명]

### 변경 요약
- 📁 변경 파일: N개
- ➕ 추가: N줄 / ➖ 삭제: N줄
- 🎯 주요 변경: [요약]

### 🔴 Critical (N개)
**[파일:라인]** 이슈 설명
\`\`\`kotlin
// 수정 제안
\`\`\`

### 🟡 Warning (N개)
...

### 🟢 Suggestion (N개)
...

### ✅ 잘된 점
...
```

## Command Usage

```bash
# 기본 리뷰 (main 브랜치 대비)
/review:pr

# 특정 브랜치 대비 리뷰
/review:pr develop

# 전체 파일 컨텍스트 포함 리뷰
/review:pr --full

# 리뷰 결과를 파일로 저장
/review:pr --comment
```

## Review Focus Areas

### Kotlin/Android 특화 체크
| 항목 | 체크 포인트 |
|------|------------|
| Null Safety | `!!` 사용, `?.let` vs `if null` |
| Coroutines | Dispatcher, scope, 취소 처리 |
| Lifecycle | lifecycleScope, viewModelScope 사용 |
| Memory | Context 참조, 리스너 해제 |

### Compose 특화 체크
| 항목 | 체크 포인트 |
|------|------------|
| State | remember, derivedStateOf 사용 |
| Recomposition | 불필요한 리컴포지션 |
| Side Effects | LaunchedEffect, DisposableEffect |
| Performance | key 설정, 람다 캐싱 |

## Output Examples

### Critical 예시
```
🔴 **[UserViewModel.kt:45]** NPE 가능성

현재 코드:
val name = user!!.name

제안:
val name = user?.name ?: return
// 또는
val name = user?.name.orEmpty()
```

### Warning 예시
```
🟡 **[HomeScreen.kt:120]** Recomposition 최적화 필요

현재 코드:
items(list) { item -> ItemCard(item) }

제안:
items(list, key = { it.id }) { item -> ItemCard(item) }
```

## Workflow Integration

### PR 생성 전 워크플로우
```bash
# 1. 셀프 리뷰
/review:pr

# 2. 린트 검사
/lint

# 3. 테스트 실행
./gradlew test

# 4. PR 생성
gh pr create
```

### CI 연동
```bash
# GitHub Actions에서 자동 리뷰 코멘트
/review:pr --comment > pr-review.md
gh pr comment --body-file pr-review.md
```

## Notes

- 변경사항이 500줄 이상이면 `--full` 옵션 권장
- 리뷰 결과는 참고용이며, 최종 판단은 사람이
- 컨텍스트 부족 시 관련 파일도 함께 확인
- 팀 컨벤션에 맞게 체크리스트 커스터마이징 권장
