import SwiftUI

/// 설정 창 (PRD 5.2) — 메뉴바 표시 + 기타만
/// 시간 설정은 메뉴바 패널에서 직접 변경 가능
struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
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

            // 기타
            Section("기타") {
                Toggle("알림 사운드", isOn: $settings.notificationSoundEnabled)
                Toggle("로그인 시 자동 시작", isOn: $settings.launchAtLogin)
            }
        }
        .formStyle(.grouped)
        .frame(width: 360, height: 220)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppSettings())
}
