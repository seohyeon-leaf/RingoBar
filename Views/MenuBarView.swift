import SwiftUI

/// 메뉴바 아이콘 클릭 시 표시되는 드롭다운 패널 (PRD 5.1)
struct MenuBarView: View {
    @EnvironmentObject var engine: TimerEngine
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(spacing: 0) {

            // ── 상단: 상태 레이블 ──────────────────────────────
            HStack(spacing: 6) {
                Circle()
                    .fill(engine.state.accentColor)
                    .frame(width: 7, height: 7)
                Text(engine.state.displayName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            // ── 중앙 메인: 타이머 표시 ────────────────────────
            TimerDisplayView()
                .padding(.top, 18)
                .padding(.bottom, 10)

            // ── 중앙 서브: 세션 진행 상황 ─────────────────────
            sessionInfoView
                .padding(.bottom, 18)

            Divider()

            // ── 하단 컨트롤 ───────────────────────────────────
            ControlsView()
                .padding(.vertical, 10)

            Divider()

            // ── 최하단: 설정 링크 ─────────────────────────────
            Button("설정") {
                openSettings()
            }
            .buttonStyle(.plain)
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
            .padding(.vertical, 8)
        }
        .frame(width: 230)
    }

    // MARK: - 세션 정보

    @ViewBuilder
    private var sessionInfoView: some View {
        switch engine.state {
        case .idle:
            Text("시작 버튼을 눌러 집중을 시작하세요")
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
        case .completed:
            Text("싸이클 완료 🎉")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
        default:
            Text("세션 \(engine.currentSession) / \(engine.totalSessions)")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
    }
}
