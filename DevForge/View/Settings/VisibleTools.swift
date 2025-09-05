//
//  VisibleTools.swift
//  DevForge
//
//  Created by resistanceto on 2025-09-04.
//

import SwiftUI

struct VisibleToolsSettingsView: View {
    @Environment(ToolManager.self) private var toolManager

    @AppStorage("hiddenToolIDs") private var hiddenToolIDsData: Data = .init()

    private var hiddenToolIDs: Set<String> {
        get {
            (try? JSONDecoder().decode(Set<String>.self, from: hiddenToolIDsData)) ?? []
        }
        set {
            hiddenToolIDsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 页面标题
            VStack(alignment: .leading, spacing: 4) {
                Text("Tools")
                    .font(.largeTitle.weight(.bold))

                Text("Control which tools appear in the sidebar")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 20)

            Divider()

            // 工具列表
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(toolManager.masterCollections) { collection in
                        ToolCategoryView(
                            collection: collection,
                            hiddenToolIDs: bindingForHiddenTools()
                        )
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func bindingForHiddenTools() -> Binding<Set<String>> {
        Binding(
            get: { self.hiddenToolIDs },
            set: { newValue in
                let data = try? JSONEncoder().encode(newValue)
                self.hiddenToolIDsData = data ?? Data()
            }
        )
    }
}

// MARK: - 工具分类视图

private struct ToolCategoryView: View {
    let collection: ToolCollection
    @Binding var hiddenToolIDs: Set<String>
    @State private var isExpanded: Bool = true

    private var visibleToolsCount: Int {
        collection.tools.count - collection.tools.filter { hiddenToolIDs.contains($0.title) }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 分类头部
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(collection.category.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Spacer()

                    // 工具数量标签
                    Text("\(visibleToolsCount) of \(collection.tools.count) visible")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.quaternary, in: Capsule())

                    // 展开箭头
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())

            // 工具列表
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(collection.tools.indices, id: \.self) { index in
                        ToolRowView(
                            tool: collection.tools[index],
                            isVisible: binding(for: collection.tools[index].title)
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(.controlBackgroundColor))
                        )

                        if index < collection.tools.count - 1 {
                            Divider()
                                .padding(.leading, 44)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.controlBackgroundColor))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.separatorColor), lineWidth: 0.5)
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .scale(scale: 0.95).combined(with: .opacity)
                ))
            }
        }
    }

    private func binding(for toolID: String) -> Binding<Bool> {
        Binding(
            get: { !self.hiddenToolIDs.contains(toolID) },
            set: { isVisible in
                withAnimation(.easeInOut(duration: 0.15)) {
                    if isVisible {
                        self.hiddenToolIDs.remove(toolID)
                    } else {
                        self.hiddenToolIDs.insert(toolID)
                    }
                }
            }
        )
    }
}

// MARK: - 工具行视图

private struct ToolRowView: View {
    let tool: Tool
    @Binding var isVisible: Bool
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            // 工具图标
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(.quaternary)
                    .frame(width: 28, height: 28)

                Text(String(tool.title.prefix(1)).uppercased())
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            // 工具信息
            VStack(alignment: .leading, spacing: 1) {
                Text(LocalizedStringKey(tool.title))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)
            }

            Spacer()

            // 开关
            Toggle("", isOn: $isVisible)
                .toggleStyle(.switch)
                .controlSize(.small)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovered ? Color.accentColor.opacity(0.08) : .clear)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovered = hovering
            }
        }
    }
}

#Preview {
    @Previewable @State var toolManager = ToolManager()

    VisibleToolsSettingsView()
        .environment(toolManager)
}
