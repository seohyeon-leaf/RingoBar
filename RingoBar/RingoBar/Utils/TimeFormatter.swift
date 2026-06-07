import Foundation

/// 초(Int)를 사람이 읽을 수 있는 시간 문자열로 변환하는 유틸리티
enum TimeFormatter {

    /// 드롭다운 패널용 — "MM:SS" (두 자리 패딩)
    /// 예: 1500 → "25:00"
    static func format(seconds: Int) -> String {
        let m = max(0, seconds) / 60
        let s = max(0, seconds) % 60
        return String(format: "%02d:%02d", m, s)
    }

    /// 메뉴바 아이콘용 — "M:SS" (분은 패딩 없음)
    /// 예: 1500 → "25:00", 90 → "1:30"
    static func formatCompact(seconds: Int) -> String {
        let m = max(0, seconds) / 60
        let s = max(0, seconds) % 60
        return String(format: "%d:%02d", m, s)
    }
}
