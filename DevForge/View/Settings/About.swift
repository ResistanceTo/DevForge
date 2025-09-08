//
//  About.swift
//  DevForge
//
//  Created by resistanceto on 2025-09-05.
//

import SwiftUI

struct AboutView: View {
    // MARK: - App Info Properties
    
    // 从 App 的 Bundle 中动态获取信息，无需硬编码
    let appIcon = Bundle.main.icon
    let appName = Bundle.main.displayName ?? "DevForge"
    let appVersion = Bundle.main.versionNumber ?? "1.0"
    let buildVersion = Bundle.main.buildNumber ?? "1"
    let copyright = Bundle.main.copyright ?? "© \(Calendar.current.component(.year, from: .now)) Zhaohe. All rights reserved."
    
    // MARK: - Tech Stack
    
    let techStack = ["SwiftUI", "CryptoKit", "CommonCrypto", "Combine", "Vision", "CoreImage", "AppKit"]

    var body: some View {
        VStack(spacing: 24) {
            // 顶部 App 信息
            VStack {
                Image(nsImage: appIcon ?? NSImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                Text(appName)
                    .font(.largeTitle.weight(.bold))
                
                Text("Version \(appVersion) (\(buildVersion))")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text(copyright)
                    .font(.caption)
                    .foregroundColor(.cyan)
                    .padding(.top, 4)
            }
            
            Divider()
            
            // App 简介
            Text("DevForge is a powerful toolkit designed for developers, providing a collection of essential utilities to streamline your daily workflow.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            // 技术栈
            VStack(alignment: .leading) {
                Text("Technology Stack")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                // 使用自适应网格来展示技术栈标签
                let columns = [GridItem(.adaptive(minimum: 100))]
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(techStack, id: \.self) { tech in
                        techStackPill(name: tech)
                    }
                }
            }
            
            Spacer()
            
            // 链接按钮
            HStack {
                LinkButton(
                    title: "Official Website",
                    icon: "safari.fill",
                    url: URL(string: "https://zhaohe.org")!
                )
                
                LinkButton(
                    title: "GitHub",
                    icon: "chevron.left.forwardslash.chevron.right",
                    url: URL(string: "https://github.com/ResistanceTo/DevForge")!
                )
            }
        }
        .padding(32)
        .frame(width: 480) // 固定窗口宽度
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial) // 毛玻璃背景
    }
    
    /// 技术栈标签视图
    private func techStackPill(name: String) -> some View {
        Text(name)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.accentColor.opacity(0.1))
            .foregroundColor(.accentColor)
            .cornerRadius(20)
    }
}

// MARK: - 可复用的链接按钮

private struct LinkButton: View {
    let title: LocalizedStringKey
    let icon: String
    let url: URL
    
    var body: some View {
        Link(destination: url) {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 扩展 Bundle 以方便地获取 App 信息

extension Bundle {
    var icon: NSImage? {
        guard let iconName = infoDictionary?["CFBundleIconFile"] as? String else { return nil }
        return NSImage(named: iconName)
    }
    
    var displayName: String? {
        infoDictionary?["CFBundleDisplayName"] as? String ?? infoDictionary?["CFBundleName"] as? String
    }
    
    var versionNumber: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildNumber: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }
    
    var copyright: String? {
        infoDictionary?["NSHumanReadableCopyright"] as? String
    }
}
