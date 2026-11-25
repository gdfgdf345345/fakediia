import SwiftUI

/// Окремий QR-аркуш для одного документа (з меню точок і з шапки).
struct QRSheet: View {
    @EnvironmentObject private var store: ProfileStore
    @Environment(\.dismiss) private var dismiss
    let kind: DocKind

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Diia.separator)
                .frame(width: 44, height: 5)
                .padding(.top, 10)

            Text(kind.title)
                .font(Diia.cardTitle)
                .foregroundColor(Diia.ink)
                .padding(.top, 6)

            QRCodeView(payload: store.qrPayload(for: kind), side: 230)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Diia.bgGradient.ignoresSafeArea())
        .presentationDetents([.height(430)])
    }
}

/// UIActivityViewController-обгортка для шарингу картинки.
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
