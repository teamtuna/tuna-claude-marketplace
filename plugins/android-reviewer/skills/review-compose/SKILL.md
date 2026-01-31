---
name: review-compose
description: Jetpack Compose 성능 및 패턴 검사. Recomposition 최적화, State 관리, Side Effect 사용법 분석.
allowed-tools: Bash, Read, Grep, Glob
argument-hint: "[file|directory] [--strict]"
user-invocable: true
---

# Compose Review Skill

Jetpack Compose 코드의 성능 이슈와 안티패턴을 검사하는 skill입니다.

## When to Use

- Compose UI 코드 작성 후 성능 검증
- XML → Compose 마이그레이션 후 검토
- Recomposition 이슈 디버깅
- Compose 코드 리뷰 시

## Core Principles

1. **Recomposition 최소화**: 불필요한 리컴포지션 방지
2. **State 올바른 사용**: remember, derivedStateOf 적절히 사용
3. **Side Effect 관리**: LaunchedEffect, DisposableEffect 올바른 사용
4. **성능 우선**: 리스트, 이미지, 애니메이션 최적화

## Process

### 1. Compose 파일 수집

```bash
# 모든 Compose 파일 찾기 (@Composable 포함)
grep -rl "@Composable" --include="*.kt" .

# 특정 디렉토리
grep -rl "@Composable" --include="*.kt" ./feature/home/

# Screen/Component 파일만
find . -name "*Screen.kt" -o -name "*Component.kt"
```

### 2. 안티패턴 검사

```bash
# remember 없이 객체 생성
grep -n "= object\|= listOf\|= mapOf\|= mutableListOf" *.kt | grep -v "remember"

# collectAsState (Lifecycle 미고려)
grep -n "collectAsState()" --include="*.kt" -r .

# unstable 람다 (인라인 람다)
grep -n "onClick = {" --include="*.kt" -r .

# key 없는 LazyColumn items
grep -n "items(" --include="*.kt" -r . | grep -v "key ="
```

### 3. 체크리스트

## 🔴 Critical Issues

### 1. Unstable Lambda in Composable
```kotlin
// ❌ Bad - 매번 새 람다 생성 → 리컴포지션 유발
@Composable
fun MyScreen(viewModel: MyViewModel) {
    Button(onClick = { viewModel.doSomething() })  // 매번 새 인스턴스
}

// ✅ Good - 메서드 레퍼런스
Button(onClick = viewModel::doSomething)

// ✅ Good - remember로 캐싱
val onClick = remember { { viewModel.doSomething() } }
Button(onClick = onClick)

// ✅ Good - 파라미터 있을 때
val onClick = remember(id) { { viewModel.doSomething(id) } }
```

### 2. collectAsState without Lifecycle
```kotlin
// ❌ Bad - 백그라운드에서도 수집
val state by viewModel.state.collectAsState()

// ✅ Good - Lifecycle aware
val state by viewModel.state.collectAsStateWithLifecycle()
```

### 3. Object Creation without remember
```kotlin
// ❌ Bad - 매번 새 객체 생성
@Composable
fun MyComposable() {
    val list = listOf(1, 2, 3)  // 리컴포지션마다 생성
    val formatter = SimpleDateFormat("yyyy-MM-dd")
}

// ✅ Good
@Composable
fun MyComposable() {
    val list = remember { listOf(1, 2, 3) }
    val formatter = remember { SimpleDateFormat("yyyy-MM-dd") }
}
```

## 🟡 Warning Issues

### 4. LazyColumn without key
```kotlin
// ❌ Bad - 아이템 변경 시 전체 리컴포지션
LazyColumn {
    items(users) { user ->
        UserCard(user)
    }
}

// ✅ Good - 고유 key로 최적화
LazyColumn {
    items(users, key = { it.id }) { user ->
        UserCard(user)
    }
}
```

### 5. Derived State 미사용
```kotlin
// ❌ Bad - 매 리컴포지션마다 필터링
@Composable
fun UserList(users: List<User>, query: String) {
    val filtered = users.filter { it.name.contains(query) }
}

// ✅ Good - 값 변경 시에만 계산
@Composable
fun UserList(users: List<User>, query: String) {
    val filtered by remember(users, query) {
        derivedStateOf { users.filter { it.name.contains(query) } }
    }
}
```

### 6. Modifier 순서 오류
```kotlin
// ❌ Bad - padding 밖에서 clickable (터치 영역 작음)
Modifier
    .padding(16.dp)
    .clickable { }

// ✅ Good - clickable 후 padding (터치 영역 넓음)
Modifier
    .clickable { }
    .padding(16.dp)
```

### 7. LaunchedEffect key 오류
```kotlin
// ❌ Bad - 매번 실행됨
LaunchedEffect(Unit) {
    viewModel.loadData(userId)  // userId 변경 시 재실행 안됨
}

// ✅ Good - userId 변경 시 재실행
LaunchedEffect(userId) {
    viewModel.loadData(userId)
}
```

## 🟢 Suggestions

### 8. Preview 함수 누락
```kotlin
// ✅ Preview 추가 권장
@Preview(showBackground = true)
@Composable
private fun MyComponentPreview() {
    MyTheme {
        MyComponent(
            title = "Preview Title",
            onClick = {}
        )
    }
}
```

### 9. State Hoisting
```kotlin
// ❌ Bad - 내부 상태 관리
@Composable
fun SearchBar() {
    var query by remember { mutableStateOf("") }
    TextField(value = query, onValueChange = { query = it })
}

// ✅ Good - 상태 호이스팅
@Composable
fun SearchBar(
    query: String,
    onQueryChange: (String) -> Unit
) {
    TextField(value = query, onValueChange = onQueryChange)
}
```

### 10. Immutable 파라미터
```kotlin
// ❌ Bad - List는 unstable
@Composable
fun UserList(users: List<User>)

// ✅ Good - ImmutableList 사용
@Composable
fun UserList(users: ImmutableList<User>)

// 또는 @Stable/@Immutable 어노테이션
@Immutable
data class User(val id: String, val name: String)
```

## Command Usage

```bash
# 현재 디렉토리 검사
/review:compose

# 특정 파일 검사
/review:compose HomeScreen.kt

# 특정 디렉토리 검사
/review:compose ./feature/feed/ui/

# 엄격 모드 (모든 Warning 포함)
/review:compose --strict
```

## Output Format

```markdown
## 🎨 Compose Review: [파일/디렉토리]

### 📊 검사 결과
- Composable 함수: N개
- 🔴 Critical: N개
- 🟡 Warning: N개
- 🟢 Suggestion: N개

### 🔴 Critical Issues
**[파일:라인]** Unstable lambda in onClick
...

### 🟡 Warnings
...

### 🟢 Suggestions
...

### ✅ Good Practices Found
- remember 적절히 사용됨
- State hoisting 패턴 준수
...
```

## Notes

- Compose Compiler 메트릭스와 함께 사용 권장
- Layout Inspector로 실제 리컴포지션 확인
- 성능 이슈는 프로파일링으로 검증
- kotlinx-collections-immutable 도입 고려
