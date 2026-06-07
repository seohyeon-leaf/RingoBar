import Foundation

/// 싸이클/세션 상태 관리 (PRD 4장 기준)
final class CycleManager {

    // MARK: - 총 세션 수 계산

    /// 총 집중 시간을 1회 세션 시간으로 나눈 올림값 (PRD 4.3: 마지막 세션은 풀타임)
    func totalSessions(settings: AppSettings) -> Int {
        guard settings.sessionMinutes > 0 else { return 0 }
        return Int(ceil(settings.totalFocusMinutes / settings.sessionMinutes))
    }

    // MARK: - 긴 휴식 판단 (PRD 4.2)

    /// 순수 집중 누적 시간이 긴 휴식 간격의 배수에 도달하면 긴 휴식
    /// - Parameter accumulatedFocusSeconds: 휴식을 제외한 순수 집중 누적 초
    func shouldTakeLongBreak(accumulatedFocusSeconds: Int, settings: AppSettings) -> Bool {
        let intervalSec = Int(settings.longBreakIntervalMinutes * 60)
        guard intervalSec > 0 else { return false }
        return accumulatedFocusSeconds % intervalSec == 0
    }

    // MARK: - 싸이클 완료 판단 (PRD 4.1)

    /// 순수 집중 누적 시간이 총 집중 시간 이상이면 완료
    /// 마지막 세션은 풀타임으로 진행하므로 실제 누적은 총 집중 시간을 초과할 수 있음 (정상)
    func isCycleComplete(accumulatedFocusSeconds: Int, settings: AppSettings) -> Bool {
        return accumulatedFocusSeconds >= Int(settings.totalFocusMinutes * 60)
    }
}
