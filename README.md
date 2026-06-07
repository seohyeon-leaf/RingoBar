# 🍎 RingoBar

macOS 메뉴바 전용 포모도로 타이머

![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![macOS](https://img.shields.io/badge/macOS-13%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 기능

- **메뉴바 상주** — Dock 아이콘 없이 메뉴바에서 바로 사용
- **텍스트 / 원형 모드** — 메뉴바 아이콘 표시 방식 선택
- **Time Timer 플로팅 창** — 원형 모드 시 화면 위에 항상 떠있는 파이 차트 타이머
- **인라인 시간 설정** — 팝업에서 집중·휴식 시간 직접 입력
- **자동 싸이클 관리** — 짧은 휴식 / 긴 휴식 자동 전환
- **로컬 알림** — 세션 종료 시 알림 (네트워크 연결 없음)
- **즉시 적용** — 설정 변경이 실시간으로 반영

## 설치 방법

1. [Actions](../../actions) 탭에서 최신 성공 빌드 클릭
2. **Artifacts** 에서 `RingoBar-xxxxx.dmg` 다운로드
3. DMG 열고 `RingoBar.app` 을 **Applications** 폴더로 드래그
4. 처음 실행 시 보안 경고가 뜨면:
   - **시스템 설정 → 개인 정보 보호 및 보안 → "확인 없이 열기"** 클릭

> ⚠️ Apple Developer 서명 없이 배포된 버전입니다.

## 불편한 점이 있다면

[피드백 남기기 →](https://forms.gle/Y9U3BbJNTu51hMnR9)

## 개발 환경

- Xcode 15+
- macOS 13 Ventura 이상
- Swift 5.9 / SwiftUI

## 빌드

```bash
git clone https://github.com/1seoe/RingoBar.git
cd RingoBar
open RingoBar/RingoBar.xcodeproj
```
