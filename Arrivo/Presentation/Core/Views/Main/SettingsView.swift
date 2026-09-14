import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            ColorConstants.background.ignoresSafeArea()
            List {
                Group {
                    // MARK: - App Settings

                    Section(header: Text("App")) {
                        NavigationLink {
                            Text("Language Settings Screen")
                        } label: {
                            Label("App Language", systemImage: "globe")
                        }

                        NavigationLink {
                            Text("Soon")
                        } label: {
                            Label("How to Add Widget", systemImage: "square.grid.2x2")
                        }
                    }

                    // MARK: - Support

                    Section(header: Text("Support")) {
                        NavigationLink {
                            Text("Soon")
                        } label: {
                            Label("Report a Problem", systemImage: "exclamationmark.bubble")
                        }

                        NavigationLink {
                            Text("Soon")
                        } label: {
                            Label("Bus Stop Location Error", systemImage: "mappin.and.ellipse")
                        }

                        NavigationLink {
                            Text("Soon")
                        } label: {
                            Label("Bus Stop Name Error", systemImage: "pencil")
                        }
                    }

                    // MARK: - Legal

                    Section(header: Text("Legal")) {
                        Link(destination: URL(string: "https://arrivoprivacyandterms.vercel.app/privacy.html")!) {
                            Label("Privacy Policy", systemImage: "lock.shield")
                        }
                        Link(destination: URL(string: "https://arrivoprivacyandterms.vercel.app/terms.html")!) {
                            Label("Terms and Conditions", systemImage: "doc.text")
                        }
                    }
                }
                .listRowBackground(ColorConstants.background)
            }
            .listStyle(.plain)
            .ifAvailableiOS26OrLower { $0.toolbarBackground(ColorConstants.background, for: .navigationBar) }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(TabEnum.settings.displayName)
                        .foregroundStyle(ColorConstants.foreground)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
