//
//  URL.swift
//  DevForge
//
//  Created by resistanceto on 2025-08-29.
//

import SwiftUI

struct URLEncoderDecoderView: View {
    // MARK: - State Properties
        
    @State private var plainText: String = "https://zhaohe.org/"
    @State private var encodedText: String = ""
    @State private var errorMessage: String?
        
    // 分别用于两个方向的防抖
    @State private var plainTextDebounceTimer: Timer?
    @State private var encodedTextDebounceTimer: Timer?

    // MARK: - Body
        
    var body: some View {
        VStack(spacing: 0) {
            // 使用我们之前创建的通用布局视图
            TwoTieredLayout {
                // MARK: - Left Panel (Decoded)

                EditorLayoutView(
                    title: "Decoded URL",
                    text: $plainText,
                    pasteAction: { Utils.paste($plainText) },
                    clearAction: { Utils.clear($plainText) },
                    copyAction: { Utils.copy(plainText) }
                )
            } right: {
                // MARK: - Right Panel (Encoded)

                EditorLayoutView(
                    title: "Encoded URL",
                    text: $encodedText,
                    pasteAction: { Utils.paste($encodedText) },
                    copyAction: { Utils.copy(encodedText) }
                )
            }
                
            // 错误信息显示
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.top, 10)
            }
        }
        .padding()
        // 监听【Decoded】框的变化 -> 执行编码
        .onChange(of: plainText) { oldValue, newValue in
            onPlainTextChange(oldValue: oldValue, newValue: newValue)
        }
        // 监听【Encoded】框的变化 -> 执行解码
        .onChange(of: encodedText) { oldValue, newValue in
            onEncodedTextChange(oldValue: oldValue, newValue: newValue)
        }
        .onAppear {
            onPlainTextChange(oldValue: "", newValue: plainText)
        }
    }
        
    // MARK: - Logic
        
    private func onPlainTextChange(oldValue: String, newValue: String) {
        plainTextDebounceTimer?.invalidate()
        plainTextDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
            let newEncoded = encode(newValue)
            if newEncoded != self.encodedText {
                self.encodedText = newEncoded
            }
            if !newValue.isEmpty { self.errorMessage = nil }
        }
    }

    private func onEncodedTextChange(oldValue: String, newValue: String) {
        encodedTextDebounceTimer?.invalidate()
        encodedTextDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
            do {
                let newDecoded = try decode(newValue)
                if newDecoded != self.plainText {
                    self.plainText = newDecoded
                }
                self.errorMessage = nil
            } catch let error as ConversionError {
                self.errorMessage = error.errorDescription
            } catch {}
        }
    }
        
    // 简单的错误类型
    enum ConversionError: Error, LocalizedError {
        case invalidEncoding
        var errorDescription: String? { "Invalid percent-encoded string." }
    }
        
    /// 编码: String -> Percent-Encoded String
    private func encode(_ string: String) -> String {
        // RFC 3986 定义了URL中不需要编码的“非保留”字符。
        // 这是最标准、兼容性最好的编码字符集。
        let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~")
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? ""
    }
        
    /// 解码: Percent-Encoded String -> String
    private func decode(_ encodedString: String) throws -> String {
        guard !encodedString.isEmpty else { return "" }
        guard let decoded = encodedString.removingPercentEncoding else {
            throw ConversionError.invalidEncoding
        }
        return decoded
    }
}

#Preview {
    URLEncoderDecoderView()
}
