import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var api: APIClient
    @State private var workerURL = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Worker URL") {
                    TextField("https://push.vymedia.xyz", text: $workerURL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                    Button("Use default") { workerURL = APIClient.defaultWorkerURL }
                    Button("Save") { api.workerURLString = workerURL.trimmingCharacters(in: .whitespacesAndNewlines) }
                }
                Section("Docs") {
                    Link("Read docs", destination: URL(string: "https://push.vymedia.xyz")!)
                }
            }
            .navigationTitle("Settings")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
            .onAppear { workerURL = api.workerURLString }
        }
    }
}
