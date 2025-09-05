//
//  HUDViewModifier.swift
//  DevForge
//
//  Created by ResistanceTo on 2025/8/30.
//

import SwiftUI

/// 一个通用的HUD视图
struct HUDView: View {
    let message: String
    let systemImage: String

    var body: some View {
        Label(self.message, systemImage: self.systemImage)
            .font(.headline)
            .foregroundColor(.primary)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .cornerRadius(30)
            .shadow(radius: 5)
    }
}

/// 一个ViewModifier，负责监听HUDManager并应用overlay
struct HUDViewModifier: ViewModifier {
    // 从环境中获取全局唯一的 HUDManager 实例
    @Environment(HUDManager.self) private var hudManager

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                // 当 isShowing 为 true 时，显示HUD
                if self.hudManager.isShowing {
                    HUDView(message: self.hudManager.message, systemImage: self.hudManager.systemImage)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 30)
                }
            }
    }
}

// 为了方便调用，我们再为 View 添加一个扩展
extension View {
    func withGlobalHUD() -> some View {
        self.modifier(HUDViewModifier())
    }
}
