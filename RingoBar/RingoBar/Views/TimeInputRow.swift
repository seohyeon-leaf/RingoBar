 import SwiftUI

/// 시간 직접 입력 행 — 숫자 타이핑 후 Enter 또는 포커스 아웃 시 적용
struct TimeInputRow: View {
    let label: String
    let value: Binding<Double>
    let range: ClosedRange<Double>
    let unit: String

    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

            Spacer()

            HStack(spacing: 2) {
                TextField("", text: $text)
                    .font(.system(size: 12, design: .monospaced))
                    .multilineTextAlignment(.trailing)
                    .focused($isFocused)
                    .frame(width: 38)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(isFocused
                                  ? Color.accentColor.opacity(0.12)
                                  : Color.secondary.opacity(0.10))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .strokeBorder(isFocused
                                          ? Color.accentColor.opacity(0.5)
                                          : Color.clear,
                                          lineWidth: 1)
                    )
                    .onAppear { text = "\(Int(value.wrappedValue))" }
                    .onChange(of: value.wrappedValue) { newVal in
                        // 외부(엔진 리셋 등)에서 값이 바뀌면 동기화
                        // DispatchQueue로 뷰 업데이트 사이클 밖에서 실행 (경고 방지)
                        if !isFocused {
                            DispatchQueue.main.async { text = "\(Int(newVal))" }
                        }
                    }
                    .onSubmit { commit() }
                    .onChange(of: isFocused) { focused in
                        if !focused { commit() }
                    }

                Text(unit)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }

    private func commit() {
        guard let parsed = Double(text) else {
            // 숫자가 아니면 원래 값으로 복원
            text = "\(Int(value.wrappedValue))"
            return
        }
        let clamped = min(max(parsed, range.lowerBound), range.upperBound)
        value.wrappedValue = clamped
        text = "\(Int(clamped))"
    }
}
