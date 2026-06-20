import SwiftUI
import UIKit

/// The one signature animation (time-box: 1 day). A clipped cup shape + gradient
/// mask that reads as espresso filling a cup, paired with a timer ring closing —
/// no real fluid physics. Plays once on reveal, then the card settles. Reduce
/// Motion skips the animation and just shows the card.
struct CardRevealView: View {
    let shot: Shot

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var fill: CGFloat = 0
    @State private var ring: CGFloat = 0
    @State private var cupOpacity: Double = 1
    @State private var cardOpacity: Double = 0
    @State private var actionsOpacity: Double = 0
    @State private var didAnimate = false
    @State private var shareSheet = false
    @State private var savedMessage: String?

    private let cupSize = CGSize(width: 168, height: 188)
    private let exportSize: CardSize = .stories

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Palette.cream, Palette.cream.opacity(0.95)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 22) {
                Spacer(minLength: 0)

                ZStack {
                    if cupOpacity > 0.01 {
                        cupAnimation.opacity(cupOpacity)
                    }
                    if cardOpacity > 0.01 {
                        ShotCardView(shot: shot, size: .preview)
                            .opacity(cardOpacity)
                    }
                }

                Spacer(minLength: 0)

                actions
                    .opacity(actionsOpacity)
                    .allowsHitTesting(actionsOpacity > 0.5)
            }
            .padding(20)

            if let savedMessage {
                savedToast(savedMessage)
            }
        }
        .onAppear { beginIfNeeded() }
        .sheet(isPresented: $shareSheet) {
            if let image = CardRenderer.render(shot: shot, size: exportSize) {
                ShareSheet(items: [image])
            }
        }
    }

    // MARK: - Animation

    private var cupAnimation: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: ring)
                .stroke(Palette.crema, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 248, height: 248)

            ZStack {
                CupShape(cupSize: cupSize)
                    .stroke(Palette.cremaSoft.opacity(0.6), lineWidth: 3)

                LinearGradient(
                    colors: [Palette.espresso, Palette.espresso.opacity(0.8), Palette.crema],
                    startPoint: .bottom, endPoint: .top
                )
                .frame(width: cupSize.width, height: cupSize.height)
                .mask(CupShape(cupSize: cupSize).fill(style: FillStyle(eoFill: true)))
                .mask(
                    Color.white
                        .frame(width: cupSize.width, height: cupSize.height * max(0.001, fill))
                        .frame(width: cupSize.width, height: cupSize.height, alignment: .bottom)
                )

                // crema sheen riding the surface of the fill
                Ellipse()
                    .fill(Palette.cremaSoft.opacity(0.85))
                    .frame(width: cupSize.width * 0.62, height: 7)
                    .offset(y: cupSize.height * 0.5 - cupSize.height * fill)
                    .opacity(fill > 0.02 && fill < 0.98 ? 1 : 0)
            }
            .frame(width: cupSize.width, height: cupSize.height)
        }
    }

    private func beginIfNeeded() {
        guard !didAnimate else { return }
        didAnimate = true

        if reduceMotion {
            cardOpacity = 1
            actionsOpacity = 1
            cupOpacity = 0
            return
        }

        withAnimation(.easeOut(duration: 1.0)) {
            fill = 1
            ring = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.45)) {
                cupOpacity = 0
                cardOpacity = 1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            HapticEngine.saveSuccess()
            withAnimation(.easeOut(duration: 0.3)) {
                actionsOpacity = 1
            }
        }
    }

    // MARK: - Actions

    private var actions: some View {
        VStack(spacing: 10) {
            PrimaryButton("Share card", systemImage: EspressoIcon.share) { shareSheet = true }
            HStack(spacing: 10) {
                SecondaryButton("Save photo", systemImage: "square.and.arrow.down") { savePhoto() }
                SecondaryButton("Done", systemImage: "checkmark") { dismiss() }
            }
            diffCardButton
        }
    }

    private var diffCardButton: some View {
        Button {
            // Diff card is a Pro feature (Phase 4). Surfaced here so the entry
            // point exists; gating + implementation arrive with StoreKit.
            savedMessage = "Diff cards come with Coffii Pro — coming soon."
            flashSavedMessage()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "rectangle.on.rectangle.angled")
                    .font(.system(size: 13, weight: .semibold))
                Text("Make diff card")
                    .font(.system(size: 14, weight: .semibold))
                Text("PRO")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.8)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Palette.cremaSoft.opacity(0.5))
                    .clipShape(Capsule())
            }
            .foregroundStyle(Palette.inkSoft)
        }
        .buttonStyle(.plain)
    }

    private func savePhoto() {
        guard let image = CardRenderer.render(shot: shot, size: exportSize) else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        savedMessage = "Saved to Photos"
        flashSavedMessage()
    }

    private func flashSavedMessage() {
        let message = savedMessage
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            if savedMessage == message { savedMessage = nil }
        }
    }

    private func savedToast(_ text: String) -> some View {
        Text(text)
            .font(.system(.subheadline, weight: .semibold))
            .foregroundStyle(Palette.paper)
            .padding(.horizontal, 18).padding(.vertical, 12)
            .background(Palette.espresso)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
            .transition(.opacity.combined(with: .move(edge: .top)))
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 60)
    }
}

// MARK: - Cup shape

private struct CupShape: Shape {
    let cupSize: CGSize

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        let bodyInset = w * 0.14
        let bodyTop = h * 0.04
        let bodyBottom = h * 0.74
        let bodyRect = CGRect(x: bodyInset, y: bodyTop, width: w - bodyInset * 2, height: bodyBottom - bodyTop)
        p.addRoundedRect(in: bodyRect, cornerSize: CGSize(width: w * 0.10, height: w * 0.10))

        // handle (right side)
        let handleSize = w * 0.22
        let handleRect = CGRect(
            x: bodyRect.maxX - handleSize * 0.15,
            y: bodyRect.midY - handleSize * 0.5,
            width: handleSize, height: handleSize
        )
        p.addEllipse(in: handleRect)

        // saucer
        let saucerRect = CGRect(x: w * 0.06, y: bodyBottom + h * 0.04, width: w * 0.88, height: h * 0.10)
        p.addEllipse(in: saucerRect)
        return p
    }
}

#Preview {
    CardRevealView(shot: Shot(dose: 18, yield: 36, brewSeconds: 28, tempC: 93, tasteNote: "Sweet, balanced, syrupy.", isGoodPull: true))
        .modelContainer(for: [Shot.self, Bean.self, Grinder.self, Machine.self, Basket.self], inMemory: true)
}
