//
//  Utils.swift
//  DevForge
//
//  Created by ResistanceTo on 2025/8/30.
//

import CommonCrypto
import CryptoKit
import SwiftUI
import UniformTypeIdentifiers

@MainActor
enum Utils {
    static func copy(_ text: String) {
        guard !text.isEmpty else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)

        HUDManager.shared.show(message: "Copied")
    }

    static func paste(_ text: Binding<String>) {
        if let pastedString = NSPasteboard.general.string(forType: .string) {
            text.wrappedValue = pastedString
        }
    }

    static func clear(_ texts: Binding<String>?...) {
        for textBinding in texts {
            textBinding?.wrappedValue = ""
        }
    }

    static func saveFile(_ text: String, type: [UTType], name: String) {
        if text == "" { return }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = type
        savePanel.nameFieldStringValue = "\(name)_\(Date().formatted(.dateTime))"

        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    try text.write(to: url, atomically: true, encoding: .utf8)
                } catch {
                    print("Failed to save file: \(error.localizedDescription)")
                }
            }
        }
    }

    /// 根据算法类型计算哈希值
    static func computeHash(from data: Data, for algorithm: HashAlgorithm) -> String {
        switch algorithm {
        case .md5:
            var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            data.withUnsafeBytes { _ = CC_MD5($0.baseAddress, CC_LONG(data.count), &digest) }
            return digest.map { String(format: "%02x", $0) }.joined()
        case .sha1:
            return Insecure.SHA1.hash(data: data).map { String(format: "%02x", $0) }.joined()
        case .sha256:
            return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        case .sha384:
            return SHA384.hash(data: data).map { String(format: "%02x", $0) }.joined()
        case .sha512:
            return SHA512.hash(data: data).map { String(format: "%02x", $0) }.joined()
        }
    }
}
