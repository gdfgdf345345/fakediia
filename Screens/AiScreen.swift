import SwiftUI

// MARK: - Дія.AI: чат-інтерфейс з локальними відповідями

struct AiScreen: View {
    struct Msg: Identifiable, Equatable {
        let id = UUID()
        let text: String
        let isUser: Bool
    }

    @State private var messages: [Msg] = []
    @State private var draft = ""

    private var answered: [String] {
        [
            "Я демонстраційний асистент жартівливої версії Дії. Реальні документи я не видаю — їх тут ніхто не видає.",
            "У фейковій Дії я вмію тільки гарно моргати чотирикінцевою зіркою ✨",
            "Скажу чесно: я просто чорний текст на склі. Але гарний."
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Дія.AI")
                    .font(Diia.screenTitle)
                    .foregroundColor(Diia.ink)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            if messages.isEmpty {
                Spacer()
                VStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Diia.ink)
                            .frame(width: 64, height: 64)
                        Image(systemName: "sparkles")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.white)
                    }
                    Text("Запитайте Дія.AI")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Diia.ink)
                    Text("Напишіть будь-що — асистент відповість")
                        .font(.system(size: 15))
                        .foregroundColor(Diia.muted)
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(messages) { m in
                            HStack {
                                if m.isUser { Spacer(minLength: 40) }
                                Text(m.text)
                                    .font(.system(size: 16))
                                    .foregroundColor(Diia.ink)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(m.isUser ? Color.white : Color.white.opacity(0.55))
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                if !m.isUser { Spacer(minLength: 40) }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }

            HStack(spacing: 10) {
                TextField("Запитайте Дія.AI…", text: $draft)
                    .font(.system(size: 16))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .clipShape(Capsule())

                Button(action: send) {
                    ZStack {
                        Circle()
                            .fill(Diia.ink)
                            .frame(width: 44, height: 44)
                        Image(systemName: "arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(draft.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Diia.bgGradient.ignoresSafeArea())
    }

    private func send() {
        let question = draft.trimmingCharacters(in: .whitespaces)
        guard !question.isEmpty else { return }
        draft = ""
        messages.append(Msg(text: question, isUser: true))
        let reply = answered[messages.count % answered.count]
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 700_000_000)
            messages.append(Msg(text: reply, isUser: false))
        }
    }
}
