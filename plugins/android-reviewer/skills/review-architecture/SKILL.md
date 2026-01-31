---
name: review-architecture
description: 클린 아키텍처 및 모듈 구조 검증. 의존성 방향, 레이어 분리, 패키지 구조 검사.
allowed-tools: Bash, Read, Grep, Glob
argument-hint: "[module] [--deps] [--layers]"
---

# Architecture Review Skill

클린 아키텍처 원칙과 모듈 구조를 검증하는 skill입니다.

## When to Use

- 새 모듈/기능 설계 후 구조 검증
- 아키텍처 리뷰 미팅 전 사전 점검
- 레이어 간 의존성 위반 확인
- 모듈 분리 적절성 검토

## Core Principles

1. **의존성 규칙**: 안쪽 레이어는 바깥 레이어를 몰라야 함
2. **단방향 의존성**: Domain ← Data, UI → Domain
3. **관심사 분리**: 각 레이어는 명확한 책임
4. **테스트 가능성**: 의존성 주입을 통한 테스트 용이성

## Architecture Layers

```
┌─────────────────────────────────────────┐
│              Presentation               │
│   (UI, ViewModel, Compose, Activity)    │
├─────────────────────────────────────────┤
│                Domain                   │
│   (UseCase, Entity, Repository Interface)│
├─────────────────────────────────────────┤
│                 Data                    │
│   (Repository Impl, DataSource, API)    │
└─────────────────────────────────────────┘

의존성 방향: Presentation → Domain ← Data
```

## Process

### 1. 모듈 구조 확인

```bash
# 모듈 목록 확인
find . -name "build.gradle.kts" -type f | xargs dirname | sort

# 모듈별 패키지 구조
find ./feature -type d -name "domain" -o -name "data" -o -name "presentation"

# 레이어 구조 확인
tree -d -L 3 ./feature/
```

### 2. 의존성 검사

```bash
# build.gradle.kts에서 모듈 의존성 확인
grep -r "implementation(project" --include="build.gradle.kts"

# Domain 모듈의 의존성 (Data, Presentation 의존 금지)
grep -r "implementation(project" ./feature/*/domain/build.gradle.kts

# 순환 의존성 검사
./gradlew :feature:home:dependencies --configuration implementation
```

### 3. Import 검사

```bash
# Domain에서 Android import 검사 (금지)
grep -r "import android\." --include="*.kt" ./feature/*/domain/

# Domain에서 Data 레이어 import 검사 (금지)
grep -r "import.*\.data\." --include="*.kt" ./feature/*/domain/

# Presentation에서 Data 직접 접근 검사 (Domain 통해야 함)
grep -r "import.*\.data\." --include="*.kt" ./feature/*/presentation/
```

## Checklist

### 🔴 Critical Violations

#### 1. 의존성 역전 위반
```kotlin
// ❌ Domain이 Data를 직접 의존
// domain/usecase/GetUserUseCase.kt
import com.app.feature.user.data.UserRepositoryImpl  // 위반!

class GetUserUseCase(
    private val repository: UserRepositoryImpl  // 구현체 직접 참조
)

// ✅ Domain은 인터페이스만 의존
// domain/usecase/GetUserUseCase.kt
import com.app.feature.user.domain.repository.UserRepository

class GetUserUseCase(
    private val repository: UserRepository  // 인터페이스 참조
)
```

#### 2. Domain에 Android 의존성
```kotlin
// ❌ Domain에 Android import
// domain/model/User.kt
import android.os.Parcelable  // 위반!

@Parcelize
data class User(val id: String) : Parcelable

// ✅ Domain은 순수 Kotlin
// domain/model/User.kt
data class User(val id: String)

// presentation/model/UserUiModel.kt (필요시 여기서 Parcelable)
@Parcelize
data class UserUiModel(val id: String) : Parcelable
```

#### 3. Presentation에서 Data 직접 접근
```kotlin
// ❌ ViewModel에서 DataSource 직접 사용
class UserViewModel(
    private val api: UserApi  // 위반! Data 레이어 직접 접근
)

// ✅ UseCase를 통해 접근
class UserViewModel(
    private val getUserUseCase: GetUserUseCase
)
```

