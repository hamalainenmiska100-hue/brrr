import SwiftUI

@main
struct brrrApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var apiClient = APIClient.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationManager)
                .environmentObject(apiClient)
        }
    }
}
