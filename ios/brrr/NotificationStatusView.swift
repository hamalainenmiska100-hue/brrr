import SwiftUI

struct NotificationStatusView: View {
    @EnvironmentObject private var manager: NotificationManager
    @EnvironmentObject private var api: APIClient

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notification Status").font(.headline)
            Text("Permission: \(manager.permissionState.rawValue)")
            Text("APNs: \(manager.apnsState.rawValue)")
            Text("Worker registration: \(manager.registrationMessage)")
            Text("Worker URL: \(api.workerURLString)")
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
