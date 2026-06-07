import SwiftUI

/// 설정 창 (PRD 5.2)
/// - 저장 버튼 없음 — 변경 즉시 적용
/// - 상단에 예상 싸이클 소요 시간 표시
struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── 예상 싸이클 소요 시간 ─────────────────────────
            VStack(alignment: .leading, spacing: 6) {
                Text("싸이클 미리보기")
                    .font(.headline)
                Text(settings.estimatedCycleDurationText)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color.secondary.opacity(0.1),
                                in: RoundedRectangle(cornerRadius: 8))
            }
            .padding()

            Divider()

            Form {

                // 메뉴바 표시 모드
                Section("메뉴바 표시") {
                    Picker("표시 모드", selection: $settings.menuBarMode) {
                        ForEach(MenuBarMode.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // 집중 설정
                Section("집중 시간") {
                    stepperRow(label: "1회 집중 시간",
                               value: $settings.sessionMinutes,
                               range: 1...60, step: 1, unit: "분")
                    stepperRow(label: "총 집중 시간",
                               value: $settings.totalFocusMinutes,
                               range: 10...480, step: 10, unit: "분")
                }

                // 휴식 설정
                Section("휴식") {
                    stepperRow(label: "짧은 휴식",
                               value: $settings.shortBreakMinutes,
                               range: 1...30, step: 1, unit: "분")
                    stepperRow(label: "긴 휴식",
                               value: $settings.longBreakMinutes,
                               range: 1...60, step: 1, unit: "분")
                    stepperRow(label: "긴 휴식 간격",
                               value: $settings.longBreakIntervalMinutes,
                               range: 10...240, step: 10, unit: "분마다")
                }

                // 기타
                Section("기타") {
                    Toggle("알림 사운드", isOn: $settings.notificationSoundEnabled)
                    Toggle("로그인 시 자동 시작", isOn: $settings.launchAtLogin)
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 380)
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - 스텝퍼 행 헬퍼

    private func stepperRow(label: String,
                             value: Binding<Double>,
                             range: ClosedRange<Double>,
                             step: Double,
                             unit: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(Int(value.wrappedValue))\(unit)")
                .foregroundStyle(.secondary)
                .frame(minWidth: 60, alignment: .trailing)
            Stepper("", value: value, in: range, step: step)
                .labelsHidden()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppSettings())
}
