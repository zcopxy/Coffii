import SwiftUI

/// Full-screen closing ring, serif elapsed seconds, tabular. Haptic on start
/// and stop; light tick at 25s/30s targets. Stop writes brewSeconds back.
struct ShotTimerView: View {
    var onComplete: (Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var startDate: Date?
    @State private var elapsedSeconds: Double = 0
    @State private var isRunning = false
    @State private var firedTargets: Set<Int> = []

    private let ringScaleSeconds: Double = 45
    private let targets: [Int] = [25, 30]

    private var displaySeconds: Int { Int(elapsedSeconds.rounded()) }
    private var ringProgress: Double { min(elapsedSeconds / ringScaleSeconds, 1.0) }

    private let ticker = Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Palette.espresso, Palette.espresso.opacity(0.86)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 36) {
                Spacer()

                Text("SHOT TIMER")
                    .eyebrow(.footnote)
                    .foregroundStyle(Palette.cremaSoft)

                ringView

                if isRunning {
                    Text("Tap stop when the stream blonds.")
                        .font(.system(.subheadline))
                        .foregroundStyle(Palette.cremaSoft.opacity(0.8))
                } else {
                    Text("A calm, full-screen timer. No scales, no graphs.")
                        .font(.system(.subheadline))
                        .foregroundStyle(Palette.cremaSoft.opacity(0.7))
                }

                Spacer()

                actionButton
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 28)
        }
        .preferredColorScheme(.dark)
        .onReceive(ticker) { _ in tick() }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
                    .foregroundStyle(Palette.cremaSoft)
            }
        }
    }

    private var ringView: some View {
        ZStack {
            Circle()
                .stroke(Palette.cremaSoft.opacity(0.18), lineWidth: 6)
            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(Palette.crema, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : .linear(duration: 0.08), value: displaySeconds)

            ForEach(targets, id: \.self) { t in
                targetMarker(for: t)
            }

            VStack(spacing: 4) {
                Text("\(displaySeconds)")
                    .font(.system(size: 96, weight: .semibold, design: .serif))
                    .tabularNumbers()
                    .foregroundStyle(Palette.paper)
                Text("seconds")
                    .eyebrow(.caption2)
                    .foregroundStyle(Palette.cremaSoft.opacity(0.7))
            }
        }
        .frame(width: 280, height: 280)
    }

    private func targetMarker(for target: Int) -> some View {
        let progress = min(Double(target) / ringScaleSeconds, 1.0)
        let angle = -90 + 360 * progress
        return Circle()
            .fill(Palette.cremaSoft)
            .frame(width: 8, height: 8)
            .offset(y: -140)
            .rotationEffect(.degrees(angle))
            .opacity(displaySeconds >= target ? 1 : 0.35)
    }

    private var actionButton: some View {
        Button(action: handleAction) {
            Text(isRunning ? "Stop" : "Start")
                .font(.system(size: 19, weight: .semibold, design: .serif))
                .frame(minWidth: 200, minHeight: 60)
                .foregroundStyle(Palette.espresso)
                .background(Palette.crema)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func handleAction() {
        if isRunning {
            stop()
        } else {
            start()
        }
    }

    private func start() {
        startDate = .now
        elapsedSeconds = 0
        firedTargets.removeAll()
        isRunning = true
        HapticEngine.startPull()
    }

    private func stop() {
        isRunning = false
        HapticEngine.stopPull()
        onComplete(displaySeconds)
        dismiss()
    }

    private func tick() {
        guard isRunning, let startDate else { return }
        elapsedSeconds = Date().timeIntervalSince(startDate)
        let secs = displaySeconds
        for t in targets where secs >= t && !firedTargets.contains(t) {
            firedTargets.insert(t)
            HapticEngine.targetTick()
        }
    }
}

#Preview {
    ShotTimerView { _ in }
}
