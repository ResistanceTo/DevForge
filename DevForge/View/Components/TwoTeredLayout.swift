//
//  TwoTieredLayout.swift
//  DevForge
//
//  Created by resistanceto on 2025-08-29.
//

import SwiftUI

/// 左右或上下两栏分布的一个模板，切换按钮做成了一个toolbar
struct TwoTieredLayout<LeftContent: View, RightContent: View>: View {
    enum LayoutDirection {
        case horizontal, vertical
    }
    
    // 1. 布局状态由这个通用视图自己管理
    @State private var layoutDirection: LayoutDirection = .horizontal
    
    // 2. 使用 @ViewBuilder 接受任意的 SwiftUI 视图作为内容
    private let leftContentView: LeftContent
    private let rightContentView: RightContent
    
    // 3. 初始化方法，捕获传入的视图构建闭包
    init(@ViewBuilder left: () -> LeftContent, @ViewBuilder right: () -> RightContent) {
        self.leftContentView = left()
        self.rightContentView = right()
    }

    var body: some View {
        VStack(spacing: 16) {
            if layoutDirection == .horizontal {
                HStack(spacing: 16) {
                    leftContentView
                    rightContentView
                }
            } else {
                VStack(spacing: 16) {
                    leftContentView
                    rightContentView
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: toggleLayout) {
                    Label("Toggle Layout", systemImage: layoutDirection == .horizontal ? "rectangle.split.1x2" : "rectangle.split.2x1")
                }
            }
        }
    }
    
    private func toggleLayout() {
        withAnimation(.spring) {
            layoutDirection = (layoutDirection == .horizontal) ? .vertical : .horizontal
        }
    }
}
