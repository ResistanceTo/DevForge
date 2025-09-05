//
//  Hash.swift
//  DevForge
//
//  Created by ResistanceTo on 2025/8/30.
//

import CommonCrypto // 用于支持传统的 MD5 算法
import CryptoKit // 现代、安全的哈希算法框架
import SwiftUI

// MARK: - 定义我们支持的哈希算法

enum HashAlgorithm: String, CaseIterable {
    case md5 = "MD5"
    case sha1 = "SHA-1"
    case sha256 = "SHA-256"
    case sha384 = "SHA-384"
    case sha512 = "SHA-512"
}

struct HashGeneratorView: View {
    // MARK: - 哈希结果的结构体

    struct HashResult: Identifiable {
        let id = UUID()
        let algorithm: HashAlgorithm
        var value: String = ""
    }

    // MARK: - State Properties

    @State private var inputText: String = "Hello DevForge!"
    @State private var hashResults: [HashResult] = HashAlgorithm.allCases.map { HashResult(algorithm: $0) }

    @State private var debounceTimer: Timer?

    // MARK: - Body

    var body: some View {
        // VStack 和 EditorLayoutView 的部分保持不变
        VStack(alignment: .leading, spacing: 16) {
            EditorLayoutView(
                title: "Input Text",
                text: $inputText,
                pasteAction: { Utils.paste($inputText) },
                clearAction: { Utils.clear($inputText) }
            )
            .frame(minHeight: 150, maxHeight: 250) // 可以给输入框一个最大高度

            resultsSection
        }
        .padding()
        .onChange(of: inputText) { _, newValue in
            handleTextChange(newValue: newValue)
        }
        .onAppear {
            handleTextChange(newValue: inputText)
        }
    }

    // MARK: - Subviews

    private var resultsSection: some View {
        VStack(alignment: .leading) {
            Text("Hash Results")
                .font(.headline)
                .foregroundColor(.secondary)

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(hashResults) { result in
                        hashRow(for: result)
                    }
                }
            }
        }
    }

    private func hashRow(for result: HashResult) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(result.algorithm.rawValue)
                    .font(.system(.body, design: .monospaced, weight: .bold)) // 算法名加粗
                    .foregroundColor(.secondary)
                Spacer()
                copyButton(for: result.value)
            }

            Text(result.value.isEmpty ? "..." : result.value)
                .font(.system(.body, design: .monospaced)) // 等宽字体
                .foregroundColor(result.value.isEmpty ? .secondary : .primary)
                .textSelection(.enabled) // 允许用户自由选择
                .lineLimit(nil) // 允许无限换行
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color(.textBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }

    /// 为单个结果创建拷贝按钮
    private func copyButton(for value: String) -> some View {
        Button(action: { Utils.copy(value) }) {
            Image(systemName: "doc.on.doc")
        }
        .frame(height: 18)
        .buttonStyle(.borderless)
        .disabled(value.isEmpty)
    }

    // MARK: - Logic

    private func handleTextChange(newValue: String) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
            calculateHashes()
        }
    }

    /// 计算所有哈希值
    private func calculateHashes() {
        guard let data = inputText.data(using: .utf8) else { return }

        for i in hashResults.indices {
            hashResults[i].value = Utils.computeHash(from: data, for: hashResults[i].algorithm)
        }
    }
}

#Preview {
    HashGeneratorView()
}
