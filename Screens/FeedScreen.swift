import SwiftUI

// MARK: - Стрічка: «Привіт, Ім'я», повідомлення, швидкі кнопки, промо

struct FeedScreen: View {
    @EnvironmentObject private var store: ProfileStore
    @State private var showQR = false
    @State private var page = 0
    @State private var alertText: String? = nil

    private let feedMessages = [
        "До вашої Дії підключено новий пристрій",
        "Дія.Підпис доступний у застосунку",
        "Оновлено дані у реєстрах",
        "З'явилися нові послуги для водіїв"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Привіт, \(firstName.isEmpty ? "друже" : firstName) 👋")
                    .font(Diia.screenTitle)
                    .foregroundColor(Diia.ink)
                    .padding(.top, 12)

                Text("Нові повідомлення")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Diia.ink)

                TabView(selection: $page) {
                    ForEach(0..<4) { i in
                        FeedMessageCard(text: feedMessages[i], date: Date().addingTimeInterval(Double(-i) * 86_400))
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 150)

                HStack(spacing: 7) {
                    ForEach(0..<4) { i in
                        Circle()
                            .fill(page == i ? Diia.ink : .white.opacity(0.7))
                            .frame(width: 7, height: 7)
                            .onTapGesture { withAnimation { page = i } }
                    }
                }
                .frame(maxWidth: .infinity)

                Button {
                    alertText = "«Незламність» не працює у фейковій версії. Це жартівливий застосунок."
                } label: {
                    PromoCard()
                }
                .buttonStyle(.plain)

                HStack(spacing: 18) {
                    QuickTile(systemName: "qrcode.viewfinder", title: "Дія Сканер") {
                        alertText = "Сканер не працює у фейковій версії."
                    }
                    QuickTile(systemName: "chart.line.uptrend.xyaxis", title: "Військові облігації") {
                        alertText = "Облігації не працюють у фейковій версії."
                    }
                    QuickTile(systemName: "antenna.radiowaves.left.and.right.slash", title: "Відсутній зв'язок") {
                        alertText = "Зв'язок якраз є. Фейк же."
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Diia.bgGradient.ignoresSafeArea())
        .sheet(isPresented: $showQR) { QRPickerSheet(page: $page) }
        .alert(alertText ?? "", isPresented: Binding(
            get: { alertText != nil },
            set: { if !$0 { alertText = nil } }
        )) {
            Button("Зрозуміло") { alertText = nil }
        }
    }

    private var firstName: String {
        store.profile.name
    }
}

/// Біла картка повідомлення у стрічці.
struct FeedMessageCard: View {
    let text: String
    let date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Зверніть увагу")
                .font(.system(size: 15))
                .foregroundColor(Diia.muted)
            Text(text)
                .font(.system(size: 19, weight: .semibold))
                .foregroundColor(Diia.ink)
            Text(date.formatted(Diia.longDateFormatter))
                .font(.system(size: 13))
                .foregroundColor(Diia.muted)
            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(maxHeight: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

/// Промо-картка «Незламність» з трьома кольоровими кружками.
struct PromoCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Незламність")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Diia.ink)
            Text("Мапа укриттів, Пунктів незламності та відділень Power Banking. Заява про відсутній зв'язок.")
                .font(.system(size: 15))
                .foregroundColor(Diia.ink.opacity(0.8))
            HStack {
                ZStack { Circle().fill(Diia.stripeYellow); Image(systemName: "bolt.fill").font(.system(size: 13, weight: .bold)) }
                    .frame(width: 30, height: 30)
                ZStack { Circle().fill(Color(hex: 0x2E6BE6)); Image(systemName: "shield.fill").font(.system(size: 13)) }
                    .frame(width: 30, height: 30)
                    .offset(x: -8)
                ZStack { Circle().fill(Color(hex: 0x2E8B44)); Image(systemName: "building.columns.fill").font(.system(size: 12)) }
                    .frame(width: 30, height: 30)
                    .offset(x: -16)
                Spacer()
                Circle().fill(Diia.ink).frame(width: 34, height: 34)
                    .overlay(Image(systemName: "arrow.right").font(.system(size: 14, weight: .bold)).foregroundColor(.white))
            }
        }
        .padding(18)
        .diiaGlass(radius: 24)
    }
}

/// Чорна скруглена кнопка швидкої дії.
struct QuickTile: View {
    let systemName: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Diia.ink)
                        .frame(width: 66, height: 66)
                    Image(systemName: systemName)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                }
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Diia.ink)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(.plain)
    }
}
