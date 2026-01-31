---
name: review-security
description: Android 보안 취약점 검사. 하드코딩된 키, 민감정보 로깅, 암호화 누락, 인증 우회 등 검출.
allowed-tools: Bash, Read, Grep, Glob
argument-hint: "[file|directory] [--strict] [--secrets]"
user-invocable: true
---

# Security Review Skill

Android 앱의 보안 취약점을 검사하는 skill입니다.

## When to Use

- PR 머지 전 보안 검토
- 릴리즈 전 보안 점검
- 인증/결제 관련 코드 변경 시
- 외부 API 연동 코드 검토 시

## Core Principles

1. **민감정보 보호**: 하드코딩 금지, 안전한 저장
2. **로깅 주의**: 프로덕션에서 민감정보 로깅 금지
3. **통신 보안**: HTTPS 필수, 인증서 검증
4. **입력 검증**: 모든 외부 입력 검증

## Process

### 1. 민감정보 검색

```bash
# API 키 패턴 검색
grep -rn "api[_-]?key\|apikey" --include="*.kt" --include="*.xml" .

# 하드코딩된 시크릿 검색
grep -rn "secret\|password\|token\|credential" --include="*.kt" .

# Base64 인코딩된 값 (키 은폐 시도)
grep -rn "eyJ\|YWRt\|c2Vj" --include="*.kt" .

# BuildConfig 외 상수 검색
grep -rn "const val.*=" --include="*.kt" . | grep -i "key\|secret\|token"
```

### 2. 로깅 검사

```bash
# Log 호출 검색
grep -rn "Log\.\|Timber\.\|println" --include="*.kt" .

# 민감 필드 로깅 검색
grep -rn "Log.*token\|Log.*password\|Log.*secret" --include="*.kt" .

# 릴리즈 빌드 로그 제거 확인
grep -rn "BuildConfig.DEBUG" --include="*.kt" . | grep -i "log"
```

### 3. 네트워크 보안 검사

```bash
# HTTP 사용 검색 (HTTPS 아닌)
grep -rn "http://" --include="*.kt" --include="*.xml" .

# 인증서 검증 우회 검색
grep -rn "trustAllCerts\|ALLOW_ALL\|hostnameVerifier" --include="*.kt" .

# 네트워크 보안 설정 확인
cat app/src/main/res/xml/network_security_config.xml
```

### 4. 저장소 보안 검사

```bash
# SharedPreferences 민감정보 저장 검색
grep -rn "putString.*token\|putString.*password" --include="*.kt" .

# EncryptedSharedPreferences 사용 확인
grep -rn "EncryptedSharedPreferences" --include="*.kt" .

# Room DB 암호화 확인
grep -rn "SQLCipher\|SupportFactory" --include="*.kt" .
```

## Checklist

### 🔴 Critical Vulnerabilities

#### 1. 하드코딩된 시크릿
```kotlin
// ❌ Critical - 하드코딩된 API 키
object ApiConfig {
    const val API_KEY = "sk-1234567890abcdef"  // 위험!
    const val SECRET = "my-secret-key"  // 위험!
}

// ✅ Safe - BuildConfig 또는 환경변수 사용
object ApiConfig {
    val API_KEY: String = BuildConfig.API_KEY
}

// local.properties (git ignored)
API_KEY=sk-1234567890abcdef

// build.gradle.kts
buildConfigField("String", "API_KEY", "\"${localProperties["API_KEY"]}\"")
```

#### 2. 민감정보 로깅
```kotlin
// ❌ Critical - 토큰/비밀번호 로깅
Log.d(TAG, "User token: $accessToken")
Log.d(TAG, "Login with password: $password")
Timber.d("Auth response: $authResponse")  // 토큰 포함 가능

// ✅ Safe - 민감정보 마스킹
Log.d(TAG, "User token: ${accessToken.take(4)}****")
Log.d(TAG, "Login attempted for user: ${email.maskEmail()}")

// ✅ Better - 릴리즈에서 제거
if (BuildConfig.DEBUG) {
    Log.d(TAG, "Debug info: $debugData")
}
```

#### 3. 인증서 검증 우회
```kotlin
// ❌ Critical - 모든 인증서 신뢰 (MITM 취약)
val trustAllCerts = arrayOf<TrustManager>(object : X509TrustManager {
    override fun checkClientTrusted(chain: Array<X509Certificate>, authType: String) {}
    override fun checkServerTrusted(chain: Array<X509Certificate>, authType: String) {}
    override fun getAcceptedIssuers(): Array<X509Certificate> = arrayOf()
})

// ❌ Critical - 호스트네임 검증 우회
val hostnameVerifier = HostnameVerifier { _, _ -> true }

// ✅ Safe - 기본 검증 사용 + 필요시 Certificate Pinning
val certificatePinner = CertificatePinner.Builder()
    .add("api.example.com", "sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=")
    .build()
```

