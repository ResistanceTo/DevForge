//
//  SidebarItem.swift
//  DevForge
//
//  Created by resistanceto on 2025-08-28.
//

import SwiftUI

// 代表侧边栏中的一个项目，可以是分类标题，也可以是工具
enum SidebarItem: Identifiable, Hashable {
    case category(ToolCategory)
    case tool(Tool)

    // Identifiable 协议要求
    var id: String {
        switch self {
        case .category(let category):
            // 为分类和工具ID添加前缀，确保唯一性
            return "category_\(category.id)"
        case .tool(let tool):
            return "tool_\(tool.id)"
        }
    }

    // 从 Item 中提取 Tool，方便后续使用
    var tool: Tool? {
        if case .tool(let tool) = self {
            return tool
        }
        return nil
    }
}
