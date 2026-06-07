import Foundation
import Combine

// MARK: - AppSettings

/// 사용자 설정 — UserDefaults 기반 영구 저장
/// 설정값 변경 시 objectWillChange 자동 발행 → TimerEngine이 즉시 감지
final class AppSettings: ObservableObject {

    // MARK: - 타이머 설정 (PRD 3.4)

    @Published var sessionMinutes: Double {
        didSet { save("sessionMinutes", sessionMinutes) }
    }
    @Published var totalFocusMinutes: Double {
        didSet { save("totalFocusMinutes", totalFocusMinutes) }
    }
    @Published var shortBreakMinutes: Double {
        didSet { save("shortBreakMinutes", shortBreakMinutes) }
    }
    @Published var longBreakMinutes: Double {
        didSet { save("longBreakMinutes", longBreakMinutes) }
    }
    @Published var longBreakIntervalMinutes: Double {
        didSet { save("longBreakIntervalMinutes", longBreakIntervalMinutes) }
    }

    // MARK: - UI 설정

    @Published var menuBarMode: MenuBarMode {
        didSet { UserDefaults.standard.set(menuBarMode.rawValue, forKey: "menuBarMode") }
    }
    @Published var notificationSoundEnabled: Bool {
        didSet { save("notificationSoundEnabled", notificationSoundEnabled) }
    }
    @Published var launchAtLogin: Bool {
        didSet {
            save("launchAtLogin", launchAtLogin)
            applyLaunchAtLogin(launchAtLogin)
        }
    }

    // MARK: - 초기화

    init() {
        let d = UserDefaults.standard
        sessionMinutes           = d.optDouble("sessionMinutes")           ?? 25
        totalFocusMinutes        = d.optDouble("totalFocusMinutes")        ?? 120
        shortBreakMinutes        = d.optDouble("shortBreakMinutes")        ?? 5
        longBreakMinutes         = d.optDouble("longBreakMinutes")         ?? 15
        longBreakIntervalMinutes = d.optDouble("longBreakIntervalMinutes") ?? 60
        notificationSoundEnabled = d.optBool("notificationSoundEnabled")   ?? true
        launchAtLogin            = d.optBool("launchAtLogin")              ?? false
        menuBarMode              = MenuBarMode(rawValue: d.string(forKey: "menuBarMode") ?? "") ?? .text
    }

    // MARK: - 예상 싸이클 소요 시간 (PRD 3.4 설정 초기 안내)

    var estimatedCycleDurationText: String {
        let totalFocusSec = totalFocusMinutes * 60
        let sessionSec    = sessionMinutes * 60
        guard sessionSec > 0 else { return "-" }

        let sessions        = ceil(totalFocusSec / sessionSec)
        let longBreakCount  = floor(totalFocusMinutes / longBreakIntervalMinutes)
        let shortBreakCount = max(0, sessions - 1 - longBreakCount)
        let totalSec        = totalFocusSec
                            + shortBreakCount * shortBreakMinutes * 60
                            + longBreakCount  * longBreakMinutes  * 60

        let h      = Int(totalSec) / 3600
        let m      = (Int(totalSec) % 3600) / 60
        let breakM = Int(totalSec - totalFocusSec) / 60

        let focusH = Int(totalFocusMinutes) / 60
        let focusM = Int(totalFocusMinutes) % 60
        let focusStr = focusH > 0
            ? (focusM > 0 ? "\(focusH)시간 \(focusM)분" : "\(focusH)시간")
            : "\(focusM)분"
        let totalStr = h > 0 ? "약 \(h)시간 \(m)분" : "약 \(m)분"

        return "예상 소요: \(totalStr) (집중 \(focusStr) + 휴식 \(breakM)분)"
    }

    // MARK: - Private

    private func save(_ key: String, _ value: Double) {
        UserDefaults.standard.set(value, forKey: key)
    }
    private func save(_ key: String, _ value: Bool) {
        UserDefaults.standard.set(value, forKey: key)
    }

    private func applyLaunchAtLogin(_ enabled: Bool) {
        // macOS 13+: SMAppService 사용 (Phase 3에서 완전 구현)
        // 현재는 설정값만 저장
    }
}

// MARK: - UserDefaults Helper

private extension UserDefaults {
    func optDouble(_ key: String) -> Double? { object(forKey: key) as? Double }
    func optBool(_ key: String) -> Bool?     { object(forKey: key) as? Bool }
}
