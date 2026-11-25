import SwiftUI

enum Sex: String, Codable, CaseIterable, Identifiable {
    case man = "Чоловіча"
    case woman = "Жіноча"
    var id: String { rawValue }
}

struct PassportDoc: Codable, Equatable {
    var number: String = ""      // 9 цифр ID-картки
    var issueDate: Date? = nil
    var issuedBy: String = ""    // напр. "ТЦЦ 7931"
}

struct DriverDoc: Codable, Equatable {
    var categories: String = ""  // напр. "A, B"
    var number: String = ""      // напр. МВЕ96869
    var validUntil: Date? = nil
    var issuedBy: String = "ТЦЦ 7931"
}

struct TaxpayerDoc: Codable, Equatable {
    var rnokpp: String = ""      // 10 цифр
}

struct StudentDoc: Codable, Equatable {
    var university: String = ""
    var course: Int = 1
    var number: String = ""
    var validUntil: Date? = nil
}

struct Profile: Codable, Equatable {
    var surname: String = ""
    var name: String = ""
    var patronymic: String = ""
    var birthDate: Date? = nil
    var sex: Sex = .man
    var passport = PassportDoc()
    var driver = DriverDoc()
    var taxpayer = TaxpayerDoc()
    var student = StudentDoc()
}

enum DocKind: Int, CaseIterable, Identifiable {
    case passport = 0, driver = 1, taxpayer = 2, student = 3
    var id: Int { rawValue }

    var title: String {
        switch self {
        case .passport: return "Паспорт громадянина"
        case .driver: return "Посвідчення водія"
        case .taxpayer: return "Картка платника податків"
        case .student: return "Студентський квиток"
        }
    }

    var short: String {
        switch self {
        case .passport: return "Паспорт"
        case .driver: return "Водій"
        case .taxpayer: return "РНОКПП"
        case .student: return "Студентський"
        }
    }

    var hasPhoto: Bool {
        switch self {
        case .passport, .driver, .student: return true
        case .taxpayer: return false
        }
    }
}

enum DocNumbers {
    static func randomPassportNumber() -> String {
        String(format: "%09d", Int.random(in: 0...99_999_999))
    }
    static func randomDriverNumber() -> String {
        let alphabet = Array("АБВГДЕЗИІКЛМНОПРСТУФХЦШЩЄЮЯ")
        let letters = String((0..<3).map { _ in alphabet.randomElement()! })
        let digits = String(format: "%05d", Int.random(in: 0...99_999))
        return letters + digits
    }
    static func randomTaxpayerNumber() -> String {
        String(format: "%010d", Int.random(in: 0...9_999_999_999))
    }
    static func randomStudentNumber() -> String {
        String(format: "%06d", Int.random(in: 0...999_999))
    }
}
