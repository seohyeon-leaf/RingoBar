import SwiftUI

/// 원형 모드 전용 플로팅 패널 내용
struct FloatingTimerPanelView: View {
    @EnvironmentObject var engine: TimerEngine

    var body: some View {
        ZStack {
            // 유리 배경
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.white.opacity(0.25), lineWidth: 0.5)

            VStack(spacing: 6) {
                CircularTimerView(
                    progress: engine.progressValue,
                    accentColor: engine.state.accentColor,
                    size: 118,
                    showTicks: true,
                    showCenterDot: true
                )

                Text(TimeFormatter.format(seconds: engine.remainingSeconds))
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(engine.state.accentColor)

                Text(engine.state.displayName)
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
        }
        .frame(width: 158, height: 186)
        .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 5)
    }
}
