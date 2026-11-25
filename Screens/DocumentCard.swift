import SwiftUI

// MARK: - Glass-карточка документа (референс 4.38)

struct DocumentCard: View {
    @EnvironmentObject private var store: ProfileStore
    let kind: DocKind

    @State private var showActions = false
    @State private var showQR = false
    @State private var showShare = false
    @State private var rendered: UIImage? = nil

    var body: some View {
        card
            .padding(.horizontal, 24)
            .diiaGlass(radius: 28)
            .overlay(alignment: .bottom) {
                numberBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
            }
            .overlay(alignment: .bottom) {
                updateBand
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(y: -64)
            }
            .contentShape(Rectangle())
            .onTapGesture { showActions = true }
            .confirmationDialog(kind.title, isPresented: $showActions, titleVisibility: .visible) {
                Button("Показати QR-код") { showQR = true }
                Button("Поділитися зображенням") {
                    rendered = CardRenderer.snapshot(kind: kind, store: store)
                    showShare = rendered != nil
                }
                Button("Скасувати", role: .cancel) {}
            }
            .sheet(isPresented: $showQR) { QRSheet(kind: kind) }
            .sheet(isPresented: $showShare) {
                if let img = rendered { ShareSheet(items: [img]) }
            }
            .padding(.horizontal, 4)
    }

    @ViewBuilder
    private var card: some View {
        switch kind {
        case .passport: PassportCard(photo: store.photoImage)
        case .driver: DriverCard(photo: store.photoImage)
        case .taxpayer: TaxpayerCard()
        case .student: StudentCard(photo: store.photoImage)
        }
    }

    private var numberText: String {
        switch kind {
        case .passport: return store.profile.passport.number
        case .driver: return store.profile.driver.number
        case .taxpayer: return store.profile.taxpayer.rnokpp
        case .student: return store.profile.student.number
        }
    }

    private var numberLabel: String {
        switch kind {
        case .passport: return "Запис №"
        case .driver: return "Номер"
        case .taxpayer: return "РНОКПП"
        case .student: return "№"
        }
    }

    private var numberBar: some View {
        HStack(spacing: 10) {
            Text(display(numberText, fallback: "— — — — —"))
                .font(Diia.bigNumber)
                .foregroundColor(Diia.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Button {
                UIPasteboard.general.string = numberText
                // Тост покаже DocumentsScreen через store? Ні — копіювання без тосту тут простіше
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Diia.ink)
            }
            .opacity(numberText.isEmpty ? 0 : 1)
            Spacer()
            DotsButton(action: { showActions = true })
        }
    }

    private var updateBand: some View {
        Text("Документ оновлено о \((store.lastUpdated ?? Date()).formatted(Diia.docBandFormatter)) • Перевірено")
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(Diia.ink)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(
                Capsule().fill(Diia.updateBand)
                    .opacity(0.85)
            )
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, 16)
    }
}

/// Оффскрин-рендер картки в UIImage для поділитися.
@MainActor
enum CardRenderer {
    static func snapshot(kind: DocKind, store: ProfileStore) -> UIImage? {
        let view: AnyView = {
            switch kind {
            case .passport: return AnyView(PassportCard(photo: store.photoImage))
            case .driver: return AnyView(DriverCard(photo: store.photoImage))
            case .taxpayer: return AnyView(TaxpayerCard())
            case .student: return AnyView(StudentCard(photo: store.photoImage))
            }
        }()

        let framed = view
            .frame(width: 340, height: 400)
            .background(Diia.bgGradient)
            .diiaGlass(radius: 28)
        let renderer = ImageRenderer(content: framed)
        renderer.scale = 3.0
        return renderer.uiImage
    }
}

// MARK: - Паспорт

struct PassportCard: View {
    @EnvironmentObject private var store: ProfileStore
    var photo: UIImage?

    var body: some View {
        let p = store.profile
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text("ПАСПОРТ\nГРОМАДЯНИНА\nУКРАЇНИ")
                    .font(.system(size: 17, weight: .bold))
                    .lineSpacing(4)
                Spacer()
                Image("Tryzub")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 46)
                    .opacity(0.4)
            }
            .padding(.top, 24)

            Text(p.fioMultiline)
                .font(.system(size: 22, weight: .bold))
                .lineSpacing(4)
                .padding(.top, 14)

            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 9) {
                    field("Дата народження:", date(p.birthDate))
                    field("Дата видачі:", date(p.passport.issueDate))
                    field("Видав:", display(p.passport.issuedBy, fallback: "—"))
                }
                Spacer(minLength: 0)
                PhotoSlot(photo: photo)
            }
            .padding(.top, 16)

            Spacer(minLength: 56)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .foregroundColor(Diia.ink)
        .frame(height: 400)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Посвідчення водія

struct DriverCard: View {
    @EnvironmentObject private var store: ProfileStore
    var photo: UIImage?

