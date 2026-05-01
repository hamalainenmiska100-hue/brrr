import SwiftUI

struct GlassCircleButton: View {
    let systemImage: String
    var badge: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
                if let badge {
                    Text(badge)
                        .font(.caption2.bold())
                        .padding(4)
                        .background(.red, in: Circle())
                        .offset(x: 4, y: -4)
                }
            }
        }
    }
}
