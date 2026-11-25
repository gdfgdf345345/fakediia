import SwiftUI
import PhotosUI

// MARK: - Меню 4.38: секції списків, версія, «Вийти», під-екрани

struct MenuScreen: View {
    @EnvironmentObject private var store: ProfileStore
    @EnvironmentObject private var toast: ToastCenter
    @State private var showQR = false
    @State private var page = 0
    @State private var showInbox = false
    @State private var showSignHistory = false
    @State private var showSettings = false
    @State private var showDevices = false
    @State private var alertText: String? = nil
    @State private var confirmExit = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Меню")
                        .font(Diia.screenTitle)
                        .foregroundColor(Diia.ink)
                    Spacer()
                    Button { showQR = true } label: {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 26, weight: .light))
                            .foregroundColor(Diia.ink)
                    }
                }
                Text("Версія Дії: 4.38.5.3025")
                    .font(.system(size: 15))
                    .foregroundColor(Diia.muted)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    MenuSection(rows: [
                        MenuRow(icon: "envelope", title: "Повідомлення", badge: true) { showInbox = true }
                    ])

                    MenuSection(rows: [
                        MenuRow(icon: "key", title: "Дія.Підпис") {
                            alertText = "Дія.Підпис не працює у фейковій версії."
                        },
                        MenuRow(icon: "doc.on.doc", title: "Історія підписань") { showSignHistory = true }
                    ])

                    MenuSection(rows: [
                        MenuRow(icon: "gearshape", title: "Налаштування") { showSettings = true },
                        MenuRow(icon: "arrow.triangle.2.circlepath", title: "Оновити застосунок") {
                            alertText = "Вже найсвіжіша. Це фейк, оновлювати нема чого."
                        },
                        MenuRow(icon: "iphone.gen2", title: "Підключені пристрої") { showDevices = true }
                    ])

                    MenuSection(rows: [
                        MenuRow(icon: "bubble.left", title: "Служба підтримки") {
                            alertText = "Підтримка фейкової Дії — це ти сам у дзеркалі."
                        },
                        MenuRow(icon: "doc.on.doc.fill", title: "Копіювати номер пристрою") {
                            UIPasteboard.general.string = "FAKE-DIIA-\(store.profile.name.isEmpty ? "0000" : "80085")"
                            toast.show("Номер пристрою скопійовано")
                        },
                        MenuRow(icon: "questionmark.circle", title: "Питання та відповіді") {
                            alertText = "Питання: навіщо це все? Відповідь: щоб дивитись на обличчя."
                        }
                    ])

                    Button {
                        confirmExit = true
                    } label: {
                        Text("Вийти")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(Capsule().fill(Diia.ink))
                    }
                    .buttonStyle(.plain)

                    Text("Повідомлення про обробку персональних даних")
                        .font(.system(size: 14))
                        .underline()
                        .foregroundColor(Diia.ink)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .background(Diia.bgGradient.ignoresSafeArea())
        .sheet(isPresented: $showQR) { QRPickerSheet(page: $page) }
        .sheet(isPresented: $showInbox) { InboxSheet() }
        .sheet(isPresented: $showSignHistory) { SignHistorySheet() }
        .sheet(isPresented: $showSettings) { SettingsEditorSheet() }
        .sheet(isPresented: $showDevices) { DevicesSheet() }
        .confirmationDialog("Вийти?", isPresented: $confirmExit, titleVisibility: .visible) {
            Button("Вийти", role: .destructive) {
                // Це фейк: виходити нікуди, але показати тост — красиво
                // Тост через environment подається далі в overlay MainTabView
                showFakeLogoutToast()
            }
            Button("Скасувати", role: .cancel) {}
        } message: {
            Text("З фейкової Дії можна вийти лише психологічно.")
        }
        .alert(alertText ?? "", isPresented: Binding(
            get: { alertText != nil },
            set: { if !$0 { alertText = nil } }
        )) {
            Button("Зрозуміло") { alertText = nil }
        }
    }

    private func showFakeLogoutToast() {
        toast.show("Виходу з фейку не існує. Але зусилля засчитано.")
    }
}

// MARK: - Секція меню

struct MenuSection: View {
    let rows: [MenuRow]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { i, row in
                row
                    .padding(.vertical, 16)
                    .overlay(alignment: .bottom) {
                        if i < rows.count - 1 {
                            Rectangle().fill(Diia.separator).frame(height: 1)
                                .padding(.horizontal, 2)
                        }
                    }
            }
        }
        .padding(.horizontal, 18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    var badge: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Diia.ink)
                    if badge {
                        Circle().fill(.red).frame(width: 9, height: 9)
                            .offset(x: 5, y: -4)
                    }
                }
                .frame(width: 26)
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Diia.ink)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Повідомлення (sheet)

