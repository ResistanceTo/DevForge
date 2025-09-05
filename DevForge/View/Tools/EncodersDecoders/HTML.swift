//
//  HTML.swift
//  DevForge
//
//  Created by ResistanceTo on 2025/8/31.
//

import SwiftUI

struct HTMLEncoderDecoderView: View {
    // MARK: - State Properties
        
    @State private var plainText: String = ""
    @State private var encodedText: String = ""
    @State private var errorMessage: String?
        
    @State private var plainTextDebounceTimer: Timer?
    @State private var encodedTextDebounceTimer: Timer?

    // MARK: - Body
        
    var body: some View {
        VStack(spacing: 16) {
            TwoTieredLayout {
                // 左侧：纯文本
                EditorLayoutView(
                    title: "Plain Text",
                    text: $plainText,
                    pasteAction: { Utils.paste($plainText) },
                    clearAction: { Utils.clear($plainText) }
                )
            } right: {
                // 右侧：HTML 实体编码文本
                EditorLayoutView(
                    title: "HTML Entities",
                    text: $encodedText,
                    pasteAction: { Utils.paste($encodedText) },
                    clearAction: { Utils.clear($encodedText) },
                    copyAction: { Utils.copy(encodedText) }
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
        .onChange(of: plainText) { oldValue, newValue in
            onPlainTextChange(oldValue: oldValue, newValue: newValue)
        }
        .onChange(of: encodedText) { oldValue, newValue in
            onEncodedTextChange(oldValue: oldValue, newValue: newValue)
        }
        .onAppear {
            plainText = "<div>Hello DevForge! It's \(Date.now.formatted(date: .abbreviated, time: .shortened)).</div>"
        }
    }
        
    // MARK: - Logic & Actions
        
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
        case decodingFailed
        var errorDescription: String? { "Failed to decode HTML entities." }
    }
        
    /// 编码: Plain String -> HTML Entities
    private func encode(_ string: String) -> String {
        var result = ""
        // 预分配容量以提高性能
        result.reserveCapacity(Int(Double(string.count) * 1.1))
            
        // 只转换最核心的5个字符
        for char in string {
            switch char {
            case "&": result.append("&amp;")
            case "<": result.append("&lt;")
            case ">": result.append("&gt;")
            case "\"": result.append("&quot;")
            case "'": result.append("&#39;") // &apos; in XML/XHTML, but &#39; is safer for HTML
            default: result.append(char)
            }
        }
        return result
    }
        
    /// 解码: HTML Entities -> Plain String
    private func decode(_ htmlString: String) throws -> String {
        guard !htmlString.isEmpty else { return "" }
        guard let data = htmlString.data(using: .utf8) else {
            return htmlString // 如果无法转为Data，返回原文
        }
            
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
            
        do {
            let attributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
            return attributedString.string
        } catch {
            throw ConversionError.decodingFailed
        }
    }
}

#Preview {
    HTMLEncoderDecoderView()
}
