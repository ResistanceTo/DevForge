//
//  Tool.swift
//  DevForge
//
//  Created by resistanceto on 2025-08-28.
//

import SwiftUI

enum ToolCategory: String, CaseIterable, Identifiable {
    case home
    case converters
    case encoders_decoders
    case formatters
    case generators
    case text
    case graphic
    case media

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .home: "Home"
        case .converters: "Converters"
        case .encoders_decoders: "Encoders / Decoders"
        case .formatters: "Formatters"
        case .generators: "Generators"
        case .text: "ToolCategory.Text"
        case .graphic: "Graphic"
        case .media: "Media"
        }
    }
}

struct ToolCollection: Identifiable {
    var id: ToolCategory { category }
    let category: ToolCategory
    let tools: [Tool]
}

typealias ToolViewProvider = () -> any View

/// 每个功能的基础结构
struct Tool: Identifiable, Equatable, Hashable {
    let id = UUID()
//    let category: ToolCategory
    let title: String
    let icon: String
    let viewProvider: ToolViewProvider

    init(
        title: String,
        icon: String,
        viewProvider: @escaping ToolViewProvider
    ) {
        self.title = title
        self.icon = icon
        self.viewProvider = viewProvider
    }

    var localizedTitle: String {
        return String(localized: String.LocalizationValue(title))
    }

    @ViewBuilder
    var content: some View {
        // AnyView在这里可以很好地将闭包返回的`any View`转换为一个具体的类型，
        // 供ViewBuilder使用。
        AnyView(viewProvider())
    }

    // 实现 Equatable 协议
    static func == (lhs: Tool, rhs: Tool) -> Bool {
        lhs.id == rhs.id
    }

    // 实现 Hashable 协议
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
