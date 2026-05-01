import Foundation

@MainActor
final class APIClient: ObservableObject {
    static let shared = APIClient()
    static let defaultWorkerURL = "https://push.vymedia.xyz"

    @Published var workerURLString: String {
        didSet { UserDefaults.standard.set(workerURLString, forKey: "workerURL") }
    }

    private init() {
        self.workerURLString = UserDefaults.standard.string(forKey: "workerURL") ?? Self.defaultWorkerURL
    }

    private var baseURL: URL {
        URL(string: workerURLString) ?? URL(string: Self.defaultWorkerURL)!
    }

    func registerDeviceToken(token: String, deviceId: String) async throws {
        let endpoint = baseURL.appending(path: "register")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["deviceId": deviceId, "token": token])
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    func sendTestNotification(title: String = "brrr", body: String = "Hello from brrr app! 🚀") async throws {
        var request = URLRequest(url: baseURL.appending(path: "send"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["title": title, "body": body])
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    func healthCheck() async throws -> Bool {
        let (_, response) = try await URLSession.shared.data(from: baseURL.appending(path: "health"))
        guard let http = response as? HTTPURLResponse else { return false }
        return (200...299).contains(http.statusCode)
    }

    var curlCommand: String {
        "curl -X POST \(workerURLString) \\\n  -d 'Hello world! 🚀'"
    }
}
