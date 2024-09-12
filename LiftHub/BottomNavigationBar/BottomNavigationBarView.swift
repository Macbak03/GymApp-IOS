import SwiftUI

enum BottomBarSelectedTab: Int {
    case stats = 0
    case plans = 1
    case workout = 2
    case history = 3
    case settings = 4
}

struct BottomBar: View {
    @Environment(\.safeAreaInsets) var safeAreaInsets
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedTab: BottomBarSelectedTab
    
    var body: some View {
        TabView(selection: $selectedTab) {
            StatsView()
                .tag(BottomBarSelectedTab.stats)
            PlansView()
                .tag(BottomBarSelectedTab.plans)
            HomeView()
                .tag(BottomBarSelectedTab.workout)
            HistoryView()
                .tag(BottomBarSelectedTab.history)
            SettingsView()
                .tag(BottomBarSelectedTab.settings)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .overlay(
            HStack(spacing:35) {
                BottomBarButton(selectedTab: $selectedTab, tab: .stats, image: "stats_icon", text: "Stats")
                BottomBarButton(selectedTab: $selectedTab, tab: .plans, image: "plans_icon", text: "Plans")
                BottomBarButton(selectedTab: $selectedTab, tab: .workout, image: "workout_icon", text: "Workout")
                BottomBarButton(selectedTab: $selectedTab, tab: .history, image: "history_icon", text: "History")
                BottomBarButton(selectedTab: $selectedTab, tab: .settings, image: "settings_icon", text: "Settings")
            }
            .frame(height: 20)
            .background(
                Image("navigation_bar_background")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(Color("BackgroundColorList"))
                    .frame(width: 400.0, height: 115.0)
                    
            )
            .shadow(color: Color("BackgroundColorList").opacity(colorScheme == .dark ? 0.5 : 0.1), radius: 10, x: 0, y: 0)
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
                .frame(width: isActive ? 36 : 40, height: isActive ? 36 : 40)
            Text(text)
                .font(.caption)
                .foregroundColor(isActive ? Color("AccentColor") : Color("TextColorPrimary"))
        }
    }
}

// Dummy Views for each tab
struct StatsView: View { var body: some View { Text("Stats View") } }
struct HistoryView: View { var body: some View { Text("History View") } }

struct BottomBar_Previews: PreviewProvider {
    static var previews: some View {
        BottomBar(selectedTab: .constant(.workout))
    }
}
