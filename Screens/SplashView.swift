import SwiftUI

/// Сплеш: пастельний градієнт, тризуб у скругленій рамці, міністерство.
struct SplashView: View {
    let onFinish: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Diia.skyTop, Diia.skyMid, Diia.skyBottom],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            HStack(spacing: 18) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Diia.ink, lineWidth: 3)
                    .frame(width: 64, height: 64)
                    .overlay(
                        Image("Tryzub")
                            .resizable()
                            .scaledToFit()
                            .padding(9)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text("Міністерство")
                    Text("цифрової трансформації")
                    Text("України")
                }
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Diia.ink)
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 1_700_000_000)
            onFinish()
        }
    }
}
