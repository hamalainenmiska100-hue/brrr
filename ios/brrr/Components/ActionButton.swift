import SwiftUI

struct PrimaryActionButton: View {
    let title: String
    let systemImage: String
    var tint: Color = .green
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(tint, in: RoundedRectangle(cornerRadius: 18))
                .foregroundStyle(.black)
        }
    }
}

struct SecondaryActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.white, in: RoundedRectangle(cornerRadius: 18))
                .foregroundStyle(.black)
        }
    }
}

struct DocsButton: View {
    let urlString: String

    var body: some View {
        Link(destination: URL(string: urlString)!) {
            Label("Read docs", systemImage: "book.pages")
                .font(.subheadline.bold())
                .foregroundStyle(.white)
        }
    }
}
