//
//  Appearance.swift
//  DevForge
//
//  Created by resistanceto on 2025-09-02.
//

import SwiftUI

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    var systemIcon: String {
        switch self {
        case .system: "laptopcomputer"
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        }
    }
}

struct AppearanceSettingsView: View {
    @AppStorage("appAppearance") private var appearance: AppearanceMode = .system

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 页面标题
            VStack(alignment: .leading, spacing: 4) {
                Text("Appearance")
                    .font(.largeTitle.weight(.bold))

                Text("Customize the appearance of the application")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 20)

            Divider()

            // 主题设置组
            VStack(alignment: .leading, spacing: 16) {
                Text("Theme")
                    .font(.headline)

                // 主题选择器
                HStack(spacing: 8) {
                    ForEach(AppearanceMode.allCases) { mode in
                        ThemeOptionView(
                            mode: mode,
                            selectedMode: $appearance
                        )
                    }
                    Spacer()
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - 主题选项视图

private struct ThemeOptionView: View {
    let mode: AppearanceMode
    @Binding var selectedMode: AppearanceMode

    private var isSelected: Bool {
        selectedMode == mode
    }

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedMode = mode
            }
        } label: {
            VStack(spacing: 8) {
                // 主题预览
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(themePreviewGradient)
                        .frame(width: 64, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? Color.accentColor : Color.primary.opacity(0.2),
                                        lineWidth: isSelected ? 2 : 1)
                        )

                    Image(systemName: mode.systemIcon)
                        .font(.system(size: 16, weight: .medium))
//                        .foregroundStyle(mode.iconColor)
                }

                // 主题名称
                Text(mode.title)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    private var themePreviewGradient: LinearGradient {
        switch mode {
        case .light:
            return LinearGradient(
                colors: [.white, Color(.systemIndigo)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .dark:
            return LinearGradient(
                colors: [Color(.systemGray), Color(.black)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .system:
            return LinearGradient(
                colors: [Color(.systemBlue).opacity(0.3), Color(.systemPurple).opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

#Preview {
    AppearanceSettingsView()
}
