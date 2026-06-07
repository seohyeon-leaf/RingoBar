import Foundation
import Combine

/// RingoBar 핵심 타이머 엔진
/// - ObservableObject → SwiftUI 뷰가 @EnvironmentObject로 자동 구독
/// - 상태 전환 머신: idle → focusing ↔ paused → shortBreak/longBreak → completed
final class TimerEngine: ObservableObject {

    // MARK: - Published State (뷰 바인딩)

    @Published private(set) var state: TimerState = .idle
    @Published private(set) var remainingSeconds: Int = 0
    @Published private(set) var currentSession: Int = 1
    @Published private(set) var totalSessions: Int = 0
    @Published private(set) var accumulatedFocusSeconds: Int = 0
    /// menuBarMode를 engine에서 직접 발행 — MenuBarExtra label 재렌더링 보장
    @Published private(set) var menuBarMode: MenuBarMode = .text

    // MARK: - Dependencies

    let settings: AppSettings
    private let cycleManager          = CycleManager()
    private let notifications         = NotificationManager()
    private let floatingWindowManager = FloatingWindowManager()

    // MARK: - Private

    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init() {
        settings = AppSettings()
        notifications.requestAuthorization()
        applyIdleState()

        // settings 변경 감지
        settings.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.onSettingsChanged() }
            .store(in: &cancellables)

        // menuBarMode 변경 → engine에서 직접 발행 (MenuBarExtra label 업데이트용)
        settings.$menuBarMode
            .receive(on: RunLoop.main)
            .sink { [weak self] mode in self?.menuBarMode = mode }
            .store(in: &cancellables)

        menuBarMode = settings.menuBarMode

        // 플로팅 창 관리자 초기화 (원형 모드 전용)
        floatingWindowManager.setup(engine: self)
    }

    // MARK: - Public Controls

    /// 시작 / 재개 (idle, completed, paused 상태에서 호출)
    func start() {
        switch state {
        case .idle, .completed:
            beginNewCycle()
        case .paused:
            resumeFocus()
        default:
            break
        }
    }

    /// 일시정지 (focusing 상태에서만 가능 — PRD 3.3.1)
    func pause() {
        guard state == .focusing else { return }
        state = .paused
        stopTimer()
    }

    /// 현재 세션 및 싸이클 전체 초기화 (PRD 3.3.2)
    func reset() {
        stopTimer()
        // cycleManager는 상태 없음 — 별도 리셋 불필요
        applyIdleState()
    }

    // MARK: - Private: State Transitions

    private func beginNewCycle() {
        accumulatedFocusSeconds = 0
        currentSession  = 1
        totalSessions   = cycleManager.totalSessions(settings: settings)
        state           = .focusing
        remainingSeconds = sessionDuration
        startTimer()
    }

    private func resumeFocus() {
        state = .focusing
        startTimer()
    }

    private func applyIdleState() {
        accumulatedFocusSeconds = 0
        currentSession  = 1
        totalSessions   = cycleManager.totalSessions(settings: settings)
        state           = .idle
        remainingSeconds = sessionDuration
    }

    // MARK: - Private: Timer

    private func startTimer() {
        stopTimer()
        // .common 모드: 메뉴바 드롭다운이 열려 있어도 타이머 동작 보장
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        // 집중 중이면 순수 집중 시간 누적
        if state == .focusing {
            accumulatedFocusSeconds += 1
        }

        // 카운트다운
        if remainingSeconds > 0 {
            remainingSeconds -= 1
        }

        // 세션 종료 처리
        if remainingSeconds == 0 {
            handleTimerExpired()
        }
    }

    private func handleTimerExpired() {
        stopTimer()

        switch state {
        case .focusing:   handleFocusEnd()
        case .shortBreak: handleShortBreakEnd()
        case .longBreak:  handleLongBreakEnd()
        default: break
        }
    }

    private func handleFocusEnd() {
        // 싸이클 완료 여부를 먼저 확인 (PRD 4.1)
        if cycleManager.isCycleComplete(accumulatedFocusSeconds: accumulatedFocusSeconds, settings: settings) {
            state = .completed
            notifications.send(type: .cycleComplete, soundEnabled: settings.notificationSoundEnabled)
            return
        }

        notifications.send(type: .focusEnd, soundEnabled: settings.notificationSoundEnabled)

        // 긴 휴식 vs 짧은 휴식 결정 (PRD 4.2)
        if cycleManager.shouldTakeLongBreak(accumulatedFocusSeconds: accumulatedFocusSeconds, settings: settings) {
            state            = .longBreak
            remainingSeconds = Int(settings.longBreakMinutes * 60)
        } else {
            state            = .shortBreak
            remainingSeconds = Int(settings.shortBreakMinutes * 60)
        }

        startTimer()
    }

    private func handleShortBreakEnd() {
        notifications.send(type: .shortBreakEnd, soundEnabled: settings.notificationSoundEnabled)
        advanceToNextFocusSession()
    }

    private func handleLongBreakEnd() {
        notifications.send(type: .longBreakEnd, soundEnabled: settings.notificationSoundEnabled)
        advanceToNextFocusSession()
    }

    private func advanceToNextFocusSession() {
        currentSession  += 1
        state            = .focusing
        remainingSeconds = sessionDuration
        startTimer()
    }

    // MARK: - Settings Change Handler (PRD 3.3.3 — 설정 변경 즉시 적용)

    private func onSettingsChanged() {
        totalSessions = cycleManager.totalSessions(settings: settings)

        switch state {
        case .idle, .completed:
            // 대기/완료 상태: 다음 시작을 위해 표시값만 갱신
            remainingSeconds = sessionDuration

        case .focusing, .paused:
            // 집중/일시정지 중: 새 세션 시간으로 재계산
            // 이미 경과한 시간만큼 빼서 남은 시간 재설정
            let elapsed = sessionDuration - remainingSeconds
            let newRemaining = max(1, sessionDuration - elapsed)
            remainingSeconds = newRemaining

        case .shortBreak:
            // 짧은 휴식 중: 새 휴식 시간으로 재계산
            remainingSeconds = Int(settings.shortBreakMinutes * 60)

        case .longBreak:
            // 긴 휴식 중: 새 긴 휴식 시간으로 재계산
            remainingSeconds = Int(settings.longBreakMinutes * 60)
        }
    }

    // MARK: - Helpers

    private var sessionDuration: Int {
        Int(settings.sessionMinutes * 60)
    }

    /// 현재 단계 남은 비율 (1.0 = 가득, 0.0 = 완료)
    var progressValue: Double {
        let total: Double
        switch state {
        case .idle:      return 1.0
        case .completed: return 0.0
        case .focusing, .paused:
            total = settings.sessionMinutes * 60
        case .shortBreak:
            total = settings.shortBreakMinutes * 60
        case .longBreak:
            total = settings.longBreakMinutes * 60
        }
        guard total > 0 else { return 0 }
        return Double(remainingSeconds) / total
    }
}
