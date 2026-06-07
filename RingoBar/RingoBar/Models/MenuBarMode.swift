import Foundation

/// 메뉴바 표시 모드 (PRD 3.1)
enum MenuBarMode: String, CaseIterable, Identifiable {
    case text     = "text"
    case circular = "circular"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .text:     return "텍스트 (23:45)"
        case .circular: return "원형 프로그레스"
        }
    }
}
