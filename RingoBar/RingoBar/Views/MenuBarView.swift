import SwiftUI

/// 메뉴바 아이콘 클릭 시 표시되는 드롭다운 패널 (PRD 5.1)
struct MenuBarView: View {
    @EnvironmentObject var engine: TimerEngine
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        VStack(spacing: 0) {

            // ── 상태 레이블 ──────────────────────────────
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

            // ── 타이머 표시 (모드 무관하게 항상 텍스트) ────────
            // 원형 모드의 파이 차트는 플로팅 창에서 표시
            TimerDisplayView()
                .padding(.top, 18)
                .padding(.bottom, 10)

            // ── 세션 진행 상황 ─────────────────────────────
            sessionInfoView
                .padding(.bottom, 18)

            Divider()

            // ── 컨트롤 ───────────────────────────────────
            ControlsView()
                .padding(.vertical, 10)

            Divider()

            // ── 인라인 시간 설정 ──────────────────────────
            VStack(spacing: 0) {

                // 싸이클 미리보기
                Text(settings.estimatedCycleDurationText)
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 8)

                Divider()
                    .padding(.horizontal, 16)

                // 집중 시간
                inlineStepperRow("1회 집중", value: $settings.sessionMinutes,
                                 range: 1...60, step: 1, unit: "분")
                inlineStepperRow("총 집중", value: $settings.totalFocusMinutes,
                                 range: 10...480, step: 10, unit: "분")

                Divider()
                    .padding(.horizontal, 16)

                // 휴식
                inlineStepperRow("짧은 휴식", value: $settings.shortBreakMinutes,
                                 range: 1...30, step: 1, unit: "분")
                inlineStepperRow("긴 휴식", value: $settings.longBreakMinutes,
                                 range: 1...60, step: 1, unit: "분")
                inlineStepperRow("긴 휴식 간격", value: $settings.longBreakIntervalMinutes,
                                 range: 10...240, step: 10, unit: "분마다")
            }
            .padding(.bottom, 4)

            Divider()

            // ── 설정 + 피드백 ─────────────────────────────
            settingsButton

            Divider()

            feedbackButton
        }
        .frame(width: 260)
    }

    // MARK: - 인라인 텍스트 입력 행

    private func inlineStepperRow(_ label: String,
                                   value: Binding<Double>,
                                   range: ClosedRange<Double>,
                                   step: Double,
                                   unit: String) -> some View {
        TimeInputRow(label: label, value: value, range: range, unit: unit)
    }

    // MARK: - 설정 버튼

    @ViewBuilder
    private var settingsButton: some View {
        Button("설정") {
            NSApp.activate(ignoringOtherApps: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }
        }
        .buttonStyle(.plain)
        .font(.system(size: 12))
        .foregroundStyle(.secondary)
        .padding(.vertical, 8)
    }

    // MARK: - 피드백 버튼

    private var feedbackButton: some View {
        Button(action: sendFeedbackEmail) {
            HStack(spacing: 4) {
                Image(systemName: "envelope")
                    .font(.system(size: 10))
                Text("불편함 알려주기")
                    .font(.system(size: 11))
            }
            .foregroundStyle(.tertiary)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 6)
    }

    private func sendFeedbackEmail() {
        if let url = URL(string: "https://forms.gle/Y9U3BbJNTu51hMnR9") {
            NSWorkspace.shared.open(url)
        }
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
