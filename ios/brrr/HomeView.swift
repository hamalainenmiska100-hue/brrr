import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var notifications: NotificationManager
    @EnvironmentObject private var api: APIClient
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color.black, Color(red: 0.09, green: 0.07, blue: 0.16)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        topBar
                        hero
                        CodeCard(command: api.curlCommand) { Task { try? await api.sendTestNotification() } }
                        HStack(spacing: 12) {
                            PrimaryActionButton(title: "Copy", systemImage: "doc.on.doc.fill", tint: .green) {
                                UIPasteboard.general.string = api.curlCommand
                            }
                            SecondaryActionButton(title: "Share", systemImage: "square.and.arrow.up") {
                                let av = UIActivityViewController(activityItems: [api.curlCommand], applicationActivities: nil)
                                UIApplication.shared.connectedScenes
                                    .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                                    .first?.rootViewController?.present(av, animated: true)
                            }
                        }
                        DocsButton(urlString: "https://push.vymedia.xyz")
                        NotificationStatusView()
                        StatusBanner()
                    }.padding(20)
                }
            }
            .task {
                notifications.checkAuthorizationStatus()
                if notifications.permissionState != .granted { notifications.requestPermissionAndRegister() }
            }
            .sheet(isPresented: $showingSettings) { SettingsView() }
        }
    }

    var topBar: some View {
        HStack {
            GlassCircleButton(systemImage: "arrow.clockwise") { notifications.checkAuthorizationStatus() }
            Spacer()
            GlassCircleButton(systemImage: notifications.permissionState == .granted ? "bell.fill" : "bell.slash.fill",
                              badge: notifications.permissionState == .granted ? nil : "!") {}
            GlassCircleButton(systemImage: "gearshape.fill") { showingSettings = true }
        }
    }

    var hero: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome\nto")
                .font(.system(size: 56, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Text("brrr")
                .font(.system(size: 64, weight: .black, design: .rounded))
                .foregroundStyle(Color.purple)
                .shadow(color: .purple.opacity(0.7), radius: 20)
            Text("Make this device go brrr by sending a notification with the API call below.")
                .foregroundStyle(.gray)
                .font(.headline)
        }
    }
}