### 🟡 Warnings

#### 4. UseCase 미사용
```kotlin
// ❌ ViewModel에서 Repository 직접 사용
class UserViewModel(
    private val userRepository: UserRepository
) {
    fun loadUser() {
        userRepository.getUser()  // 비즈니스 로직이 ViewModel에
    }
}

// ✅ UseCase로 비즈니스 로직 분리
class UserViewModel(
    private val getUserUseCase: GetUserUseCase
) {
    fun loadUser() {
        getUserUseCase()
    }
}
```

#### 5. Entity와 DTO 미분리
```kotlin
// ❌ API 응답을 Domain까지 전파
// data/api/UserResponse.kt
data class UserResponse(
    @SerializedName("user_id") val userId: String
)

// domain/model/User.kt - 같은 클래스 사용하면 안됨

// ✅ 레이어별 모델 분리
// data/api/UserResponse.kt (DTO)
data class UserResponse(@SerializedName("user_id") val userId: String)

// domain/model/User.kt (Entity)
data class User(val id: String)

// data/mapper/UserMapper.kt
fun UserResponse.toDomain() = User(id = userId)
```

#### 6. Repository 인터페이스 위치 오류
```kotlin
// ❌ Repository 인터페이스가 Data에 위치
// data/repository/UserRepository.kt
interface UserRepository

// ✅ Repository 인터페이스는 Domain에
// domain/repository/UserRepository.kt
interface UserRepository

// data/repository/UserRepositoryImpl.kt
class UserRepositoryImpl : UserRepository
```

### 🟢 Suggestions

#### 7. 모듈 분리 권장
```
# 현재 (모놀리식)
feature/
  └── user/
      ├── data/
      ├── domain/
      └── presentation/

# 권장 (멀티모듈)
feature/
  ├── user-domain/     # 순수 Kotlin
  ├── user-data/       # Android, Network
  └── user-presentation/  # Compose, ViewModel
```

#### 8. DI 모듈 분리
```kotlin
// ✅ 레이어별 DI 모듈 분리
@Module
object UserDomainModule {
    @Provides
    fun provideGetUserUseCase(repo: UserRepository) = GetUserUseCase(repo)
}

@Module
object UserDataModule {
    @Provides
    fun provideUserRepository(api: UserApi): UserRepository = UserRepositoryImpl(api)
}
```

## Command Usage

```bash
# 전체 아키텍처 검사
/review:architecture

# 특정 모듈 검사
/review:architecture feature/home

# 의존성만 검사
/review:architecture --deps

# 레이어 구조만 검사
/review:architecture --layers
```

## Output Format

```markdown
## 🏗️ Architecture Review: [모듈명]

### 📊 모듈 구조
- Domain: ✅ 존재
- Data: ✅ 존재
- Presentation: ✅ 존재

### 의존성 그래프
presentation → domain ← data ✅

### 🔴 Critical Violations (N개)
**[파일:라인]** Domain에서 Android 의존성 발견
...

### 🟡 Warnings (N개)
...

### 🟢 Suggestions (N개)
...

### ✅ Good Practices
- Repository 인터페이스가 Domain에 위치
- UseCase 패턴 적용됨
...
```

## Recommended Module Dependencies

```kotlin
// domain/build.gradle.kts
dependencies {
    // 순수 Kotlin만
    implementation(libs.kotlinx.coroutines.core)
    // Android 의존성 없음!
}

// data/build.gradle.kts
dependencies {
    implementation(project(":feature:user:domain"))
    implementation(libs.retrofit)
    implementation(libs.room)
}

// presentation/build.gradle.kts
dependencies {
    implementation(project(":feature:user:domain"))
    // data 직접 의존 금지!
    implementation(libs.compose)
    implementation(libs.hilt)
}
```

## Notes

- 작은 기능은 레이어 분리가 오버엔지니어링일 수 있음
- 팀 규모와 프로젝트 복잡도에 맞게 조정
- 100% 클린 아키텍처보다 실용적 접근 권장
- Gradle 모듈 그래프 시각화 도구 활용 추천
