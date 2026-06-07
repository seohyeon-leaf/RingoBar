import SwiftUI

/// 드롭다운 패널 중앙 — 타이머 숫자 표시 (Phase 1: 텍스트 모드)
/// Phase 2에서 원형 프로그레스 모드 추가 예정
struct TimerDisplayView: View {
    @EnvironmentObject var engine: TimerEngine

    var body: some View {
        VStack(spacing: 6) {
            Text(TimeFormatter.format(seconds: engine.remainingSeconds))
                .font(.system(size: 52, weight: .thin, design: .monospaced))
                .foregroundStyle(labelColor)
                .contentTransition(.numericText(countsDown: true))
                .animation(.linear(duration: 0.3), value: engine.remainingSeconds)
        }
    }

    private var labelColor: Color {
        engine.state == .idle ? Color.secondary : engine.state.accentColor
    }
}
