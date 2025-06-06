# AdMob 개인 수익 대시보드

개인용 AdMob 수익을 실시간으로 확인할 수 있는 Flutter 앱입니다. Google AdMob Reporting API를 사용하여 일별 수익, 클릭, 노출 데이터를 조회합니다.


## 📱 주요 기능

- ✅ **Google OAuth 로그인**: 안전한 Google 계정 연동
- 📊 **실시간 수익 조회**: 지난 7일간 일별 AdMob 수익 데이터
- 📈 **수익 요약**: 총 수익, 클릭, 노출, CTR 통계
- 🔄 **자동 새로고침**: 플로팅 버튼으로 데이터 갱신
- 🔐 **안전한 토큰 관리**: 약 1시간 유효한 OAuth 토큰
- 📱 **반응형 UI**: iOS/Android 모두 지원

## 🚀 빠른 시작

### 사전 준비사항

- Flutter SDK 3.0+ 설치
- iOS: Xcode 14+, macOS 개발 환경
- Google Cloud Console 계정

## 📋 설정 가이드

### 1단계: Google Cloud Console 설정

#### 1.1 프로젝트 생성
1. [Google Cloud Console](https://console.cloud.google.com/)에 접속
2. **새 프로젝트 만들기** 클릭
3. 프로젝트 이름 입력 (예: `my-admob-dashboard`)
4. **만들기** 클릭

#### 1.2 AdMob Reporting API 활성화
1. 좌측 메뉴에서 **API 및 서비스** > **라이브러리** 선택
2. "AdMob API" 검색
3. **AdMob API** 선택 후 **사용** 클릭

#### 1.3 OAuth 2.0 클라이언트 ID 생성

**iOS용 클라이언트 ID:**
1. **API 및 서비스** > **사용자 인증 정보** 이동
2. **+ 사용자 인증 정보 만들기** > **OAuth 클라이언트 ID** 선택
3. **애플리케이션 유형**: iOS
4. **번들 ID**: `com.yourname.admobchecker` (본인의 프로젝트 번틀ID와 동일한 이름으로 해야한다) 
5. **만들기** 클릭
6. **클라이언트 ID**를 복사해서 저장


### 2단계: 프로젝트 설정

#### 2.1 저장소 클론
```bash
git clone https://github.com/flutterkage2k/admob-personal-dashboard.git
cd admob-personal-dashboard
```

#### 2.2 종속성 설치
```bash
flutter pub get
```

#### 2.3 환경 변수 설정
프로젝트 루트에 `.env` 파일 생성:
```env
# AdMob Publisher ID (pub-xxxxxxxxxxxxxxxx 형태)
ADMOB_PUBLISHER_ID=pub-your-publisher-id-here
```

> 💡 **Publisher ID 는 방법**: AdMob 콘솔 > 계정 > 계정 정보에서 확인

#### 2.4 iOS 설정

**방법 1: Google Cloud Console 클라이언트 ID 직접 사용 (권장)**

`ios/Runner/Info.plist` 파일에 다음 내용 추가:
```xml
<!-- Google Sign-In 클라이언트 ID -->
<key>GIDClientID</key>
<string>YOUR_IOS_CLIENT_ID_HERE.apps.googleusercontent.com</string>

<!-- URL Schemes (중요: 클라이언트 ID를 역순으로) -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_IOS_CLIENT_ID_HERE</string>
        </array>
    </dict>
</array>

<!-- iOS 14+ 호환성을 위한 쿼리 스킴 -->
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>google</string>
    <string>com.googleusercontent.apps.YOUR_IOS_CLIENT_ID_HERE</string>
</array>
```

> 💡 **YOUR_IOS_CLIENT_ID_HERE**를 Google Cloud Console에서 생성한 iOS 클라이언트 ID로 교체하세요.
> 
> 예시: `170220951508-2tfffl3ubr04rqbkdoadcfav4okdl0gf`

> ⚠️ **주의**: 기존에 `client_*.plist` 파일이 있다면 삭제하세요. Info.plist 방식과 충돌할 수 있습니다.



### 3단계: AdMob 계정 연결

#### 3.1 AdMob API 액세스 권한 설정
1. [AdMob 콘솔](https://apps.admob.com/) 접속
2. **계정** > **계정 정보** 이동
3. **API 액세스** 섹션에서 **AdMob Reporting API 액세스** 활성화
4. Google Cloud Console에서 사용한 **동일한 Google 계정**이어야 함

#### 3.2 권한 확인
- AdMob 계정과 Google Cloud Console이 **같은 이메일**로 로그인되어 있는지 확인
- AdMob Reporting API 권한이 활성화되어 있는지 확인

## 🛠️ 빌드 및 실행

### 개발 모드 실행
```bash
# iOS
flutter run -d ios

```

### 릴리즈 빌드
```bash
# iOS (App Store 배포용은 불가)
flutter build ios --release

```

## 📱 사용 방법

1. **앱 실행**: 빌드된 앱을 기기에 설치 후 실행
2. **로그인**: "Google로 로그인" 버튼 클릭
3. **권한 승인**: AdMob 데이터 읽기 권한 승인
4. **데이터 확인**: 지난 7일간 일별 수익 데이터 조회
5. **새로고침**: 플로팅 버튼으로 최신 데이터 갱신
6. **로그아웃**: 상단 우측 로그아웃 버튼 클릭

## 🔐 보안 및 개인정보

### 토큰 유효기간
- **OAuth 액세스 토큰**: 약 1시간 유효
- **자동 갱신**: 백그라운드에서 자동으로 토큰 갱신 시도
- **수동 갱신**: 만료 시 재로그인 필요

### 데이터 저장
- ❌ **서버 저장 없음**: 모든 데이터는 기기에서만 처리
- ❌ **개인정보 수집 없음**: Google OAuth 외 추가 정보 수집 안 함
- ✅ **로컬 처리**: API 응답은 메모리에서만 처리 후 폐기

### 권한 범위
- `https://www.googleapis.com/auth/admob.readonly`: AdMob 데이터 읽기 전용

## 🐛 문제 해결

### 일반적인 오류

**1. "API 키가 유효하지 않습니다"**
```
해결: Google Cloud Console에서 AdMob Reporting API가 활성화되어 있는지 확인
```

**2. "권한이 없습니다"**
```
해결: AdMob 계정과 Google Cloud Console이 같은 이메일인지 확인
      AdMob에서 API 액세스가 활성화되어 있는지 확인
```

**3. "Publisher ID를 찾을 수 없습니다"**
```
해결: .env 파일의 ADMOB_PUBLISHER_ID 확인
      AdMob 콘솔 > 계정 > 계정 정보에서 올바른 ID 복사
```

**4. "토큰이 만료되었습니다"**
```
해결: 로그아웃 후 다시 로그인
      토큰은 약 1시간마다 갱신 필요
```

### 로그 확인
개발 중 문제 발생 시:
```bash
# Flutter 로그 확인
flutter logs

# iOS 시뮬레이터 로그
xcrun simctl spawn booted log stream --predicate 'process == "Runner"'
```

## 📁 프로젝트 구조

```
lib/
├── main.dart                          # 앱 진입점
├── model/
│   └── admob_report_model.dart       # 데이터 모델
├── repository/
│   └── admob_repository.dart         # API 통신 로직
└── presentation/
    ├── providers/
    │   └── admob_provider.dart       # 상태 관리 (Riverpod)
    └── screens/
        └── admob_home_page.dart      # 메인 화면
        
android/
├── app/
│   ├── build.gradle                  # Android 빌드 설정
│   └── google-services.json         # Firebase 설정 (추가 필요)

ios/
└── Runner/
    ├── Info.plist                    # iOS 설정
    └── GoogleService-Info.plist      # Firebase 설정 (추가 필요)

.env                                   # 환경 변수 (생성 필요)
pubspec.yaml                          # Flutter 종속성
README.md                             # 이 문서
```

## 🔧 기술 스택

- **프론트엔드**: Flutter 3.0+
- **플랫폼**: iOS 14.0+
- **상태 관리**: Riverpod
- **HTTP 통신**: http package
- **환경 변수**: flutter_dotenv
- **인증**: google_sign_in
- **API**: Google AdMob Reporting API v1

## 📊 API 응답 예시

```json
{
  "header": {
    "dateRange": {
      "startDate": {"year": 2025, "month": 5, "day": 30},
      "endDate": {"year": 2025, "month": 6, "day": 6}
    },
    "localizationSettings": {"currencyCode": "USD"}
  },
  "row": {
    "dimensionValues": {
      "DATE": {"value": "20250530"}
    },
    "metricValues": {
      "ESTIMATED_EARNINGS": {"microsValue": "363812"},
      "IMPRESSIONS": {"integerValue": "355"},
      "CLICKS": {"integerValue": "2"}
    }
  }
}
```

## 🚨 중요 주의사항

### App Store 배포 제한
- **개인용 앱**: 이 앱은 개인 사용 목적으로 제작됨
- **배포 금지**: AdMob API 사용 약관상 상업적 배포 제한
- **계정 보안**: 본인의 AdMob 계정에만 사용

### iOS 개발자 계정 요구사항
- **Apple Developer Program**: $99/년 (실기기 테스트 및 설치용)
- **시뮬레이터**: 무료 계정으로도 시뮬레이터에서 테스트 가능
- **사이드로딩**: 개발자 계정 있으면 개인 기기에 직접 설치 가능

## 🍎 iOS 전용 기능

### 지원 기기
- iPhone: iOS 14.0 이상
- iPad: iPadOS 14.0 이상
- 모든 화면 크기 대응

### iOS 최적화
- Dark Mode 자동 대응
- Dynamic Type 지원
- VoiceOver 접근성 지원
- Hand off 준비 (향후 Mac 연동)

## 📜 라이선스

MIT License - 개인 사용에 한함

```
MIT License

Copyright (c) 2025 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 🤝 기여하기

이 프로젝트는 개인용이지만 개선 사항이나 버그 수정은 환영합니다!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 지원

문제가 발생하면 다음을 확인해주세요:

1. ✅ `.env` 파일에 올바른 Publisher ID 설정
2. ✅ Google Cloud Console에서 AdMob Reporting API 활성화
3. ✅ Info.plist에 올바른 클라이언트 ID 설정
4. ✅ AdMob 계정과 Google Cloud Console 계정 일치
5. ✅ iOS 번들 ID와 OAuth 클라이언트 ID의 번들 ID 일치

GitHub Issues를 통해 문제를 신고해주세요.

---

⭐ **이 프로젝트가 유용했다면 Star를 눌러주세요!**