struct InboxSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let items: [(date: String, read: Bool)] = [
        ("08 листопада 2026 / 12:39", false),
        ("12 жовтня 2026 / 05:51", false),
        ("30 червня 2026 / 17:54", true),
        ("19 травня 2026 / 12:31", false)
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Diia.ink)
                }
                Text("Повідомлення")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Diia.ink)
                    .padding(.leading, 14)
                Spacer()
                ZStack {
                    Circle().fill(Diia.ink).frame(width: 34, height: 34)
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Зверніть увагу")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(item.read ? Diia.muted : Diia.ink)
                            Text("До вашої Дії підключено новий пристрій")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(item.read ? Diia.muted : Diia.ink)
                            Text(item.date)
                                .font(.system(size: 13))
                                .foregroundColor(Diia.muted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(Color.white.opacity(item.read ? 0.45 : 1))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .background(Diia.bgGradient.ignoresSafeArea())
    }
}

// MARK: - Історія підписань (sheet)

struct SignHistorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var segment = 2
    @State private var alertText: String? = nil

    private var entries: [(status: String, ok: Bool, date: String)] {
        [
            ("ВИКОНАНО", true, "08.11.2026 12:40"),
            ("ВІДМОВЛЕНО", false, "08.11.2026 12:36"),
            ("ВІДМОВЛЕНО", false, "08.11.2026 12:33"),
            ("ВИКОНАНО", true, "07.11.2026 10:02")
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Diia.ink)
                }
                Text("Історія підписань")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Diia.ink)
                    .padding(.leading, 14)
                Spacer()
                DotsButton(action: {
                    alertText = "У фейковій версії тут нічого немає."
                })
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    pill("Організації", index: 0)
                    pill("Підписання", index: 1)
                    pill("Копії документів", index: 2, badge: 6)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    ForEach(Array(entries.enumerated()), id: \.offset) { _, e in
                        VStack(alignment: .leading, spacing: 10) {
                            Capsule()
                                .fill(e.ok ? Color(hex: 0x8FF0A4) : Color(hex: 0xE4E4E8))
                                .overlay(
                                    Text(e.status)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(Diia.ink)
                                )
                                .frame(width: 110, height: 26)
                            Text("АТ \"БАНК АЛЬЯНС\"")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Diia.ink)
                            Text("Юридична адреса: Київська обл., Шевченківський р-н, м.Київ, Січових Стрільців, 50")
                                .font(.system(size: 14))
                                .foregroundColor(Diia.muted)
                            HStack {
                                Text(e.date)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Diia.ink)
                                Spacer()
                                Button {
                                    alertText = "Деталі підпису знаходяться в реальному Дії. Тут — тільки антураж."
                                } label: {
                                    Text("Детальніше")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 10)
                                        .background(Capsule().fill(Diia.ink))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.top, 4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
        }
        .background(Diia.bgGradient.ignoresSafeArea())
        .alert(alertText ?? "", isPresented: Binding(
            get: { alertText != nil },
            set: { if !$0 { alertText = nil } }
        )) {
            Button("Зрозуміло") { alertText = nil }
        }
    }

    private func pill(_ title: String, index: Int, badge: Int? = nil) -> some View {
        Button {
            segment = index
        } label: {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Diia.ink)
                if let badge {
                    Circle().fill(Diia.ink).frame(width: 22, height: 22)
                        .overlay(
                            Text("\(badge)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Capsule().fill(segment == index ? Color.white : Color.white.opacity(0.55)))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Підключені пристрої (sheet)

struct DevicesSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Diia.ink)
                }
                Text("Підключені пристрої")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Diia.ink)
                    .padding(.leading, 14)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)

            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "iphone.gen2")
                        .font(.system(size: 20))
                        .foregroundColor(Diia.ink)
                    Text("Цей iPhone")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Diia.ink)
                    Spacer()
                    Text("активний")
                        .font(.system(size: 14))
                        .foregroundColor(Diia.muted)
                }
                .padding(.vertical, 16)
            }
            .padding(.horizontal, 18)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 20)
            .padding(.top, 18)

            Spacer()
        }
        .background(Diia.bgGradient.ignoresSafeArea())
    }
}

// MARK: - Редактор даних (sheet «Налаштування»)

