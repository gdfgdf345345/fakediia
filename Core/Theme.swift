import SwiftUI

// Палітра нової Дії 4.38: живий градієнт, glass-карточки, чорні пілюлі.
extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

enum Diia {
    // Живий фон: голубий -> м'ятний -> лавандовий
    static let skyTop = Color(hex: 0xA9CFEA)
    static let skyMid = Color(hex: 0xBFE3C8)
    static let skyBottom = Color(hex: 0xD8C9EC)

    static let ink = Color(hex: 0x141416)
    static let muted = Color(hex: 0x5C5C66)
    static let separator = Color(hex: 0xE8E8EC)
    static let stripeYellow = Color(hex: 0xF5C400)
    static let updateBand = Color(hex: 0xBFF0A8) // зелена смуга «Документ оновлено»
    static let toastGreen = Color(hex: 0x57D977)

    static let screenTitle = Font.system(size: 34, weight: .bold)
    static let cardTitle = Font.system(size: 21, weight: .bold)
    static let bigNumber = Font.system(size: 30, weight: .bold)
    static let field = Font.system(size: 15, weight: .regular)
    static let fieldLabel = Font.system(size: 15, weight: .medium)

    static let updatedAtFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "uk_UA")
        f.dateFormat = "d.M.yyyy 'о' HH:mm"
        return f
    }()

    static let longDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "uk_UA")
        f.dateFormat = "d MMMM yyyy / HH:mm"
        return f
    }()

    static let docBandFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "uk_UA")
        f.dateFormat = "HH:mm | d.M.yyyy"
        return f
    }()

    static var bgGradient: LinearGradient {
        LinearGradient(
            colors: [skyTop, skyMid, skyBottom],
            startPoint: .top, endPoint: .bottom
        )
    }
}

extension Date {
    func formatted(_ f: DateFormatter) -> String { f.string(from: self) }
}

/// Glass-поверхня: напівпрозорий білий шар поверх градієнта.
struct GlassSurface: ViewModifier {
    var radius: CGFloat = 28

    func body(content: Content) -> some View {
        content
            .background(.white.opacity(0.42))
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

extension View {
    func diiaGlass(radius: CGFloat = 28) -> some View {
        modifier(GlassSurface(radius: radius))
    }
}
