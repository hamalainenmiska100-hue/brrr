import SwiftUI

struct StatusBanner: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "heart.fill").foregroundStyle(.pink)
            VStack(alignment: .leading) {
                Text("Your free trial ended 9. Apr 2026.")
                Text("Subscribe to keep the pushes coming.").foregroundStyle(.gray)
            }.font(.footnote.bold())
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
