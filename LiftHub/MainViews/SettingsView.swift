//
//  SettingsView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 07/09/2024.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @State private var isDarkModeOn = true
    
    init() {
        UINavigationBar.appearance().barTintColor = UIColor(named: "ColorPrimary")
        UINavigationBar.appearance().backgroundColor = UIColor(named: "ColorPrimary")
        UITableView.appearance().backgroundColor = UIColor(named: "BackgroundColor")
    }
    
    func setAppTheme(){
        //MARK: use saved device theme from toggle
        isDarkModeOn = UserDefaultsUtils.shared.getDarkMode()
        //MARK: or use device theme
        /*
         if (colorScheme == .dark)
         {
         isDarkModeOn = true
         }
         else{
         isDarkModeOn = false
         }
         */
        changeDarkMode(state: isDarkModeOn)
    }
    
    func changeDarkMode(state: Bool){
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first!.overrideUserInterfaceStyle = state ? .dark : .light
        UserDefaultsUtils.shared.setDarkMode(enable: state)
    }
    
    var ToggleThemeView: some View {
        Toggle("Dark Mode", isOn: $isDarkModeOn).onChange(of: isDarkModeOn) { (state)  in
            changeDarkMode(state: state)
        }.labelsHidden()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.BackgroundColorList.edgesIgnoringSafeArea(.all)
                VStack() {
                    Text("Switch theme").foregroundColor(Color.TextColorPrimary).padding(10)
                    ToggleThemeView
                }
                .background(Color.BackgroundColorList)
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarItems(
                    leading:
                        Text("Settings").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    
                )
                .navigationBarBackButtonHidden(true)
                .foregroundColor(Color.TextColorPrimary)
            }
        }
        .background(Color.BackgroundColorList)
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: {
            setAppTheme()
        })
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environment(\.colorScheme, .light)  //Light mode
        
        SettingsView()
            .environment(\.colorScheme, .dark)  //Light mode
    }
}
