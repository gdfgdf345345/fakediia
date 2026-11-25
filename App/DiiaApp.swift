import SwiftUI

@main
struct DiiaApp: App {
    @StateObject private var store = ProfileStore()
    @State private var splashDone = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .environmentObject(store)
                if !splashDone {
                    SplashView {
                        withAnimation(.easeOut(duration: 0.45)) {
                            splashDone = true
                        }
                    }
                    .transition(.opacity)
                    .zIndex(10)
                }
            }
        }
    }
}
