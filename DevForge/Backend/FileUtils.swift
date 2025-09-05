//
//  FileUtils.swift
//  DevForge
//
//  Created by resistanceto on 2025-09-03.
//

import SwiftUI
import UniformTypeIdentifiers

/// 专门处理文件系统交互的工具集
@MainActor
enum FileUtils {
    /// 弹出一个保存面板，让用户选择位置来保存字符串内容。
    static func saveFile(
        content: String,
        allowedFileTypes: [UTType],
        suggestedName: String
    ) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = allowedFileTypes
        savePanel.nameFieldStringValue = suggestedName

        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    try content.write(to: url, atomically: true, encoding: .utf8)
                    HUDManager.shared.show(message: "Saved Successfully")
                } catch {
                    HUDManager.shared.show(message: "Save Failed", systemImage: "xmark.circle.fill")
                    print("FileUtils.saveFile failed: \(error.localizedDescription)")
                }
            }
        }
    }
}
