import SwiftUI

/// 앱 진입점
/// - MenuBarExtra (.window 스타일): 드롭다운 패널
/// - Settings 씬: 설정 창 (Phase 2)
/// - Dock 아이콘 없음 (Info.plist LSUIElement = YES)
@main
struct RingoBarApp: App {
    @StateObject private var engine = TimerEngine()

    var body: some Scene {
        // 메뉴바 전용 (PRD 1.2)
        MenuBarExtra {
            MenuBarView()
                .environmentObject(engine)
                .environmentObject(engine.settings)
        } label: {
            MenuBarIconView(engine: engine)
        }
        .menuBarExtraStyle(.window)

        // 설정 창 — "설정" 링크 클릭 시 openSettings()로 열림
        Settings {
            SettingsView()
                .environmentObject(engine.settings)
        }
    }
}
