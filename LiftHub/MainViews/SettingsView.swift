//
//  SettingsView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 07/09/2024.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    @State private var selectedTheme: String = UserDefaultsUtils.shared.getTheme() // Use AppStorage to persist theme selection
    @State private var selectedUnit: String = UserDefaultsUtils.shared.getWeight()
    @State private var selectedIntensity: String = UserDefaultsUtils.shared.getIntensity()
    
    @State private var showMailComposer = false
    @State private var result: Result<MFMailComposeResult, Error>? = nil
    
    static let darkTheme = "Dark"
    static let darkBlueTheme = "DarkBlue"
    static let lightTheme = "Light"
    
    static let kilograms = "kg"
    static let pounds = "lbs"
    
    static let rpe = "RPE"
    static let rir = "RIR"
    
    // Apply the selected theme immediately
    static func applyTheme(theme: String) {
        switch theme {
        case darkTheme:
            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first!.overrideUserInterfaceStyle = .dark
//        case darkBlueTheme:
//            // Apply custom theme logic for DarkBlue (e.g., set specific colors)
//            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first!.overrideUserInterfaceStyle = .dark
//            // You can apply additional styling here for a custom theme.
            
        case lightTheme:
            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first!.overrideUserInterfaceStyle = .light
        default:
            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first!.overrideUserInterfaceStyle = .light
        }
    }
    
    var body: some View {
        ZStack {
            Color.BackgroundColorList.edgesIgnoringSafeArea(.all) // Custom background color
            
            List {
                // App Settings Section
                Section(header: Text("App Settings")) {
                    // Picker for App Theme
                    Picker("App Theme", selection: $selectedTheme) {
                        Text(SettingsView.darkTheme).tag(SettingsView.darkTheme)
                        Text(SettingsView.lightTheme).tag(SettingsView.lightTheme)
                        //Text("Dark Blue").tag("DarkBlue")
                    }
                    .onChange(of: selectedTheme) { theme in
                        SettingsView.applyTheme(theme: theme)  // Apply theme when the user selects a new option
                        UserDefaultsUtils.shared.setTheme(theme: theme)
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    // Weight Unit Picker
                    Picker("Weight Unit", selection: $selectedUnit) {
                        Text("Kilograms").tag(SettingsView.kilograms)
                        Text("Pounds").tag(SettingsView.pounds)
                    }
                    .onChange(of: selectedUnit) { unit in
                        UserDefaultsUtils.shared.setWeight(unit: unit)
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    // Intensity Index Picker
                    Picker("Intensity Index", selection: $selectedIntensity) {
                        Text(SettingsView.rpe).tag(SettingsView.rpe)
                        Text(SettingsView.rir).tag(SettingsView.rir)
                    }
                    .onChange(of: selectedIntensity) { intensity in
                        UserDefaultsUtils.shared.setIntensity(intensity: intensity)
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Feedback Section
                Section(header: Text("Feedback")) {
                    Button(action: {
                        showMailComposer.toggle()
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                            Text("Send Feedback")
                        }
                    }
                    .disabled(!MFMailComposeViewController.canSendMail())
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(false)
            .sheet(isPresented: $showMailComposer) {
                MailView(isShowing: $showMailComposer, result: $result)
            }
        }
        .onAppear {
            SettingsView.applyTheme(theme: selectedTheme)  // Ensure the theme is applied when the view appears
        }
    }
}

// MailView for sending feedback
struct MailView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?
        
        init(isShowing: Binding<Bool>, result: Binding<Result<MFMailComposeResult, Error>?>) {
            _isShowing = isShowing
            _result = result
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            defer { isShowing = false }
            if let error = error {
                self.result = .failure(error)
            } else {
                self.result = .success(result)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing, result: $result)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(["janos.macbak@gmail.com"])
        vc.setSubject("Feedback for LiftHub")
        vc.setMessageBody("Hi there,\n\nI wanted to share some feedback...\n\nThank you.", isHTML: false)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailView>) {}
}
