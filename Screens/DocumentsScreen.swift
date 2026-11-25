import SwiftUI

/// Документи: карусель glass-карточок з peek по краях, зелена смуга, копіювання номера.
struct DocumentsScreen: View {
    @EnvironmentObject private var store: ProfileStore
    @State private var page = 0
    @State private var showQR = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Документи")
                    .font(Diia.screenTitle)
                    .foregroundColor(Diia.ink)
                Spacer()
                Button { showQR = true } label: {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 26, weight: .light))
                        .foregroundColor(Diia.ink)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            TabView(selection: $page) {
                ForEach(DocKind.allCases) { kind in
                    DocumentCard(kind: kind)
                        .tag(kind.rawValue)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding(.top, 18)

            HStack(spacing: 7) {
                ForEach(DocKind.allCases) { kind in
                    Circle()
                        .fill(page == kind.rawValue ? Diia.ink : .white.opacity(0.75))
                        .frame(width: 7, height: 7)
                        .onTapGesture { withAnimation { page = kind.rawValue } }
                }
            }
            .padding(.top, 16)

            Spacer(minLength: 8)
        }
        .background(Diia.bgGradient.ignoresSafeArea())
        .sheet(isPresented: $showQR) {
            QRPickerSheet(page: $page)
        }
    }
}

/// Аркуш QR з вибором документа.
struct QRPickerSheet: View {
    @EnvironmentObject private var store: ProfileStore
    @Environment(\.dismiss) private var dismiss
    @Binding var page: Int
    @State private var kind: DocKind = .passport

    var body: some View {
        VStack(spacing: 24) {
            Capsule()
                .fill(Diia.separator)
                .frame(width: 44, height: 5)
                .padding(.top, 10)

            Picker("Документ", selection: $kind) {
                ForEach(DocKind.allCases) { k in
                    Text(k.short).tag(k)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)

            QRCodeView(payload: store.qrPayload(for: kind), side: 230)

            Text(kind.title)
                .font(Diia.cardTitle)
                .foregroundColor(Diia.ink)

            Spacer()
        }
        .background(Diia.bgGradient.ignoresSafeArea())
        .presentationDetents([.height(470)])
        .onAppear { if let current = DocKind(rawValue: page) { kind = current } }
        .onChange(of: kind) { _, new in page = new.rawValue }
    }
}
