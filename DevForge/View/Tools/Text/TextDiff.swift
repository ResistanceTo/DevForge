//
//  TextDiff.swift
//  DevForge
//
//  Created by ResistanceTo on 2025/8/31.
//

import SwiftUI

// 定义差异对比的模式
enum DiffStyle: String, CaseIterable, Identifiable {
    case characters = "By Characters"
    case words = "By Words"
    case lines = "By Lines"
    var id: Self { self }
}

struct TextDiffView: View {
    // MARK: - State Properties

    @State private var input1: String = "Hello World!"
    @State private var input2: String = "Hello DevForge!"
    @State private var diffStyle: DiffStyle = .characters

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            // 顶部配置栏
            self.configSection

            // 双栏输入区域
            TwoTieredLayout {
                EditorLayoutView(title: "Input 1", text: self.$input1, pasteAction: { self.paste(to: self.$input1) }, clearAction: { self.input1 = "" })
            } right: {
                EditorLayoutView(title: "Input 2", text: self.$input2, pasteAction: { self.paste(to: self.$input2) }, clearAction: { self.input2 = "" })
            }

            // 输出区域
            self.outputSection
        }
        .padding()
        .onAppear(perform: self.loadSample)
    }

    // MARK: - Subviews

    /// 顶部配置区域
    private var configSection: some View {
        HStack {
            Text("Diff Style").font(.headline).foregroundColor(.secondary)
            Picker("", selection: self.$diffStyle) {
                ForEach(DiffStyle.allCases) { style in
                    Text(style.rawValue).tag(style)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 300)
            Spacer()
        }
    }

    /// 结果输出区域
    private var outputSection: some View {
        VStack(alignment: .leading) {
            Text("Output")
                .font(.headline)
                .foregroundColor(.secondary)

            ScrollView {
                // 调用 @ViewBuilder 来构建高亮文本
                self.diffOutputView
                    .padding(12)
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(Color(.textBackgroundColor))
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
            .textSelection(.enabled)
        }
    }

    /// ✅【核心】根据输入和模式，动态计算并构建高亮文本视图
    @ViewBuilder
    private var diffOutputView: some View {
        switch self.diffStyle {
        case .characters:
            // 按字符对比
            buildStyledText(from: self.input1, to: self.input2, style: self.diffStyle)
        case .words:
            // 按单词对比
            buildStyledText(from: self.input1, to: self.input2, style: self.diffStyle)
        case .lines:
            // 按行对比
            buildStyledText(from: self.input1, to: self.input2, style: self.diffStyle)
        }
    }

    // MARK: - Logic

    private func loadSample() {
        self.input1 = "Hello World!"
        self.input2 = "Hello DevToys!"
    }

    private func paste(to binding: Binding<String>) {
        if let pastedString = NSPasteboard.general.string(forType: .string) {
            binding.wrappedValue = pastedString
        }
    }
}

// MARK: - Text Styling Helpers (最可靠的最终版)

extension TextDiffView {
    /// ✅【最终修正算法】根据输入和输出字符串，构建高亮Text视图
    private func buildStyledText(from oldString: String, to newString: String, style: DiffStyle) -> some View {
        let difference: CollectionDifference<String>
        let oldComponents: [String]
        let separator: String

        // 1. 根据模式，将字符串分解为组件数组
        switch style {
        case .characters:
            // 按字符对比，每个字符作为一个“单词”
            oldComponents = oldString.map { String($0) }
            let newComponents = newString.map { String($0) }
            difference = newComponents.difference(from: oldComponents)
            separator = ""
        case .words:
            oldComponents = oldString.components(separatedBy: .whitespaces)
            let newComponents = newString.components(separatedBy: .whitespaces)
            difference = newComponents.difference(from: oldComponents)
            separator = " "
        case .lines:
            oldComponents = oldString.components(separatedBy: .newlines)
            let newComponents = newString.components(separatedBy: .newlines)
            difference = newComponents.difference(from: oldComponents)
            separator = "\n"
        }

        // 2. 使用 difference.removals 和 .insertions 来构建一个带标记的数组
        var components = oldComponents.map { DiffComponent(text: $0, type: .same) }

        for change in difference {
            switch change {
            case .remove(let offset, _, _):
                components[offset].type = .removed
            case .insert(let offset, let element, _):
                components.insert(DiffComponent(text: element, type: .inserted), at: offset)
            }
        }

        // 在 buildStyledText 函数的末尾
        // 3. 遍历带标记的数组，拼接最终的 Text
        return components.enumerated().reduce(Text("")) { partialResult, item in
            let (index, component) = item
            var text = Text(component.text)
            switch component.type {
            case .same:
                break
            case .removed:
                text = text.foregroundColor(.red).strikethrough()
            case .inserted:
                text = text.foregroundColor(.green)
            }

            // ✅ 优化点: 只有在不是最后一个组件时才添加分隔符
            if index < components.count - 1 {
                return partialResult + text + Text(separator)
            } else {
                return partialResult + text
            }
        }
    }

    // 用于标记差异组件的辅助结构体
    private struct DiffComponent {
        let text: String
        var type: ChangeType
    }

    private enum ChangeType {
        case same, removed, inserted
    }
}

#Preview {
    TextDiffView()
}
