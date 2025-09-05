//
//  LoremIpsum.swift
//  DevForge
//
//  Created by ResistanceTo on 2025/8/31.
//

import SwiftUI

// 定义生成内容的类型
enum GenerationType: String, CaseIterable, Identifiable {
    case words = "Words"
    case sentences = "Sentences"
    case paragraphs = "Paragraphs"
    var id: Self { self }
}

struct LoremIpsumGeneratorView: View {
    // MARK: - State Properties
    
    @State private var generationType: GenerationType = .paragraphs
    @State private var amount: Int = 3
    @State private var outputText: String = ""

    // MARK: - Source Text
    
    // 经典的 Lorem Ipsum 源文本
    private let loremIpsumSource = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 配置区域
            configSection
            
            // 生成按钮
            generateButton
            
            // 输出区域
            EditorLayoutView(
                title: "Output",
                text: $outputText,
                isReadOnly: true,
                copyAction: { Utils.copy(outputText) }
            )
        }
        .padding()
        .onAppear(perform: generate) // 视图出现时自动生成一次
    }
    
    // MARK: - Subviews
    
    /// 顶部配置区域
    private var configSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Configuration")
                .font(.headline)
                .foregroundColor(.secondary)

            // 使用 LabeledContent 来创建带标签的行，样式更标准
            LabeledContent {
                Picker("Type", selection: $generationType) {
                    ForEach(GenerationType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .labelsHidden()
            } label: {
                Label("Type", systemImage: "text.justify.left")
            }
            
            Divider()
            
            LabeledContent {
                Stepper("", value: $amount, in: 1...100)
            } label: {
                Label("Amount: \(amount)", systemImage: "number")
            }
        }
        .padding()
        .background(Color(.textBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
    
    /// 生成按钮
    private var generateButton: some View {
        Button(action: generate) {
            Label("Generate", systemImage: "arrow.clockwise.circle")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    // MARK: - Logic
    
    /// 核心生成函数
    private func generate() {
        // 预处理，将源文本分割为干净的单词数组
        let sourceWords = loremIpsumSource
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: ".", with: "")
            .lowercased()
            .components(separatedBy: .whitespaces)

        var result: [String] = []
        
        switch generationType {
        case .words:
            // 生成指定数量的单词
            result.append(
                (0..<amount).map { _ in sourceWords.randomElement()! }.joined(separator: " ")
            )
        case .sentences:
            // 生成指定数量的句子
            for _ in 0..<amount {
                // 每句话的单词数随机，看起来更自然
                let sentenceLength = Int.random(in: 8...15)
                let sentence = (0..<sentenceLength).map { _ in sourceWords.randomElement()! }.joined(separator: " ")
                // 首字母大写并添加句号
                result.append(sentence.prefix(1).capitalized + sentence.dropFirst() + ".")
            }
        case .paragraphs:
            // 生成指定数量的段落
            for _ in 0..<amount {
                // 每个段落的句子数随机
                let paragraphLength = Int.random(in: 4...7)
                var sentences: [String] = []
                for _ in 0..<paragraphLength {
                    let sentenceLength = Int.random(in: 8...15)
                    let sentence = (0..<sentenceLength).map { _ in sourceWords.randomElement()! }.joined(separator: " ")
                    sentences.append(sentence.prefix(1).capitalized + sentence.dropFirst() + ".")
                }
                result.append(sentences.joined(separator: " "))
            }
        }
        
        // 根据类型，用不同的分隔符拼接最终结果
        let separator = (generationType == .paragraphs) ? "\n\n" : " "
        outputText = result.joined(separator: separator)
    }
}

#Preview {
    LoremIpsumGeneratorView()
}
