//
//  ContentSidebar.swift
//  DevForge
//
//  Created by resistanceto on 2025-08-28.
//

import SwiftUI

struct ContentSidebar: View {
    @Environment(ToolManager.self) var toolManager
    @State private var searchText = ""
    @Binding var selectedTool: Tool?

    @State private var expandedCategories: Set<ToolCategory.ID> = []

    // 1. 创建一个新的计算属性，返回“扁平化”的数组
    private var listItems: [SidebarItem] {
        var items: [SidebarItem] = []

        let collectionsToDisplay: [ToolCollection]
        if searchText.isEmpty {
            collectionsToDisplay = toolManager.visibleCollections
        } else {
            var filteredCollections = [ToolCollection]()
            let lowercasedQuery = searchText.lowercased()
            for collection in toolManager.visibleCollections {
                let matchingTools = collection.tools.filter { tool in
                    tool.localizedTitle.lowercased().contains(lowercasedQuery)
                }
                if !matchingTools.isEmpty {
                    filteredCollections.append(ToolCollection(category: collection.category, tools: matchingTools))
                }
            }
            collectionsToDisplay = filteredCollections
        }

        // 将过滤后的结果“扁平化”
        for collection in collectionsToDisplay {
            // 先添加分类标题 item
            items.append(.category(collection.category))
            if expandedCategories.contains(collection.category.id) {
                for tool in collection.tools {
                    items.append(.tool(tool))
                }
            }
        }
        return items
    }

    var body: some View {
        List(selection: $selectedTool) {
            ForEach(listItems) { item in
                switch item {
                case .category(let category):
                    // 将分类标题做成一个按钮，用于控制折叠
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            toggleCategory(category)
                        }
                    }) {
                        HStack {
                            Text(category.title)
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                                // 根据展开状态旋转箭头
                                .rotationEffect(.degrees(isCategoryExpanded(category) ? 90 : 0))
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 10)
                    .padding(.bottom, 5)

                case .tool(let tool):
                    NavigationLink(value: tool) {
                        Label {
                            Text(tool.localizedTitle)
                        } icon: {
                            Image(tool.icon)
                                .resizable() // 让图片可缩放
                                .scaledToFit() // 保持其宽高比
                                .frame(width: 18, height: 18)
                        }
                    }
                }
            }
        }
//        .toolbar {
//            ToolbarItem(placement: .primaryAction) {
//                Menu {} label: {
//                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
//                }
//            }
//        }
        .searchable(text: $searchText, placement: .sidebar)
        .frame(minWidth: 220)
        .listStyle(.sidebar)
        .onAppear {
            // 视图首次出现时，默认展开所有分类
            for collection in toolManager.visibleCollections {
                expandedCategories.insert(collection.category.id)
            }
        }
        .padding(.trailing, -16) // 使用它来隐藏滚动条，系统提供的修饰符都不行
    }

    // MARK: - Helper Functions

    /// 检查某个分类是否已展开
    private func isCategoryExpanded(_ category: ToolCategory) -> Bool {
        expandedCategories.contains(category.id)
    }

    /// 切换分类的展开/折叠状态
    private func toggleCategory(_ category: ToolCategory) {
        if expandedCategories.contains(category.id) {
            expandedCategories.remove(category.id)
        } else {
            expandedCategories.insert(category.id)
        }
    }
}

#Preview {
    @Previewable @State var selectedToolForPreview: Tool? = nil
    @Previewable @State var toolManager = ToolManager()

    ContentSidebar(selectedTool: $selectedToolForPreview)
        .environment(toolManager)
}
