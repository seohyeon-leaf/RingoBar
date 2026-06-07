import UserNotifications

// MARK: - 알림 유형 (PRD 6장 기준)

enum NotificationType {
    case focusEnd       // 집중 세션 종료
    case shortBreakEnd  // 짧은 휴식 종료
    case longBreakEnd   // 긴 휴식 종료
    case cycleComplete  // 싸이클 완료

    var title: String { "RingoBar" }

    var body: String {
        switch self {
        case .focusEnd:       return "집중 시간이 끝났습니다. 잠깐 쉬어가세요."
        case .shortBreakEnd:  return "휴식 종료! 다시 집중할 시간이에요."
        case .longBreakEnd:   return "긴 휴식 종료! 새 세션을 시작하세요."
        case .cycleComplete:  return "오늘의 집중 싸이클 완료! 수고하셨습니다."
        }
    }
}

// MARK: - NotificationManager

/// macOS UserNotifications 프레임워크 래퍼 (PRD 6장)
/// 네트워크 없이 로컬 알림만 사용
final class NotificationManager {

    /// 앱 최초 실행 시 알림 권한 요청
    func requestAuthorization() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { granted, error in
                if let error { print("[NotificationManager] Auth error: \(error)") }
            }
    }

    /// 즉시 알림 발송
    func send(type: NotificationType, soundEnabled: Bool) {
        let content = UNMutableNotificationContent()
        content.title = type.title
        content.body  = type.body
        content.sound = soundEnabled ? .default : nil

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil  // trigger=nil → 즉시 발송
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("[NotificationManager] Delivery error: \(error)") }
        }
    }
}
