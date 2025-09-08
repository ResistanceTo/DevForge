//
//  JWT.swift
//  DevForge
//
//  Created by ResistanceTo on 2025/8/30.
//

import SwiftUI

struct JWTEncoderDecoderView: View {
    struct JWTResult {
        var header: String
        var payload: String
        var signature: String
        var interpretedClaims: [InterpretedClaim]
        
        struct InterpretedClaim: Identifiable {
            let id = UUID()
            let key: String
            let value: String
            let description: String
        }
    }
    
    // MARK: - State Properties

    @State private var inputText: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjE3NTYyMzkwMjJ9.h7a1jZ84_OK--2Bf_s-KAbT2aC2dOci-M0y0K0oUsGo"
    @State private var jwtResult: JWTResult?
    @State private var errorMessage: String?
    
    @State private var debounceTimer: Timer?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            EditorLayoutView(
                title: "Input",
                text: self.$inputText,
                pasteAction: { Utils.paste(self.$inputText) },
                clearAction: { Utils.clear(self.$inputText) }
            )
            .frame(minHeight: 100, maxHeight: 200)
            
            self.resultsSection
        }
        .padding()
        .onChange(of: self.inputText) { _, newValue in
            self.handleTextChange(newValue: newValue)
        }
        .onAppear {
            self.handleTextChange(newValue: self.inputText)
        }
    }
    
    @ViewBuilder
    private var resultsSection: some View {
        VStack(alignment: .leading) {
            Text("Output")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if let result = jwtResult {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        self.headerPayloadCard(title: "Header (Algorithm & Token Type)", json: result.header)
                        self.headerPayloadCard(title: "Payload (Data & Claims)", json: result.payload)
                        if !result.interpretedClaims.isEmpty {
                            self.interpretedClaimsCard(claims: result.interpretedClaims)
                        }
                        self.signatureCard(signature: result.signature)
                    }
                }
            } else if let error = errorMessage {
                self.errorCard(message: error)
            } else {
                self.placeholderCard
            }
        }
    }
    
    /// 可复用的、用于展示 Header, Payload 和 Signature 的卡片
    private func headerPayloadCard(title: String, json: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: { Utils.copy(json) }) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.borderless)
            }
            
            // 使用我们熟悉的只读编辑器样式
            ScrollView {
                Text(json)
                    .font(.monospaced(.body)())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
            }
            .textSelection(.enabled)
            .frame(minHeight: 80, maxHeight: 200)
            .background(Color(.textBackgroundColor))
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        }
    }

    /// 用于展示 Interpreted Claims 的卡片
    private func interpretedClaimsCard(claims: [JWTResult.InterpretedClaim]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Interpreted Claims")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
            
            VStack(spacing: 10) {
                ForEach(claims) { claim in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(claim.key)
                                .font(.system(.caption, design: .monospaced)).fontWeight(.bold)
                            Text("(\(claim.description))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Text(claim.value)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                    }
                    // 如果不是最后一个元素，则添加分割线
                    if claim.id != claims.last?.id {
                        Divider().padding(.vertical, 2)
                    }
                }
            }
            .padding(12)
            .background(Color(.textBackgroundColor))
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        }
    }

    /// 用于展示签名的卡片
    private func signatureCard(signature: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Signature")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: { Utils.copy(signature) }) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.borderless)
            }
            
            Text(signature)
                .font(.monospaced(.caption)())
                .foregroundColor(.secondary)
                .textSelection(.enabled)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true) // 允许多行显示
            
            Text("Signature cannot be verified without the secret key.")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.textBackgroundColor))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
    
    /// 初始状态下显示的占位卡片
    @ViewBuilder
    private var placeholderCard: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
            
            Text("Waiting for Input")
                .font(.headline)
            
            Text("Paste a JWT in the field above to see the decoded results.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // 应用与结果卡片一致的样式
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
    
    /// 解码失败时显示的错误卡片
    private func errorCard(message: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "xmark.octagon.fill")
                .font(.system(size: 50))
                .foregroundColor(.red) // 使用红色作为警示色
            
            Text("Decoding Failed")
                .font(.headline)
            
            Text(message)
                .font(.callout)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .foregroundColor(.primary) // 错误文本使用主色，确保可读性
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // 应用与结果卡片一致的样式
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }

    // MARK: - Logic
    
    private func handleTextChange(newValue: String) {
        self.debounceTimer?.invalidate()
        self.debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
            self.decodeJWT(from: newValue)
        }
    }

    private func decodeJWT(from jwtString: String) {
        if jwtString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.jwtResult = nil
            self.errorMessage = nil
            return
        }
        
        let parts = jwtString.split(separator: ".")
        guard parts.count == 3 else {
            self.jwtResult = nil
            self.errorMessage = "Invalid JWT structure. It must have three parts separated by dots."
            return
        }
        
        do {
            let headerJSON = try base64UrlDecodeAndBeautify(String(parts[0]))
            let payloadJSON = try base64UrlDecodeAndBeautify(String(parts[1]))
            let signature = String(parts[2])
            
            let claims = self.interpretClaims(from: payloadJSON)
            
            self.jwtResult = JWTResult(
                header: headerJSON,
                payload: payloadJSON,
                signature: signature,
                interpretedClaims: claims
            )
            self.errorMessage = nil
        } catch {
            self.jwtResult = nil
            self.errorMessage = error.localizedDescription
        }
    }
    
    /// Base64Url 解码并美化 JSON
    private func base64UrlDecodeAndBeautify(_ value: String) throws -> String {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // 补全 '=' 填充
        let length = Double(base64.lengthOfBytes(using: .utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = Int(requiredLength - length)
        if paddingLength > 0 {
            base64 += String(repeating: "=", count: paddingLength)
        }

        guard let data = Data(base64Encoded: base64) else {
            throw JWTError.invalidBase64Url
        }
        
//        return try self.beautifyJSON(from: data)
        return try FormatterUtils.beautifyJSONFromData(from: data)
    }

    /// 解析 Payload 中的标准声明
    private func interpretClaims(from payloadJSON: String) -> [JWTResult.InterpretedClaim] {
        var claims: [JWTResult.InterpretedClaim] = []
        guard let data = payloadJSON.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return []
        }
        
        let claimMappings: [(key: String, description: String, transform: (Any) -> String?)] = [
            ("exp", "Expiration Time", {
                guard let timestamp = ($0 as? NSNumber)?.doubleValue else { return nil }
                let date = Date(timeIntervalSince1970: timestamp)
                let status = date > .now ? "✅ Not Expired" : "❌ Expired"
                return "\(date.formatted(date: .abbreviated, time: .standard)) (\(status))"
            }),
            ("iat", "Issued At", {
                guard let timestamp = ($0 as? NSNumber)?.doubleValue else { return nil }
                return Date(timeIntervalSince1970: timestamp).formatted(date: .abbreviated, time: .standard)
            }),
            ("nbf", "Not Before", {
                guard let timestamp = ($0 as? NSNumber)?.doubleValue else { return nil }
                return Date(timeIntervalSince1970: timestamp).formatted(date: .abbreviated, time: .standard)
            }),
            ("iss", "Issuer", { $0 as? String }),
            ("sub", "Subject", { $0 as? String }),
            ("aud", "Audience", {
                if let string = $0 as? String { return string }
                if let array = $0 as? [String] { return array.joined(separator: ", ") }
                return nil
            })
        ]
        
        for mapping in claimMappings {
            if let value = jsonObject[mapping.key], let transformedValue = mapping.transform(value) {
                claims.append(.init(key: mapping.key, value: transformedValue, description: mapping.description))
            }
        }
        
        return claims
    }
    
    enum JWTError: Error, LocalizedError {
        case invalidBase64Url
        var errorDescription: String? { "Invalid Base64Url string." }
    }
}
