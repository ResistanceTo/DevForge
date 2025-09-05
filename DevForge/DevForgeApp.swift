//
//  DevForgeApp.swift
//  DevForge
//
//  Created by resistanceto on 2025-08-28.
//

import SwiftUI

@main
struct DevForgeApp: App {
    @Environment(\.openWindow) private var openWindow
    @State private var toolManager = ToolManager()
    @State private var hudManager = HUDManager.shared

    @State private var premiumProvider: any PremiumStatusProvider

    @AppStorage("appAppearance") private var appearance: AppearanceMode = .system

    init() {
        #if APPSTORE_BUILD
        self._premiumProvider = State(initialValue: SubscriptionManager())
        print("INFO: Initializing with real SubscriptionManager.")
        #else
        self._premiumProvider = State(initialValue: DemoPremiumProvider())
        print("INFO: Initializing with OpenSourcePremiumProvider.")
        #endif
        
//        self._premiumProvider = State(initialValue: SubscriptionManager())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(toolManager)
                .environment(hudManager)
                .environment(\.premiumProvider, premiumProvider)
                .task {
                    await premiumProvider.prepare()
                }
                .preferredColorScheme(appearance.colorScheme)
        }
        
        Settings {
            SettingsView()
                .environment(toolManager)
                .preferredColorScheme(appearance.colorScheme)
        }
    }
}
