//
//  OnboardingView.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 11.02.2026.
//

import SwiftUI
import Combine

enum OnboardingPage {
    case zero      // 👈 Новая пустая страница
    case one
    case two
    case three
    case four
    case five
}

struct ButtonOverviewNext: View {
    let color = LinearGradient(
        colors: [ColorConstants.foreground, ColorConstants.foregroundSec],
        startPoint: .top,
        endPoint: .bottom
    )
    let text: String
    let action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .foregroundStyle(ColorConstants.background)
                .frame(width: 300, height: 120)
                .font(.system(size: LayoutConstants.FontSize.title1))
                .bold()
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.large))
                .shadow(color: ColorConstants.foreground, radius: 2, y: 4)
        }
    }
}

struct BusOnRoadSideView: View {
    let bus: String = "BusFront"
    let onWaveHaptic: (Double) -> Void
    @State private var offset: CGFloat = 0
    let maxTime: Double = 2.0

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Image(bus)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 130)
                    .offset(x: offset)

                Rectangle()
                    .foregroundStyle(ColorConstants.foreground)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onAppear {
                offset = -geo.size.width / 2 - 240 // старт за левым краем

                withAnimation(.linear(duration: maxTime)) {
                    offset = geo.size.width / 2 + 240 // финиш за правым краем
                }
                onWaveHaptic(maxTime)
            }
        }
        .frame(height: 150)
    }
}

struct OnboardingView: View {
    @ObservedObject var onboardingViewModel: OnboardingViewModel
    @State private var selectedPage: OnboardingPage = .zero  // 👈 Стартуем с нулевой страницы
    @EnvironmentObject private var untitledVM: UntitledViewModel

    var body: some View {
        ZStack {
            ColorConstants.background.ignoresSafeArea()

            VStack {
                Spacer()

                Group {
                    ZStack {
                        switch selectedPage {
                        case .zero: emptyPage      // 👈 Новая пустая страница
                        case .one: firstPage
                        case .two: secondPage
                        case .three: thirdPage
                        case .four: fourthPage
                        case .five: fifthPage
                        }
                    }
                    .animation(.easeInOut, value: selectedPage)

                    Group {
                        switch selectedPage {
                        case .zero:
                            Color.clear.frame(height: 300)  // 👈 Пустое место для zero страницы
                        case .one:
                            BusOnRoadSideView { duration in
                                Task {
                                    await onboardingViewModel.playWaveHaptic(duration: duration)
                                }
                            }
                        case .two:
                            PhoneWithWave(onSoftImpact: {
                                await onboardingViewModel.requestSoftImpact()
                            })
                        case .three: Effect3D(
                                symbols: [
                                    "alarm.fill",
                                    "location.fill",
                                    "bell.fill",
                                ],
                                symbolFont: .system(
                                    size: LayoutConstants.FontSize.title1
                                ),
                                tint: ColorConstants.foreground
                            )
                        case .four: EmptyView()
                        case .five: EmptyView()
                        }
                    }
                    .frame(height: 300)
                }

                Spacer()

                ButtonOverviewNext(text: buttonTitle) {
                    Task {
                        await onboardingViewModel.requestLightImpact()
                    }
                    next()
                }
            }
        }
        .preferredColorScheme(.light)
    }

    var buttonTitle: String {
        switch selectedPage {
        case .zero: String(localized: "Start")      // 👈 Кнопка для пустой страницы
        case .one: String(localized: "Get Started")
        case .two: String(localized: "Learn More")
        case .three: String(localized: "Next")
        case .four: String(localized: "Great")
        case .five: String(localized: "I’m Ready")
        }
    }

    func next() {
        withAnimation(.easeInOut) {
            switch selectedPage {
            case .zero: selectedPage = .one          // 👈 Переход с нулевой на первую
            case .one: selectedPage = .two
            case .two: selectedPage = .three
            case .three: selectedPage = .four
            case .four: selectedPage = .five
            case .five: untitledVM.trueOverViewShown()
            }
        }

        if selectedPage == .four {
            requestAll()
        } else if selectedPage == .five {
            reolacateAll()
        }
    }
    
    // 👈 Новая пустая страница
    var emptyPage: some View {
        VStack(spacing: 20) {
            // Можно добавить логотип или просто оставить пустым
            Image(systemName: "hand.wave.fill")
                .font(.system(size: 80))
                .foregroundStyle(ColorConstants.foreground)
                .opacity(0.3)
        }
    }

    /// Example pages in English
    var firstPage: some View {
        TitleLabelOverviewText(String(localized: .tiredOfMissingYourStops))
    }

    var secondPage: some View {
        TitleLabelOverviewText(String(localized: .withUsYoullNeverOversleep))
    }

    var thirdPage: some View {
        TitleLabelOverviewText(String(localized: .weNeedPermissionToAccessUsage))
    }

    var fourthPage: some View {
        TitleLabelOverviewText(String(localized: .perfectNowOnlyALittleRemains))
    }

    var fifthPage: some View {
        TitleLabelOverviewText(String(localized: .thereIsNoTutorial))
    }

    func requestAll() {
        onboardingViewModel.requestAllPermissions()
    }

    func reolacateAll() {}
}

struct TitleLabelOverviewText: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.system(size: LayoutConstants.FontSize.title1))
            .foregroundStyle(ColorConstants.foreground)
            .bold()
            .multilineTextAlignment(.center)
    }
}

struct Effect3D: View {
    var symbols: [String]
    var symbolFont: Font
    var tint: Color

    @State private var trim: CGFloat = 0
    @State private var rotation: CGFloat = 0
    @State private var isAnimating = false

