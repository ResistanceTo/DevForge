//
//  Base64.swift
//  DevForge
//
//  Created by resistanceto on 2025-08-27.
//

import SwiftUI

struct Base64EncoderDecoderView: View {
    // MARK: - State Properties

    // 为两个文本框分别创建状态
    @State private var plainText: String = ""
    @State private var base64Text: String = ""
    @State private var errorMessage: String?

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            TwoTieredLayout {
                EditorLayoutView(
                    title: "Plain Text",
                    text: $plainText,
                    pasteAction: { Utils.paste($plainText) },
                    clearAction: { Utils.clear($plainText) },
                    copyAction: { Utils.copy(plainText) }
                )
            } right: {
                EditorLayoutView(
                    title: "Base64",
                    text: $base64Text,
                    pasteAction: { Utils.paste($base64Text) },
                    copyAction: { Utils.copy(base64Text) }
                )
            }

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.top, 5)
            }
        }
        .padding()
        .debouncedOnChange(of: plainText,
                           perform: { newValue in
                               self.base64Text = encode(newValue)
                           })
        .debouncedOnChange(of: base64Text,
                           perform: { newValue in
                               self.plainText = try decode(newValue)
                           },
                           onError: $errorMessage)
        .onAppear {
            plainText = "Welcome to DevForge! The time is \(Date().formatted(.dateTime))."
        }
    }

    // MARK: - Logic

    /// 编码: String -> Base64
    private func encode(_ string: String) -> String {
        guard !string.isEmpty, let data = string.data(using: .utf8) else { return "" }
        return data.base64EncodedString()
    }

    /// 解码: Base64 -> String
    private func decode(_ base64String: String) throws -> String {
        guard !base64String.isEmpty else { return "" }
        guard let data = Data(base64Encoded: base64String) else {
            throw ToolError.parsingFailed(format: "Base64", reason: "Invalid Base64 string. Please check the input.")
        }
        return String(data: data, encoding: .utf8) ?? ""
    }
}

#Preview {
    Base64EncoderDecoderView()
}
