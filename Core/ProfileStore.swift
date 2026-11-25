import SwiftUI
import UIKit

@MainActor
final class ProfileStore: ObservableObject {
    @Published var profile: Profile {
        didSet { persist() }
    }
    @Published var photoImage: UIImage?
    @Published var lastUpdated: Date? = nil

    private let defaults: UserDefaults
    private let profileKey = "fakediia.profile.v2"
    private let updatedAtKey = "fakediia.updatedAt.v2"
    static let photoURL = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("fake_diia_photo.jpg")

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: profileKey),
           let decoded = try? JSONDecoder().decode(Profile.self, from: data) {
            profile = decoded
        } else {
            profile = Profile()
        }
        lastUpdated = defaults.object(forKey: updatedAtKey) as? Date
        if let data = try? Data(contentsOf: Self.photoURL),
           let img = UIImage(data: data) {
            photoImage = img
        }
    }

    /// Текст картки для QR-коду
    func qrPayload(for kind: DocKind) -> String {
        let p = profile
        let fio = "\(p.surname) \(p.name) \(p.patronymic)".trimmingCharacters(in: .whitespaces)
        switch kind {
        case .passport:
            return "ДІЯ|ПАСПОРТ|\(fio)|№ \(p.passport.number)"
        case .driver:
            return "ДІЯ|ПОСВІДЧЕННЯ ВОДІЯ|\(fio)|\(p.driver.number)|\(p.driver.categories)"
        case .taxpayer:
            return "ДІЯ|КАРТКА ПЛАТНИКА ПОДАТКІВ|\(fio)|РНОКПП \(p.taxpayer.rnokpp)"
        case .student:
            return "ДІЯ|СТУДЕНТСЬКИЙ КВИТОК|\(fio)|\(p.student.university)|№ \(p.student.number)"
        }
    }

    func setPhoto(_ image: UIImage) {
        photoImage = image
        if let data = image.jpegData(compressionQuality: 0.9) {
            try? data.write(to: Self.photoURL, options: .atomic)
        }
        touch()
    }

    func clearPhoto() {
        photoImage = nil
        try? FileManager.default.removeItem(at: Self.photoURL)
        touch()
    }

    func generateNumbers() {
        if profile.passport.number.isEmpty { profile.passport.number = DocNumbers.randomPassportNumber() }
        if profile.driver.number.isEmpty { profile.driver.number = DocNumbers.randomDriverNumber() }
        if profile.taxpayer.rnokpp.isEmpty { profile.taxpayer.rnokpp = DocNumbers.randomTaxpayerNumber() }
        if profile.student.number.isEmpty { profile.student.number = DocNumbers.randomStudentNumber() }
        touch()
    }

    func reset() {
        profile = Profile()
        clearPhoto()
    }

    private func touch() {
        lastUpdated = Date()
        defaults.set(lastUpdated, forKey: updatedAtKey)
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(profile) {
            defaults.set(data, forKey: profileKey)
        }
    }
}
