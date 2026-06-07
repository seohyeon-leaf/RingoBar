import SwiftUI

/// 메뉴바 아이콘 / 레이블 뷰 (PRD 3.1)
/// - 텍스트 모드: 잔여 시간 숫자
/// - 원형 모드: 상태 표시 아이콘 (파이 차트는 플로팅 창에서 표시)
struct MenuBarIconView: View {
    @ObservedObject var engine: TimerEngine

    var body: some View {
        switch engine.menuBarMode {
        case .text:
            textModeView
        case .circular:
            circularModeView
        }
    }

    // MARK: - 텍스트 모드: 잔여 시간

    private var textModeView: some View {
        Group {
            if engine.state == .idle {
                Image(systemName: "timer")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.secondary)
            } else {
                Text(TimeFormatter.formatCompact(seconds: engine.remainingSeconds))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(engine.state.accentColor)
            }
        }
        .frame(minWidth: 44)
    }

    // MARK: - 원형 모드: 상태 색상 점 아이콘

    private var circularModeView: some View {
        HStack(spacing: 4) {
            // 상태 색상 원 (앱 아이콘 느낌)
            ZStack {
                Circle()
                    .fill(engine.state == .idle
                          ? Color.secondary.opacity(0.2)
                          : engine.state.accentColor.opacity(0.18))
                    .frame(width: 18, height: 18)
                Circle()
                    .fill(engine.state == .idle
                          ? Color.secondary
                          : engine.state.accentColor)
                    .frame(width: 9, height: 9)
            }

            // 대기 중이 아닐 때만 시간 표시
            if engine.state != .idle {
                Text(TimeFormatter.formatCompact(seconds: engine.remainingSeconds))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(engine.state.accentColor)
            }
        }
        .frame(minWidth: 36)
    }
}
