import SwiftUI

@mainActor
final class ToastCenter: ObservableObject {
    @Published var message: String? = nil
    private var hideTask: Task<Void, Never>? = nil

    func show(_ text: String) {
        message = text
        hideTask?.cancel()
        hideTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            if !Task.isCancelled { message = nil }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var store: ProfileStore
    @StateObject private var toast = ToastCenter()
    @State private var tab = 0

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        let selected = appearance.stackedLayoutAppearance.selected
        let normal = appearance.stackedLayoutAppearance.normal
        selected.iconColor = UIColor(Diia.ink)
        selected.titleTextAttributes = [.foregroundColor: UIColor(Diia.ink)]
        normal.iconColor = UIColor(Diia.ink)
        normal.titleTextAttributes = [.foregroundColor: UIColor(Diia.ink)]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $tab) {
            FeedScreen()
                .tabItem { Label("Стрічка", systemImage: "doc.richtext") }
                .tag(0)
            DocumentsScreen()
                .tabItem { Label("Документи", systemImage: "person.text.rectangle") }
                .tag(1)
            AiScreen()
                .tabItem { Label("Дія.AI", systemImage: "sparkles") }
                .tag(2)
            ServicesScreen()
                .tabItem { Label("Сервіси", systemImage: "bolt.square") }
                .tag(3)
            MenuScreen()
                .tabItem { Label("Меню", systemImage: "person.circle") }
                .tag(4)
        }
        .overlay(alignment: .top) {
            ToastBanner()
                .padding(.top, 6)
                .animation(.easeInOut(duration: 0.25), value: toast.message)
        }
        .environmentObject(toast)
    }
}

/// Зелений банер нагорі — «Номер пристрою скопійовано».
struct ToastBanner: View {
    @EnvironmentObject private var toast: ToastCenter

    var body: some View {
        if let msg = toast.message {
            Text(msg)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Diia.ink)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Diia.toastGreen)
        }
    }
}