#### 4. 평문 HTTP 통신
```kotlin
// ❌ Critical - HTTP 사용
val BASE_URL = "http://api.example.com"

// ✅ Safe - HTTPS 사용
val BASE_URL = "https://api.example.com"

// network_security_config.xml
// ❌ 위험한 설정
<base-config cleartextTrafficPermitted="true" />

// ✅ 안전한 설정
<base-config cleartextTrafficPermitted="false" />
```

### 🟡 Warnings

#### 5. SharedPreferences 민감정보 저장
```kotlin
// ❌ Warning - 평문 저장
sharedPreferences.edit()
    .putString("access_token", token)
    .putString("refresh_token", refreshToken)
    .apply()

// ✅ Safe - EncryptedSharedPreferences 사용
val encryptedPrefs = EncryptedSharedPreferences.create(
    context,
    "secure_prefs",
    MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC),
    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
)
encryptedPrefs.edit().putString("access_token", token).apply()
```

#### 6. 입력값 미검증
```kotlin
// ❌ Warning - 사용자 입력 직접 사용
fun loadUser(userId: String) {
    api.getUser(userId)  // SQL Injection, Path Traversal 가능
}

// ✅ Safe - 입력값 검증
fun loadUser(userId: String) {
    require(userId.matches(Regex("^[a-zA-Z0-9]+$"))) { "Invalid user ID" }
    api.getUser(userId)
}
```

#### 7. WebView 보안
```kotlin
// ❌ Warning - JavaScript 무분별 허용
webView.settings.javaScriptEnabled = true
webView.addJavascriptInterface(WebAppInterface(), "Android")

// ✅ Safe - 필요한 경우만 + 보안 설정
webView.settings.apply {
    javaScriptEnabled = true  // 필요한 경우만
    allowFileAccess = false
    allowContentAccess = false
}
// JavascriptInterface는 신중하게 사용
```

#### 8. 디버그 정보 노출
```kotlin
// ❌ Warning - 릴리즈에서 스택트레이스 노출
try {
    riskyOperation()
} catch (e: Exception) {
    showToast("Error: ${e.stackTraceToString()}")  // 위험!
}

// ✅ Safe - 사용자 친화적 메시지
try {
    riskyOperation()
} catch (e: Exception) {
    Timber.e(e, "Operation failed")  // 로그는 Debug만
    showToast("문제가 발생했습니다. 다시 시도해주세요.")
}
```

### 🟢 Suggestions

#### 9. ProGuard/R8 난독화
```kotlin
// build.gradle.kts
release {
    isMinifyEnabled = true  // 권장
    isShrinkResources = true
    proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"))
}
```

#### 10. Root/Emulator 감지
```kotlin
// 민감한 앱에서 권장
fun isDeviceSecure(): Boolean {
    return !isRooted() && !isEmulator()
}
```

## Command Usage

```bash
# 전체 보안 검사
/review:security

# 특정 디렉토리 검사
/review:security feature/payment/

# 시크릿 검사만
/review:security --secrets

# 엄격 모드 (모든 Warning 포함)
/review:security --strict
```

## Output Format

```markdown
## 🔒 Security Review: [대상]

### 📊 검사 결과
- 🔴 Critical: N개
- 🟡 Warning: N개
- 🟢 Suggestion: N개

### 🔴 Critical Vulnerabilities
**[파일:라인]** 하드코딩된 API 키 발견
\`\`\`kotlin
const val API_KEY = "sk-..."
\`\`\`
**조치**: BuildConfig 또는 환경변수 사용

### 🟡 Warnings
...

### 🟢 Suggestions
...

### ✅ Good Practices Found
- EncryptedSharedPreferences 사용됨
- HTTPS만 사용
- ProGuard 활성화됨
```

## Pre-Release Checklist

```markdown
## 릴리즈 전 보안 체크리스트

- [ ] 하드코딩된 시크릿 없음
- [ ] 프로덕션 로그에 민감정보 없음
- [ ] HTTPS만 사용
- [ ] 인증서 검증 활성화
- [ ] EncryptedSharedPreferences 사용
- [ ] ProGuard/R8 활성화
- [ ] debuggable=false (릴리즈)
- [ ] 입력값 검증 완료
```

## Notes

- 자동 검사는 100% 완벽하지 않음, 수동 검토 병행 권장
- OWASP Mobile Top 10 참고
- 정기적인 보안 감사 권장
- 민감 앱은 전문 보안 업체 진단 고려