    var body: some View {
        let p = store.profile
        VStack(alignment: .leading, spacing: 0) {
            DriverStripe()
                .frame(height: 12)
                .padding(.horizontal, -20)
                .padding(.top, -24)

            Text("Посвідчення водія")
                .font(Diia.cardTitle)
                .padding(.top, 22)

            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 9) {
                    field("Дата народження:", date(p.birthDate))
                    field("Категорії:", display(p.driver.categories, fallback: "A, B"))
                    field("Дійсний до:", date(p.driver.validUntil))
                }
                Spacer(minLength: 0)
                PhotoSlot(photo: photo)
            }
            .padding(.top, 14)

            Spacer(minLength: 56)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .foregroundColor(Diia.ink)
        .frame(height: 400)
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

/// Жовто-чорна похила смуга нового посвідчення.
struct DriverStripe: View {
    var body: some View {
        Canvas { ctx, size in
            let w: CGFloat = 30
            let lean: CGFloat = 16
            var x: CGFloat = -w
            var index = 0
            while x < size.width + w {
                var p = Path()
                p.move(to: CGPoint(x: x, y: size.height))
                p.addLine(to: CGPoint(x: x + lean, y: 0))
                p.addLine(to: CGPoint(x: x + lean + w, y: 0))
                p.addLine(to: CGPoint(x: x + w, y: size.height))
                p.closeSubpath()
                ctx.fill(p, with: .color(index.isMultiple(of: 2) ? Diia.stripeYellow : Diia.ink))
                x += w
                index += 1
            }
        }
        .clipped()
    }
}

// MARK: - Картка платника податків (РНОКПП)

struct TaxpayerCard: View {
    @EnvironmentObject private var store: ProfileStore

    var body: some View {
        let p = store.profile
        VStack(alignment: .leading, spacing: 0) {
            Text("Картка платника\nподатків")
                .font(.system(size: 22, weight: .bold))
                .lineSpacing(3)
                .padding(.top, 24)

            Text("РНОКПП")
                .font(.system(size: 20, weight: .bold))
                .padding(.top, 16)

            Text(p.fioCaps)
                .font(.system(size: 21, weight: .bold))
                .lineSpacing(5)
                .padding(.top, 14)

            field("Дата народження:", date(p.birthDate))
                .padding(.top, 14)

            Spacer(minLength: 56)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .foregroundColor(Diia.ink)
        .frame(height: 400)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Студентський

struct StudentCard: View {
    @EnvironmentObject private var store: ProfileStore
    var photo: UIImage?

    var body: some View {
        let p = store.profile
        VStack(alignment: .leading, spacing: 0) {
            Text("Студентський квиток")
                .font(Diia.cardTitle)
                .padding(.top, 24)

            Text(p.fioMultiline)
                .font(.system(size: 21, weight: .bold))
                .lineSpacing(4)
                .padding(.top, 12)

            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 9) {
                    field("Заклад:", display(p.student.university, fallback: "—"))
                    field("Курс:", "\(p.student.course)")
                    field("Дійсний до:", date(p.student.validUntil))
                }
                Spacer(minLength: 0)
                PhotoSlot(photo: photo)
            }
            .padding(.top, 14)

            Spacer(minLength: 56)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .foregroundColor(Diia.ink)
        .frame(height: 400)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Спільні елементи

extension Profile {
    var fioCaps: String {
        [surname, name, patronymic]
            .map { $0.uppercased() }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
    }

    var fioMultiline: String {
        let full = "\(surname) \(name) \(patronymic)".trimmingCharacters(in: .whitespaces)
        return full.isEmpty ? "Прізвище\nІм'я\nПо батькові" : full
    }
}

func display(_ value: String, fallback: String) -> String {
    value.isEmpty ? fallback : value
}

func date(_ d: Date?) -> String {
    guard let d else { return "—" }
    let f = DateFormatter()
    f.locale = Locale(identifier: "uk_UA")
    f.dateFormat = "dd.MM.yyyy"
    return f.string(from: d)
}

func field(_ label: String, _ value: String) -> some View {
    HStack(alignment: .top, spacing: 6) {
        Text(label)
            .font(Diia.fieldLabel)
        Text(value)
            .font(Diia.field)
            .opacity(value == "—" ? 0.55 : 1)
    }
}

struct PhotoSlot: View {
    var size: CGSize = CGSize(width: 92, height: 122)
    var photo: UIImage?

    var body: some View {
        ZStack {
            if let photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.white.opacity(0.5)
                Image(systemName: "person.fill")
                    .font(.system(size: 30))
                    .foregroundColor(Diia.muted.opacity(0.4))
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(.white.opacity(0.7), lineWidth: 1)
        )
    }
}

struct DotsButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Diia.ink)
                .frame(width: 36, height: 36)
                .overlay(
                    HStack(spacing: 3) {
                        ForEach(0..<3) { _ in
                            Circle().fill(.white).frame(width: 3.6, height: 3.6)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }
}
