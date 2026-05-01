import SwiftUI

struct CodeCard: View {
    let command: String
    let sendTest: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Bash").font(.caption.bold()).foregroundStyle(.gray)
                Spacer()
                Button(action: sendTest) {
                    Label("Send Test", systemImage: "paperplane.fill")
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.15), in: Capsule())
                }
            }
            Text(command)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.white)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.2), lineWidth: 1))
    }
}
