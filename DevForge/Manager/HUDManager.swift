//
//  HUDManager.swift
//  DevForge
//
//  Created by ResistanceTo on 2025/8/30.
//

import SwiftUI

/// 一个全局的HUD（平视显示器）管理器，用于显示短暂的状态信息。
@MainActor @Observable
final class HUDManager {
    /// 全局唯一的共享实例
    static let shared = HUDManager()
    
    /// HUD是否正在显示
    var isShowing: Bool = false
    /// HUD显示的消息
    var message: String = ""
    /// HUD显示的系统图标名
    var systemImage: String = "checkmark.circle.fill"
    
    // 用于管理显示时间的任务，防止多次调用时冲突
    @ObservationIgnored private var displayTask: Task<Void, Never>?

    /// 显示一个HUD
    /// - Parameters:
    ///   - message: 要显示的消息文本
    ///   - systemImage: 要显示的SF Symbol图标
    ///   - duration: HUD显示的时长（秒）
    func show(message: String, systemImage: String = "checkmark.circle.fill", duration: TimeInterval = 2) {
        // 取消上一个可能还未结束的显示任务
        displayTask?.cancel()
        
        // 立即更新内容并显示HUD
        self.message = message
        self.systemImage = systemImage
        
        withAnimation(.spring) {
            self.isShowing = true
        }
        
        // 创建一个新任务，在指定时长后隐藏HUD
        displayTask = Task {
            do {
                try await Task.sleep(for: .seconds(duration))
                // 再次检查任务是否已被取消
                guard !Task.isCancelled else { return }
                withAnimation(.spring) {
                    self.isShowing = false
                }
            } catch {
                // 如果任务被取消，则直接退出
            }
        }
    }
}
