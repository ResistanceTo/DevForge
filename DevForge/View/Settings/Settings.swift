//
//  Settings.swift
//  DevForge
//
//  Created by resistanceto on 2025-08-28.
//
import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            AppearanceSettingsView()
                .tabItem {
                    // 2. 为每个 Tab 定义图标和标题
                    Label("Appearance", systemImage: "paintbrush.fill")
                }

            VisibleToolsSettingsView()
                .tabItem {
                    Label("Tools", systemImage: "wrench.and.screwdriver.fill")
                }

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle.fill")
                }
        }
        .tabViewStyle(.automatic)
        .frame(width: 500, height: 480)
    }
}

// MARK: - Supporting Views

/// 设置卡片容器
struct SettingsCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(24)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.separator.opacity(0.5), lineWidth: 0.5)
            )
    }
}

#Preview {
    SettingsView()
}