    var body: some View {
        Rectangle()
            .foregroundStyle(.clear)
            .modifier(
                Effect3DModifier(
                    symbols: symbols,
                    symbolFont: symbolFont,
                    tint: tint,
                    trim: trim,
                    rotation: rotation
                )
            )
            .task {
                guard !isAnimating else { return }
                isAnimating = true

                try? await Task.sleep(for: .seconds(0.1))
                withAnimation(.easeInOut(duration: 1.5)) {
                    trim = 1
                }

                try? await Task.sleep(for: .seconds(0.5))
                withAnimation(
                    .linear(duration: 15)
                        .repeatForever(autoreverses: false)
                ) {
                    rotation = 360
                }
            }
    }
}


private struct Effect3DModifier: AnimatableModifier {
    let symbols: [String]
    let symbolFont: Font
    let tint: Color

    var trim: CGFloat
    var rotation: CGFloat

    /// 👇 ЯВНО объявляем, что анимируется
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(trim, rotation) }
        set {
            trim = newValue.first
            rotation = newValue.second
        }
    }

    func body(content: Content) -> some View {
        content.overlay {
            GeometryReader { geo in
                let size = geo.size
                let circleSize = min(size.width, size.height)
                let dashLength = (CGFloat.pi * circleSize) / CGFloat(symbols.count * 2)
                let dashPhase = -dashLength / 2
                let strokeStyle = StrokeStyle(
                    lineWidth: 3,
                    dash: [dashLength],
                    dashPhase: dashPhase
                )

                ZStack {
                    Circle()
                        .trim(from: 0, to: trim)
                        .stroke(tint, style: strokeStyle)
                        .rotationEffect(.init(degrees: rotation))
                        .rotation3DEffect(
                            .init(degrees: 62),
                            axis: (x: 1, y: 0, z: 0),
                            anchor: .center,
                            perspective: 0
                        )
                        .rotation3DEffect(
                            .init(degrees: -20),
                            axis: (x: 0, y: 0, z: 1),
                            anchor: .center,
                            perspective: 0
                        )

                    ZStack {
                        ForEach(symbols.indices, id: \.self) { index in
                            let radius = circleSize / 2
                            let angle = (CGFloat(index) / CGFloat(symbols.count)) * 360 + rotation
                            let angleInRadians = (CGFloat.pi * angle) / 180
                            // calculate x & y offset for the angels manually
                            let rotation3D = cos((62 * CGFloat.pi) / 180)
                            let x = cos(angleInRadians) * radius
                            let y = sin(angleInRadians) * radius * rotation3D

                            // animate the trim value -> apply scale effect to each element in order
                            let start = CGFloat(index) / CGFloat(symbols.count)
                            let end = CGFloat(index + 1) / CGFloat(symbols.count)
                            let scaleProgress = max(min((trim - start) / (end - start), 1), 0)

                            // individual icon rotation
//                            let iconRotation = rotation + CGFloat(index * 10)

                            Image(systemName: symbols[index])
                                .font(symbolFont)
                                .foregroundStyle(tint)
                                // adding drop shadows
                                .shadow(color: tint.opacity(0.15), radius: 2, x: 1, y: 2)
                                .shadow(color: tint.opacity(0.1), radius: 8, x: 4, y: 8)
                                .scaleEffect(scaleProgress)
                                /// individual icon rotation
//                                .rotationEffect(.init(degrees: iconRotation))
//                                .rotation3DEffect(
//                                    .init(degrees: iconRotation),
//                                    axis: (x: 0, y: 1, z: 0),
//                                    anchor: .center,
//                                    perspective: 0
//                                )
                                /// reverse Z rotation for the icons
                                .rotationEffect(.init(degrees: 20))
                                .offset(x: x, y: y)
                        }
                    }
                    // z is typical rotation so safe to apply it to icons
                    .rotationEffect(.init(degrees: -20))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct PhoneWithWave: View {
    @State private var animate = false
    @State private var shake = false
    @State private var hapticLoopTask: Task<Void, Never>?

    let phone: String = "Phone"
    let onSoftImpact: () async -> Void

    var body: some View {
        ZStack {
            SideWaves(direction: .left, animate: animate)
            SideWaves(direction: .right, animate: animate)

            Image(phone)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 200)
                .rotationEffect(.degrees(shake ? 2 : -2))
                .animation(
                    .easeInOut(duration: 0.08)
                        .repeatForever(autoreverses: true),
                    value: shake
                )
        }
        .onAppear {
            animate = true
            shake = true
            hapticLoopTask = Task {
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 80_000_000)
                    await onSoftImpact()
                }
            }
        }
        .onDisappear {
            hapticLoopTask?.cancel()
            hapticLoopTask = nil
        }
    }
}

enum WaveDirection {
    case left, right
}

struct SideWaves: View {
    let direction: WaveDirection
    let animate: Bool

    var body: some View {
        ZStack {
            ForEach(0 ..< 3) { i in
                Circle()
                    .trim(from: 0.25, to: 0.75)
                    .stroke(Color.blue.opacity(0.6), lineWidth: 2)
                    .frame(width: 80, height: 80)
                    .scaleEffect(animate ? 2.2 : 0.3)
                    .opacity(animate ? 0 : 1)
                    .rotationEffect(direction == .left ? .degrees(0) : .degrees(180))
                    .offset(x: direction == .left ? -70 : 70)
                    .animation(
                        .easeOut(duration: 0.7)
                            .repeatForever(autoreverses: false)
                            .delay(Double(i) * 0.2),
                        value: animate
                    )
            }
        }
    }
}
