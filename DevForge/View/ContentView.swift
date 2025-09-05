//
//  ContentView.swift
//  DevForge
//
//  Created by resistanceto on 2025-08-28.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.premiumProvider) private var premiumProvider
    @Environment(ToolManager.self) var toolManager

    @State private var selectedTool: Tool?
    @State private var showSponsor = false

    var body: some View {
        NavigationSplitView {
            ContentSidebar(selectedTool: $selectedTool)
        } detail: {
            if let tool = selectedTool {
                AnyView(tool.viewProvider())
            } else {
//                Text("Select a tool")
                AboutView()
            }
        }
        .withGlobalHUD()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showSponsor = true
                } label: {
                    Image(premiumProvider.hasPremium ? "sponsor.true" : "sponsor.false")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
            }
        }
        .sheet(isPresented: $showSponsor) {
            premiumProvider.hasPremium ? premiumProvider.makeThankYouView() : premiumProvider.makeSponsorView()
        }
    }
}
