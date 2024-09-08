import SwiftUI

private struct SafeAreaInsetsEnvironmentKey: EnvironmentKey {
    static let defaultValue: (top: CGFloat, bottom: CGFloat) = (0, 0)
}

extension EnvironmentValues {
    var safeAreaInsets: (top: CGFloat, bottom: CGFloat) {
        get { self[SafeAreaInsetsEnvironmentKey.self] }
        set { self[SafeAreaInsetsEnvironmentKey.self] = newValue }
    }
}


@main
struct BottomBarApp: App {
    @State private var safeAreaInsets: (top: CGFloat, bottom: CGFloat) = (0, 0)
    var body: some Scene {
        WindowGroup {
            ZStack {
                GeometryReader { proxy in
                    Color.clear.onAppear {
                        safeAreaInsets = (proxy.safeAreaInsets.top, proxy.safeAreaInsets.bottom)
                    }
                }
                
                ContentView()
                    .environment(\.safeAreaInsets, safeAreaInsets)
            }
        }
    }
    
   
}

