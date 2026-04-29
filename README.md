# cltv-sign

모두싸인(Modusign) 클론 전자서명 플랫폼 — Flutter 기반 웹 + 앱 멀티플랫폼 지원

---

## 프로젝트 개요

cltv-sign은 전자서명 SaaS 서비스 모두싸인을 분석하여 Flutter로 구현한 클론 프로젝트입니다. 단일 코드베이스로 웹(브라우저), Android, iOS를 모두 지원합니다.

---

## 기술 스택

| 분류 | 기술 |
|------|------|
| 프레임워크 | Flutter 3.x (Dart) |
| 상태 관리 | Provider |
| 라우팅 | go_router |
| UI | Material 3 커스텀 테마 |
| 날짜 처리 | intl |
| 파일 선택 | file_picker |
| 서명 캔버스 | signature |
| 플랫폼 | Web, Android, iOS |

---

## 주요 기능

### 인증
- 이메일/비밀번호 로그인
- 회원가입
- 데모 계정 자동 로그인

### 대시보드
- 현황 요약 (전체 문서, 진행중, 완료, 이번달 서명)
- 빠른 시작 (문서 업로드, 서명 요청, 템플릿, 링크 서명)
- 이번달 사용량 진행률
- 최근 문서 목록

### 문서함
- 전체 / 진행중 / 완료 / 임시저장 탭 필터
- 문서 상태 배지 (서명 진행중, 완료, 서명 대기, 임시저장)
- 서명 진행률 표시
- 문서 상세 보기

### 서명 요청
- PDF 문서 업로드
- 서명자 추가 (이름, 이메일)
- 서명 필드 배치 (서명, 날인, 이니셜, 날짜, 텍스트)
- 서명 요청 발송

### 서명 진행
- 서명자 전용 빰
- 손글씨 서명 캔버스
- 서명 완료 처리

### 템플릿
- 카테고리별 템플릿 (계약서, 동의서, 인사, 부동산, 기타)
- 템플릿 검색
- 기본 제공 템플릿 6종

### 설정
- 프로필 관리
- 알림 설정 (이메일, 카카오톡, 서명 독쒅, 완료, 마케팅)
- 요금제 정보
- 보안 설정 (비밀번호 변경, 기기 관리)

---

## 프로젝트 구조

```
lib/
├── core/
│   ├── constants/      # 앱 상수, 라우트 정의
│   ├── router/         # go_router 설정, 메인 셸 레이아웃
│   ├── theme/          # 앱 테마, 색상 팔레트
│   └── widgets/        # 공통 위젯 (AppCard, StatusBadge, ProgressBar 등)
├── data/
│   ├── models/         # DocumentModel, UserModel
│   ├── providers/      # AuthProvider, DocumentProvider
│   └── services/       # MockDataService
└── features/
    ├── landing/        # 랜딩 페이지
    ├── auth/           # 로그인, 회원가입
    ├── dashboard/      # 대시보드
    ├── document/       # 문서함, 새 문서, 문서 상세, 서명 요청
    ├── signing/        # 서명 진행 화면, 서명 캔버스, 서명 필드
    ├── sign/           # 서명자 빰, 서명 완료
    ├── template/       # 템플릿 목록
    └── settings/       # 설정
```

---

## 실행 방법

### 사전 요구사항
- Flutter SDK 3.x 이상
- Dart SDK 3.x 이상

### 웹 실행
```bash
flutter pub get
flutter run -d chrome
```

### 웹 빌드
```bash
flutter build web --release --web-renderer html
```

### Android 실행
```bash
flutter run -d android
```

### iOS 실행
```bash
flutter run -d ios
```

---

## GitHub

https://github.com/hawoond/cltv-sign
