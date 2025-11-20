# 🍚 집밥메이트 (HomeMate)

> **자취생과 1인 가구를 위한 스마트한 식재료 관리 및 맞춤형 레시피 추천 서비스**

**집밥메이트**는 냉장고 속 식재료를 효율적으로 관리하고, 유통기한 알림과 보유 재료 기반 레시피 추천을 통해 건강하고 경제적인 식생활을 돕는 안드로이드 애플리케이션입니다.

---

## 📱 프로젝트 소개

- **프로젝트명**: 집밥메이트 (HomeMate)
- **개발 환경**: Flutter (Dart)
- **대상 사용자**: 요리에 익숙하지 않은 자취생, 식재료 관리가 필요한 1인 가구
- **핵심 가치**: 식재료 낭비 방지, 메뉴 고민 해결, 간편한 냉장고 관리

---

## 🚀 주요 기능

### 1. 🧊 냉장고 관리 (Refrigerator Management)
* **식재료 등록/수정/삭제**: 이름, 수량, 유통기한을 입력하여 냉장고 현황을 파악합니다.
* **캘린더 뷰**: `TableCalendar`를 활용하여 일자별 유통기한 만료 식재료를 직관적으로 확인합니다.
* **유통기한 임박 알림**: 홈 화면에서 유통기한이 임박한 재료를 우선적으로 표시합니다.
* **정렬 및 필터링**: 이름순, 유통기한 임박순 정렬 및 날짜별 조회가 가능합니다.

### 2. 📖 레시피 추천 및 검색 (Recipe Service)
* **레시피 검색**: 키워드를 통해 원하는 레시피를 실시간으로 검색합니다.
* **맞춤형 추천**: 사용자의 선호도(태그) 및 보유 재료를 기반으로 레시피를 추천합니다(AI 로직 연동 예정).
* **상세 정보 제공**: 난이도, 재료, 조리 순서 등 상세한 조리법을 제공합니다.
* **즐겨찾기**: 자주 보는 레시피를 즐겨찾기에 등록하여 모아볼 수 있습니다.

### 3. ⚙️ 사용자 맞춤 설정 (Personalization)
* **선호도 태그 설정**: 선호하는 식재료나 맛을 태그 형태로 선택하여 추천 알고리즘에 반영합니다.
* **마이페이지**: 알림 설정, 즐겨찾기 목록 관리, 회원 정보 관리 기능을 제공합니다.

---

## 🛠 기술 스택 (Tech Stack)

| 구분 | 내용 |
| --- | --- |
| **Framework** | [Flutter](https://flutter.dev/) |
| **Language** | [Dart](https://dart.dev/) |
| **State Management** | `setState` (Native), `StatefulWidget` |
| **External Packages** | `table_calendar`, `intl`, `firebase_core` |
| **Database** | Local Mock Data (초기), Firebase (추후 연동 예정) |

---

## 📂 디렉토리 구조 (Directory Structure)

```bash
lib/
├── main.dart                  # 앱 진입점 (Firebase 초기화 및 테마 설정)
├── main_screen.dart           # Bottom Navigation Bar 관리 (메인 프레임)
├── data/                      # 더미 데이터 (Mock Data)
│   ├── ingredient_data.dart   # 식재료 초기 데이터
│   ├── recipe_data.dart       # 레시피 초기 데이터
│   └── tos_data.dart          # 이용약관 텍스트
├── models/                    # 데이터 모델 클래스
│   ├── ingredient.dart        # 식재료 모델
│   ├── recipe.dart            # 레시피 모델
│   └── tag_model.dart         # 선호도 태그 모델
├── screens/                   # UI 화면
│   ├── home_screen.dart       # 홈 (오늘의 레시피, 임박 재료)
│   ├── refrigerator_screen.dart # 냉장고 관리 (캘린더)
│   ├── recipe_screen.dart     # 레시피 검색 및 목록
│   ├── recipe_detail_screen.dart # 레시피 상세 보기
│   ├── recommendation_screen.dart # 레시피 추천
│   ├── favorites_screen.dart  # 즐겨찾기 목록
│   ├── tags_screen.dart       # 선호도 태그 설정
│   ├── mypage_screen.dart     # 마이페이지
│   ├── login_screen.dart      # 로그인
│   ├── signup_screen.dart     # 회원가입
│   ├── loading_screen.dart    # 스플래시 스크린
│   └── tos_screen.dart        # 이용약관 화면
├── services/                  # 비즈니스 로직
│   ├── recipe_service.dart    # 레시피 검색/정렬 로직
│   ├── refrigerator_service.dart # 재료 추가/삭제/정렬 로직
│   └── recommendation_service.dart # 추천 알고리즘 로직
└── widgets/                   # 재사용 가능한 UI 컴포넌트
    ├── ingredient_item.dart   # 재료 리스트 아이템
    ├── recipe_card.dart       # 레시피 카드 아이템
    └── tag_item.dart          # 태그 아이템
```

## 📦 설치 및 실행 방법 (Installation)

이 프로젝트를 로컬 환경에서 실행하기 위해서는 Flutter SDK가 설치되어 있어야 합니다.

### 1. 프로젝트 클론 (Clone)
```bash
git clone https://github.com/your-username/home-mate.git
cd home-mate
```

### 2. 의존성 패키지 설치 (Dependencies)

프로젝트 실행에 필요한 주요 패키지들입니다. pubspec.yaml 파일의 dependencies 섹션에 아래 내용이 포함되어야 합니다.

YAML
```dart
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.0.0
  table_calendar: ^3.1.2
  intl: ^0.19.0
```
터미널에서 아래 명령어를 실행하여 패키지를 설치합니다.

```Bash
flutter pub get
```
### 3. Firebase 설정 (필수)
이 프로젝트는 firebase_core를 사용합니다.

Firebase Console에서 프로젝트를 생성합니다.

Android(google-services.json) 또는 iOS(GoogleService-Info.plist) 설정 파일을 다운로드하여 각 플랫폼 폴더에 위치시킵니다.

### 4. 앱 실행 (Run)
```Bash
flutter run
```

## 📝 향후 개발 계획 (Roadmap)
* [ ] **데이터베이스 연동**: 현재 로컬 메모리/Mock 데이터를 Firebase Firestore 또는 Realtime Database로 마이그레이션
* [ ] **회원가입/로그인 연동**: Firebase Authentication을 이용한 실제 인증 구현
* [ ] **AI 레시피 추천 고도화**: 단순 필터링이 아닌 사용자 식습관 데이터 기반 추천 알고리즘 적용
* [ ] **바코드 인식**: 식재료 등록 시 바코드 스캔을 통한 자동 입력 기능 추가

---

## 👥 Contributors
* **Team**: 한성대학교 IT공과대학 컴퓨터공학부 고급모바일프로그래밍 팀
* **Developer**: 이서하 (1971243), 신민혁 (2071214), 이시형 (2071248), 이윤수 (2171120)

