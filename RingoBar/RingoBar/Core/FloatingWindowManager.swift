import AppKit
import SwiftUI
import Combine

/// 원형 모드 전용 플로팅 타이머 창 관리자
/// - 항상 다른 창 위에 표시 (NSWindow.Level.floating)
/// - 모든 스페이스에서 표시
/// - 드래그로 위치 이동 가능
final class FloatingWindowManager {

    private var panel: NSPanel?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Setup (TimerEngine.init에서 호출)

    func setup(engine: TimerEngine) {
        // 메뉴바 모드 변화 감지
        engine.$menuBarMode
            .receive(on: RunLoop.main)
            .sink { [weak self] mode in
                switch mode {
                case .circular: self?.showIfNeeded(engine: engine)
                case .text:     self?.hide()
                }
            }
            .store(in: &cancellables)

        // 타이머 상태 변화 감지 (idle ↔ 실행 중)
        engine.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self else { return }
                guard engine.menuBarMode == .circular else { return }
                if state == .idle {
                    self.hide()
                } else {
                    self.showIfNeeded(engine: engine)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Show / Hide

    private func showIfNeeded(engine: TimerEngine) {
        if panel == nil { createPanel(engine: engine) }
        panel?.orderFront(nil)
    }

    func hide() {
        panel?.orderOut(nil)
    }

    // MARK: - Panel 생성

    private func createPanel(engine: TimerEngine) {
        let size = CGSize(width: 158, height: 186)

        let rootView = FloatingTimerPanelView()
            .environmentObject(engine)
        let hosting = NSHostingView(rootView: rootView)
        hosting.frame = NSRect(origin: .zero, size: size)

        let p = NSPanel(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        p.level = .floating
        p.backgroundColor = .clear
        p.isOpaque = false
        p.hasShadow = false           // 그림자는 SwiftUI 뷰에서 처리
        p.contentView = hosting
        p.isMovableByWindowBackground = true   // 드래그 이동 가능
        p.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]

        // 화면 오른쪽 위, 메뉴바 바로 아래 배치
        if let screen = NSScreen.main {
            let x = screen.frame.maxX - size.width - 12
            let y = screen.visibleFrame.maxY - size.height - 10
            p.setFrameOrigin(NSPoint(x: x, y: y))
        }

        self.panel = p
    }
}
