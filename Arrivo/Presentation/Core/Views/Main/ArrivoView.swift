import SwiftUI

struct ArrivoView: View {
    @EnvironmentObject private var mapVM: MapViewModel
    var body: some View {
        ZStack {
            ColorConstants.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    headerSection

                    activitySection

                    // supportSection
                }
                .padding(LayoutConstants.Padding.screen)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Arrivo")
                    .foregroundStyle(ColorConstants.foreground)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Sections

private extension ArrivoView {
    var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "bus.fill")
                .font(.system(size: 48))
                .foregroundStyle(ColorConstants.foreground)
                .padding()
                .background(ColorConstants.background.opacity(0.6))
                .clipShape(Circle())

            Text("Arrivo")
                .font(.title2)
                .foregroundStyle(ColorConstants.foreground)

            Text("Public Transport Assistant")
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(cardBackground)
    }

    var supportSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Support")

            ArrivoCard(title: "Donate", icon: "heart.fill")
            ArrivoCard(title: "My Works", icon: "hammer.fill")
            ArrivoCard(title: "Contact Me", icon: "paperplane.fill")
        }
        .padding()
        .background(cardBackground)
    }

    var activitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle(String(localized: "Activity"))

            ArrivoCard(title: String(localized: "Current Active"), icon: "bolt.fill")
                .onTapGesture {
                    mapVM.activeSheet = .startedMonitorings
                }
            ArrivoCard(title: String(localized: "History"), icon: "clock.fill")
                .onTapGesture {
                    mapVM.activeSheet = .oldMonitorings
                }
        }
        .padding()
        .background(cardBackground)
    }

    func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(ColorConstants.foreground)
    }

    var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(ColorConstants.background.opacity(0.7))
    }
}

// MARK: - Card

struct ArrivoCard: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(ColorConstants.foreground)
                .frame(width: 36, height: 36)
                .background(ColorConstants.background.opacity(0.6))
                .clipShape(Circle())

            Text(title)
                .foregroundStyle(ColorConstants.foreground)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ColorConstants.background.opacity(0.5))
        )
    }
}
