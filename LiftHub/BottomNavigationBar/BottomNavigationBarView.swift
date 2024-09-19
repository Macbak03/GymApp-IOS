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
            .frame(height: 20)
            .background(
                Image("navigation_bar_background")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(Color.BottomBarColor)
                    .frame(width: 400.0, height: 115.0)
                    
            )
            .shadow(radius: 5)
            , alignment: .bottom
        )
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
                .frame(width: isActive ? 40 : 36, height: isActive ? 40 : 36)
                .grayscale(isActive ? 0.0 : 1)
                .brightness(isActive ? 0.0 : 0.3)
                .contrast(isActive ? 1.0 : 1.5)
            Text(text)
                .font(.system(size: isActive ? 13 : 12, weight: isActive ? .bold : .regular))
                .foregroundColor(isActive ? Color("AccentColor") : Color("TextColorPrimary"))
        }
    }
}

struct BottomBar_Previews: PreviewProvider {
    static var previews: some View {
        BottomBar(selectedTab: .constant(.workout))
    }
}
