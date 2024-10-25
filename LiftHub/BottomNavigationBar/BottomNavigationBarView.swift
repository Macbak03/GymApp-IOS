import SwiftUI

enum BottomBarSelectedTab: Int {
    //case stats = 0
    case workout = 0
    case plans = 1
    case history = 2
    case settings = 3
}

struct BottomBar: View {
    @Environment(\.safeAreaInsets) var safeAreaInsets
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedTab: BottomBarSelectedTab
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                TabView(selection: $selectedTab) {
                    //            StatsView()
                    //                .tag(BottomBarSelectedTab.stats)
                    HomeView()
                        .tag(BottomBarSelectedTab.workout)
                    PlansView()
                        .tag(BottomBarSelectedTab.plans)
                    HistoryView()
                        .tag(BottomBarSelectedTab.history)
                    SettingsView()
                        .tag(BottomBarSelectedTab.settings)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .overlay(
                    HStack(spacing:50) { //35 for 5 elements, change position of workout and plans
                        //                BottomBarButton(selectedTab: $selectedTab, tab: .stats, image: "stats_icon", text: "Stats")
                        BottomBarButton(selectedTab: $selectedTab, tab: .workout, image: "workout_icon", text: "Workout")
                        BottomBarButton(selectedTab: $selectedTab, tab: .plans, image: "plans_icon", text: "Plans")
                        BottomBarButton(selectedTab: $selectedTab, tab: .history, image: "history_icon", text: "History")
                        BottomBarButton(selectedTab: $selectedTab, tab: .settings, image: "settings_icon", text: "Settings")
                    }
                        .padding(.top, 10)
                    
                        .frame(height: 20)
                        .background(
                            Image("navigation_bar_background")
                                .renderingMode(.template)
                                .resizable()
                                .foregroundColor(Color.BottomBarColor)
                                .frame(width: geometry.size.width, height: 70)
                            
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: -3)
                    , alignment: .bottom
                )
                .padding(.bottom, getBottomPadding()) // Add padding to stay above the home indicator
            }
        }
    }
    
    private func getBottomPadding() -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height

            if screenHeight <= 667 {
                // iPhone SE or smaller screens (e.g., 1st or 2nd gen SE)
                return 30
            } else {
                // Default padding for other devices
                return safeAreaInsets.bottom > 0 ? safeAreaInsets.bottom : 15
            }
    }
}

struct BottomBarButton: View {
    @Binding var selectedTab: BottomBarSelectedTab
    var tab: BottomBarSelectedTab
    var image: String
    var text: String
    
    var body: some View {
        Button {
            selectedTab = tab
        } label: {
            BottomBarButtonView(image: image, text: text, isActive: selectedTab == tab)
        }
    }
}

struct BottomBarButtonView: View {
    var image: String
    var text: String
    var isActive: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            Image(image)
                .resizable()
                .frame(width: isActive ? 30 : 25, height: isActive ? 30 : 25)
                .grayscale(isActive ? 0.0 : 1)
                .brightness(isActive ? 0.0 : 0.3)
                .contrast(isActive ? 1.0 : 1.5)
            Text(text)
                .font(.system(size: isActive ? 11 : 10, weight: isActive ? .bold : .regular))
                .foregroundColor(isActive ? Color("AccentColor") : Color("TextColorPrimary"))
        }
    }
}

struct BottomBar_Previews: PreviewProvider {
    static var previews: some View {
        BottomBar(selectedTab: .constant(.workout))
    }
}
