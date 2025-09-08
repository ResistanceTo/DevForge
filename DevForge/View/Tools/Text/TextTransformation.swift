//
//  TextTransformation.swift
//  DevForge
//
//  Created by ResistanceTo on 2025/8/31.
//

import SwiftUI

// 定义所有支持的大小写转换样式
enum CaseStyle: String, CaseIterable, Identifiable {
    case sentence = "Sentence case"
    case lower = "lower case"
    case upper = "UPPER CASE"
    case title = "Title Case"
    case camel = "camelCase"
    case pascal = "PascalCase"
    case snake = "snake_case"
    case constant = "CONSTANT_CASE"
    case kebab = "kebab-case"
    
    var id: Self { self }
}

struct TextTransformationView: View {
    // MARK: - State Properties

    @State private var inputText: String = "Hello DevForge!"
    @State private var selectedStyle: CaseStyle = .sentence
    
    // MARK: - Computed Properties
    
    // 输出文本现在是一个计算属性，当输入或样式改变时自动更新
    private var outputText: String {
        convert(inputText, to: selectedStyle)
    }
    
    // 文本信息统计也是计算属性
    private var characterCount: Int { inputText.count }
    private var wordCount: Int {
        inputText.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }

    private var lineCount: Int {
        guard !inputText.isEmpty else { return 0 }
        return inputText.components(separatedBy: .newlines).count
    }

    private var byteCount: Int {
        inputText.data(using: .utf8)?.count ?? 0
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            // 1. 顶部转换样式选择区域
            controlsSection
            
            // 2. 双栏输入输出区域
            TwoTieredLayout {
                EditorLayoutView(title: "Input", text: $inputText, pasteAction: { Utils.paste($inputText) }, clearAction: { inputText = "" })
            } right: {
                EditorLayoutView(title: "Output", text: .constant(outputText), isReadOnly: true, copyAction: { Utils.copy(outputText) })
            }
            
            // 3. 底部信息统计区域
            infoSection
        }
        .padding()
    }
    
    // MARK: - Subviews
    
    /// 顶部控制区域，使用 LazyVGrid 创建按钮网格
    private var controlsSection: some View {
        VStack(alignment: .leading) {
            Text("Transform").font(.headline).foregroundColor(.secondary)
            
            // 定义网格布局，每行自适应，最小列宽120
            let columns = [GridItem(.adaptive(minimum: 120))]
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                ForEach(CaseStyle.allCases) { style in
                    Button(action: {
                        withAnimation { selectedStyle = style }
                    }) {
                        Text(style.rawValue)
                            .frame(maxWidth: .infinity)
                    }
                    // 根据当前选中的样式，高亮对应的按钮
                    .buttonStyle(.bordered)
                    .tint(selectedStyle == style ? .accentColor : .secondary)
                }
            }
        }
    }
    
    /// 底部信息统计区域
    private var infoSection: some View {
        VStack(alignment: .leading) {
            Text("Information").font(.headline).foregroundColor(.secondary)
            HStack(spacing: 20) {
                infoItem(title: "Characters", value: "\(characterCount)")
                infoItem(title: "Words", value: "\(wordCount)")
                infoItem(title: "Lines", value: "\(lineCount)")
                infoItem(title: "Bytes", value: "\(byteCount)")
                Spacer()
            }
        }
    }
    
    /// 可复用的信息展示项
    private func infoItem(title: LocalizedStringKey, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption).foregroundColor(.secondary)
            Text(value).font(.system(.body, design: .monospaced)).fontWeight(.semibold)
        }
    }
}

// MARK: - Case Conversion Logic

private extension TextTransformationView {
    /// ✅【新算法】将文本拆分为单词数组的辅助函数，不使用正则表达式
    func components(from text: String) -> [String] {
        // 1. 先将标准分隔符统一替换为空格
        let initialSeparators = CharacterSet(charactersIn: "_-")
        let processedString = text.components(separatedBy: initialSeparators).joined(separator: " ")
           
        // 2. 在大小写变化处插入空格 (e.g., "HelloWorld" -> "Hello World")
        var result = ""
        for (index, character) in processedString.enumerated() {
            let nextIndex = processedString.index(after: processedString.startIndex)
            if index > 0, character.isUppercase, processedString[nextIndex].isLowercase {
                result.append(" ")
            }
            result.append(character)
        }
           
        // 3. 按最终的空格分割，并移除空字符串
        return result.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
    }
    
    /// 核心转换函数
    func convert(_ text: String, to style: CaseStyle) -> String {
        guard !text.isEmpty else { return "" }
        
        let words = components(from: text).map { $0.lowercased() }

        switch style {
        case .sentence:
            return text.prefix(1).uppercased() + text.dropFirst()
        case .lower:
            return text.lowercased()
        case .upper:
            return text.uppercased()
        case .title:
            return text.capitalized
        case .camel:
            return words.enumerated().map { index, word in
                index == 0 ? word : word.capitalized
            }.joined()
        case .pascal:
            return words.map { $0.capitalized }.joined()
        case .snake:
            return words.joined(separator: "_")
        case .constant:
            return words.map { $0.uppercased() }.joined(separator: "_")
        case .kebab:
            return words.joined(separator: "-")
        }
    }
}

#Preview {
    TextTransformationView()
}
