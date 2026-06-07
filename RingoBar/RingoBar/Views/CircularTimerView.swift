import SwiftUI

// MARK: - Time Timer 스타일 원형 타이머 뷰

struct CircularTimerView: View {
    let progress: Double      // 0.0 ~ 1.0 (남은 비율)
    let accentColor: Color
    let size: CGFloat
    var showTicks: Bool = true
    var showCenterDot: Bool = true

    private var innerRatio: CGFloat { 0.26 }

    var body: some View {
        ZStack {
            // 1. 배경 원 (연한 회색)
            Circle()
                .fill(Color.secondary.opacity(0.10))

            // 2. 남은 시간 파이 섹터
            PieSector(progress: max(0, min(1, progress)))
                .fill(accentColor.opacity(0.85))
                .animation(.linear(duration: 0.5), value: progress)

            // 3. 테두리
            Circle()
                .strokeBorder(Color.secondary.opacity(0.18), lineWidth: 1)

            // 4. 눈금 (5분 간격 × 12개)
            if showTicks {
                tickMarks
            }

            // 5. 중앙 흰 원 (Time Timer 중심 버튼 느낌)
            if showCenterDot {
                Circle()
                    .fill(Color(nsColor: .windowBackgroundColor))
                    .frame(width: size * innerRatio, height: size * innerRatio)
                    .shadow(radius: 1)
            }
        }
        .frame(width: size, height: size)
    }

    // 눈금 — 5분 간격 12개
    private var tickMarks: some View {
        ZStack {
            ForEach(0..<12) { i in
                let angle = Double(i) * 30.0   // 360 / 12
                let isMajor = i % 3 == 0       // 15분마다 큰 눈금
                Rectangle()
                    .fill(Color.secondary.opacity(isMajor ? 0.35 : 0.18))
                    .frame(width: isMajor ? 1.5 : 1,
                           height: isMajor ? size * 0.09 : size * 0.06)
                    .offset(y: -(size / 2 - (isMajor ? size * 0.045 : size * 0.03)))
                    .rotationEffect(.degrees(angle))
            }
        }
    }
}

// MARK: - 파이 섹터 Shape (12시 방향 기준 시계 방향)

struct PieSector: Shape {
    var progress: Double   // 0.0 ~ 1.0

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        guard progress > 0 else { return Path() }
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let startAngle = Angle.degrees(-90)
        let endAngle   = Angle.degrees(-90 + 360 * progress)

        path.move(to: center)
        path.addArc(center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        path.closeSubpath()
        return path
    }
}
