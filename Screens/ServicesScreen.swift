import SwiftUI

// MARK: - Сервіси: пошук + сітка плиток з чорними кружками

struct ServicesScreen: View {
    @EnvironmentObject private var store: ProfileStore
    @State private var query = ""
    @State private var alertText: String? = nil
    @State private var showDriverSheet = false
    @State private var showFunSheet = false

    struct Service: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        // nil -> алерт «фейк»; .driver / .fun -> реальний під-екран
        var sub: SubScreen? = nil

        enum SubScreen { case driver, fun }
    }

    private let services: [Service] = [
        .init(icon: "bell.fill", title: "Допомога армії"),
        .init(icon: "bolt.fill", title: "Незламність"),
        .init(icon: "creditcard.fill", title: "Дія.Картка"),
        .init(icon: "chart.line.uptrend.xyaxis", title: "Військові облігації"),
        .init(icon: "paperplane.fill", title: "Лінія дронів"),
        .init(icon: "barcode", title: "Національний кешбек"),
        .init(icon: "arrow.left.arrow.right", title: "Перенесення номера"),
        .init(icon: "wrench.and.screwdriver.fill", title: "еВідновлення"),
        .init(icon: "doc.badge.clock", title: "Міжнародний Реєстр збитків"),
        .init(icon: "dumbbell.fill", title: "Ветеранський спорт"),
        .init(icon: "car.fill", title: "Водіеві", sub: .driver),
        .init(icon: "house.fill", title: "Місце проживання"),
        .init(icon: "scope", title: "Чатбот єВорог"),
        .init(icon: "doc.text.fill", title: "Податкові послуги"),
        .init(icon: "hands.and.sparkles.fill", title: "Допомога від держави"),
        .init(icon: "person.3.fill", title: "Сім'я"),
        .init(icon: "cube.fill", title: "Послуги для ВПО"),
        .init(icon: "briefcase.fill", title: "Підприємцю"),
        .init(icon: "hands.clap.fill", title: "Допомога по безробіттю"),
        .init(icon: "necktie", title: "Обрій.Робота"),
        .init(icon: "scalemass.fill", title: "Судові послуги"),
        .init(icon: "house.and.fill", title: "еОселя"),
        .init(icon: "exclamationmark.octagon.fill", title: "Виконавчі провадження"),
        .init(icon: "doc.fill", title: "Довідки та витяги"),
        .init(icon: "gamecontroller.fill", title: "Розваги", sub: .fun),
        .init(icon: "creditcard.and.123", title: "Повернення вкладів"),
    ]

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Сервіси")
                    .font(Diia.screenTitle)
                    .foregroundColor(Diia.ink)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Diia.muted)
                TextField("Пошук", text: $query)
                    .font(.system(size: 16))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(Capsule())
            .padding(.horizontal, 20)
            .padding(.top, 12)

            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filtered) { s in
                        Button {
                            open(s)
                        } label: {
                            VStack(alignment: .leading, spacing: 26) {
                                ZStack {
                                    Circle().fill(Diia.ink)
                                        .frame(width: 44, height: 44)
                                    Image(systemName: s.icon)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                Text(s.title)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Diia.ink)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.55))
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .background(Diia.bgGradient.ignoresSafeArea())
        .sheet(isPresented: $showDriverSheet) { DriverServicesSheet() }
        .sheet(isPresented: $showFunSheet) { FunServicesSheet() }
        .alert(alertText ?? "", isPresented: Binding(
            get: { alertText != nil },
            set: { if !$0 { alertText = nil } }
        )) {
            Button("Зрозуміло") { alertText = nil }
        }
    }

    private var filtered: [Service] {
        query.isEmpty ? services : services.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    private func open(_ s: Service) {
        switch s.sub {
        case .driver: showDriverSheet = true
        case .fun: showFunSheet = true
        case .none:
            alertText = "«\(s.title)» не працює у фейковій версії. Це жартівливий застосунок."
        }
    }
}

// MARK: - Під-екран «Водіеві»

struct DriverServicesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var alertText: String? = nil

    private let rows = [
        "Європротокол", "Штрафи ПДР", "Шеринг авто",
        "Заміна посвідчення водія", "Продати транспортний засіб", "Заміна техпаспорта"
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Diia.ink)
                }
                Text("Водіеві")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Diia.ink)
                    .padding(.leading, 14)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)

            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { i, row in
                    Button {
                        alertText = "«\(row)» не працює у фейковій версії."
                    } label: {
                        HStack {
                            Text(row)
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(Diia.ink)
                            Spacer()
                            Circle().fill(Diia.ink).frame(width: 32, height: 32)
                                .overlay(Image(systemName: "arrow.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white))
                        }
                        .padding(.vertical, 16)
                        .overlay(alignment: .bottom) {
                            if i < rows.count - 1 {
                                Rectangle().fill(Diia.separator).frame(height: 1)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 20)
            .padding(.top, 18)

            Spacer()
        }
        .background(Diia.bgGradient.ignoresSafeArea())
        .alert(alertText ?? "", isPresented: Binding(
            get: { alertText != nil },
            set: { if !$0 { alertText = nil } }
        )) {
            Button("Зрозуміло") { alertText = nil }
        }
    }
}

// MARK: - Під-екран «Розваги»

struct FunServicesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var alertText: String? = nil

    private let rows = ["Дія.TV", "Дія.Радіо"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Diia.ink)
                }
                Text("Розваги")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Diia.ink)
                    .padding(.leading, 14)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)

            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { i, row in
                    Button {
                        alertText = "«\(row)» не працює у фейковій версії."
                    } label: {
                        HStack {
                            Text(row)
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(Diia.ink)
                            Spacer()
                            Circle().fill(Diia.ink).frame(width: 32, height: 32)
                                .overlay(Image(systemName: "arrow.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white))
                        }
                        .padding(.vertical, 16)
                        .overlay(alignment: .bottom) {
                            if i < rows.count - 1 {
                                Rectangle().fill(Diia.separator).frame(height: 1)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 20)
            .padding(.top, 18)

            Spacer()
        }
        .background(Diia.bgGradient.ignoresSafeArea())
        .alert(alertText ?? "", isPresented: Binding(
            get: { alertText != nil },
            set: { if !$0 { alertText = nil } }
        )) {
            Button("Зрозуміло") { alertText = nil }
        }
    }
}
