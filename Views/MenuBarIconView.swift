import SwiftUI

/// 메뉴바 아이콘 / 레이블 뷰 (PRD 3.1)
/// - 텍스트 모드: 잔여 시간 숫자 표시
/// - 원형 모드: 줄어드는 원형 프로그레스
struct MenuBarIconView: View {
    @ObservedObject var engine: TimerEngine

    var body: some View {
        Group {
            if engine.state == .idle {
                // 대기 중: SF Symbol 타이머 아이콘
                Image(systemName: "timer")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.secondary)
            } else {
                switch engine.settings.menuBarMode {
                case .text:
                    textModeView
                case .circular:
                    circularModeView
                }
            }
        }
        .frame(minWidth: 44)
    }

    // MARK: - 텍스트 모드

    private var textModeView: some View {
        Text(TimeFormatter.formatCompact(seconds: engine.remainingSeconds))
            .font(.system(size: 12, weight: .medium, design: .monospaced))
            .foregroundStyle(engine.state.accentColor)
    }

    // MARK: - 원형 프로그레스 모드 (PRD 3.1)

    private var circularModeView: some View {
        ZStack {
            // 배경 원
            Circle()
                .stroke(Color.secondary.opacity(0.25), lineWidth: 2)
                .frame(width: 14, height: 14)

            // 프로그레스 원 (시계 반대 방향으로 줄어듦)
            Circle()
                .trim(from: 0, to: progressValue)
                .stroke(engine.state.accentColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: 14, height: 14)
                .rotationEffect(.degrees(-90)) // 12시 방향에서 시작
                .animation(.linear(duration: 1), value: progressValue)
        }
    }

    /// 현재 세션의 남은 비율 (0.0 ~ 1.0)
    private var progressValue: Double {
        let totalSecs: Double
        switch engine.state {
        case .focusing, .paused:
            totalSecs = engine.settings.sessionMinutes * 60
        case .shortBreak:
            totalSecs = engine.settings.shortBreakMinutes * 60
        case .longBreak:
            totalSecs = engine.settings.longBreakMinutes * 60
        default:
            return 1.0
        }
        guard totalSecs > 0 else { return 1.0 }
        return Double(engine.remainingSeconds) / totalSecs
    }
}
