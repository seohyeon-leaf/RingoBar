import SwiftUI

/// 타이머의 현재 상태를 나타내는 열거형
enum TimerState: Equatable {
    case idle        // 대기 중 (시작 전 또는 리셋 후)
    case focusing    // 집중 중
    case paused      // 일시정지
    case shortBreak  // 짧은 휴식
    case longBreak   // 긴 휴식
    case completed   // 싸이클 완료

    var displayName: String {
        switch self {
        case .idle:        return "대기 중"
        case .focusing:    return "집중 중"
        case .paused:      return "일시정지"
        case .shortBreak:  return "짧은 휴식"
        case .longBreak:   return "긴 휴식"
        case .completed:   return "싸이클 완료"
        }
    }

    /// 상태별 강조 색상 — Assets의 named color 사용
    var accentColor: Color {
        switch self {
        case .focusing:
            return Color("FocusRed")
        case .shortBreak, .longBreak:
            return Color("BreakGreen")
        case .paused:
            return Color("PauseGray")
        case .idle, .completed:
            return Color.secondary
        }
    }

    /// 일시정지 가능 여부 (집중 중일 때만 가능)
    var canPause: Bool { self == .focusing }

    /// 휴식 상태 여부 (휴식 중에는 자동 진행, 버튼 비활성)
    var isBreak: Bool { self == .shortBreak || self == .longBreak }
}