struct SettingsEditorSheet: View {
    @EnvironmentObject private var store: ProfileStore
    @Environment(\.dismiss) private var dismiss
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var confirmReset = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    Section("Фото") {
                        HStack {
                            PhotoSlot(size: CGSize(width: 76, height: 100), photo: store.photoImage)
                            Spacer()
                            PhotosPicker(selection: $photoItem, matching: .images) {
                                Text(store.photoImage == nil ? "Вибрати фото" : "Змінити фото")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Diia.ink)
                                    .clipShape(Capsule())
                            }
                            .onChange(of: photoItem) { _, item in
                                loadPhoto(item)
                            }
                            if store.photoImage != nil {
                                Button("Очистити") { store.clearPhoto() }
                                    .font(.system(size: 14))
                                    .foregroundColor(Diia.muted)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    Section("Власник документів") {
                        TextField("Прізвище", text: $store.profile.surname)
                        TextField("Ім'я", text: $store.profile.name)
                        TextField("По батькові", text: $store.profile.patronymic)
                        DatePicker(
                            "Дата народження",
                            selection: Binding(
                                get: { store.profile.birthDate ?? Calendar.current.date(from: .init(year: 2000, month: 1, day: 1))! },
                                set: { store.profile.birthDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                        Picker("Стать", selection: $store.profile.sex) {
                            ForEach(Sex.allCases) { s in
                                Text(s.rawValue).tag(s)
                            }
                        }
                    }

                    Section("Паспорт громадянина") {
                        TextField("Номер (9 цифр)", text: $store.profile.passport.number)
                            .keyboardType(.numberPad)
                        DatePicker(
                            "Дата видачі",
                            selection: Binding(
                                get: { store.profile.passport.issueDate ?? Date() },
                                set: { store.profile.passport.issueDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                        TextField("Ким виданий (ТЦЦ 7931)", text: $store.profile.passport.issuedBy)
                    }

                    Section("Посвідчення водія") {
                        TextField("Категорії (A, B)", text: $store.profile.driver.categories)
                        TextField("Номер (АБВ12345)", text: $store.profile.driver.number)
                            .textInputAutocapitalization(.characters)
                        DatePicker(
                            "Дійсний до",
                            selection: Binding(
                                get: { store.profile.driver.validUntil ?? Date() },
                                set: { store.profile.driver.validUntil = $0 }
                            ),
                            displayedComponents: .date
                        )
                        TextField("Ким виданий", text: $store.profile.driver.issuedBy)
                    }

                    Section("Картка платника податків") {
                        TextField("РНОКПП (10 цифр)", text: $store.profile.taxpayer.rnokpp)
                            .keyboardType(.numberPad)
                    }

                    Section("Студентський квиток") {
                        TextField("Заклад освіти", text: $store.profile.student.university)
                        Stepper(
                            "Курс: \(store.profile.student.course)",
                            value: Binding(
                                get: { store.profile.student.course },
                                set: { store.profile.student.course = $0 }
                            ),
                            in: 1...6
                        )
                        TextField("Номер", text: $store.profile.student.number)
                        DatePicker(
                            "Дійсний до",
                            selection: Binding(
                                get: { store.profile.student.validUntil ?? Date() },
                                set: { store.profile.student.validUntil = $0 }
                            ),
                            displayedComponents: .date
                        )
                    }

                    Section {
                        Button {
                            store.generateNumbers()
                        } label: {
                            Label("Згенерувати номери", systemImage: "dice")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Diia.ink)
                        }
                        Button(role: .destructive) {
                            confirmReset = true
                        } label: {
                            Label("Скинути все", systemImage: "trash")
                        }
                        .confirmationDialog(
                            "Скинути всі дані?",
                            isPresented: $confirmReset,
                            titleVisibility: .visible
                        ) {
                            Button("Скинути", role: .destructive) { store.reset() }
                            Button("Скасувати", role: .cancel) {}
                        } message: {
                            Text("Ім'я, фото та номери документів буде стерто.")
                        }
                    } footer: {
                        Text("Це жартівлива програма. Вона не є документом і не видає документи. Реальний QR-код містить лише текст, який ти сам і ввів.")
                    }
                }
            }
            .navigationTitle("Налаштування")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                }
            }
        }
    }

    private func loadPhoto(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task { @MainActor in
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else { return }
            let maxSide: CGFloat = 620
            let scale = min(1, maxSide / max(image.size.width, image.size.height))
            let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            let renderer = UIGraphicsImageRenderer(size: size)
            let scaled = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: size))
            }
            store.setPhoto(scaled)
            photoItem = nil
        }
    }
}
