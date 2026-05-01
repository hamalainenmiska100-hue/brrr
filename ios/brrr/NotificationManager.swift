import Foundation
import UserNotifications
import UIKit

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    enum PermissionState: String {
        case granted, denied, notDetermined
    }

    enum APNsState: String {
        case registered, missing, failed
    }

    @Published var permissionState: PermissionState = .notDetermined
    @Published var apnsState: APNsState = .missing
    @Published var deviceToken: String = ""
    @Published var registrationMessage: String = "Pending"

    private init() {}

    func requestPermissionAndRegister() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            Task { @MainActor in
                self.permissionState = granted ? .granted : .denied
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral: self.permissionState = .granted
                case .denied: self.permissionState = .denied
                default: self.permissionState = .notDetermined
                }
            }
        }
    }

    func handleDeviceToken(_ tokenData: Data) {
        let token = tokenData.map { String(format: "%02.2hhx", $0) }.joined()
        deviceToken = token
        apnsState = .registered

        Task {
            do {
                try await APIClient.shared.registerDeviceToken(token: token, deviceId: "default")
                await MainActor.run { self.registrationMessage = "Registered with Worker" }
            } catch {
                await MainActor.run { self.registrationMessage = "Worker registration failed: \(error.localizedDescription)" }
            }
        }
    }

    func handleRegistrationError(_ error: Error) {
        apnsState = .failed
        registrationMessage = "APNs registration failed: \(error.localizedDescription)"
    }
}
