import SwiftUI

/// 드롭다운 패널 하단 컨트롤 — 시작/일시정지/재개 + 리셋 버튼 (PRD 3.3)
struct ControlsView: View {
    @EnvironmentObject var engine: TimerEngine

    var body: some View {
        HStack(spacing: 10) {
            // 시작 / 일시정지 / 재개 통합 버튼
            Button(action: primaryAction) {
                Label(primaryLabel, systemImage: primaryIcon)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(engine.state.accentColor)
            // 휴식 중에는 자동 진행 → 버튼 비활성 (PRD 3.3.1)
            .disabled(engine.state.isBreak)

            // 리셋 버튼
            Button {
                engine.reset()
            } label: {
                Image(systemName: "arrow.counterclockwise")
            }
            .buttonStyle(.bordered)
            .help("싸이클 리셋")
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Helpers

    private func primaryAction() {
        switch engine.state {
        case .idle, .completed:
            engine.start()
        case .focusing:
            engine.pause()
        case .paused:
            engine.start()
        default:
            break
        }
    }

    private var primaryLabel: String {
        switch engine.state {
        case .idle, .completed:  return "시작"
        case .focusing:          return "일시정지"
        case .paused:            return "재개"
        case .shortBreak:        return "휴식 중"
        case .longBreak:         return "긴 휴식 중"
        }
    }

    private var primaryIcon: String {
        switch engine.state {
        case .idle, .completed, .paused:  return "play.fill"
        case .focusing:                   return "pause.fill"
        case .shortBreak, .longBreak:     return "cup.and.saucer.fill"
        }
    }
}
