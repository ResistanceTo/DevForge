//
//  ToolManager.swift
//  DevForge
//
//  Created by resistanceto on 2025-08-28.
//

import Combine
import SwiftUI

@MainActor @Observable
final class ToolManager {
    // 展示到主界面上的工具库
    var visibleCollections: [ToolCollection] = []
        
    // 设置中的工具库
    var masterCollections: [ToolCollection]

    // 3. 用于监听 UserDefaults 变化的订阅者
    private var settingsObserver: AnyCancellable?
    
    // ✅ 新增：添加和 SettingsView 一样的计算属性来解码 Data
    private var hiddenToolIDs: Set<String> {
        let data = UserDefaults.standard.data(forKey: "hiddenToolIDs") ?? Data()
        return (try? JSONDecoder().decode(Set<String>.self, from: data)) ?? []
    }
    
    init() {
        masterCollections = Self.toolList()
        applyFilter()
            
        settingsObserver = NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .sink { _ in
                // 无需再手动切换到主线程，因为整个类已经是 @MainActor
                self.applyFilter()
            }
    }
    
    /// 应用筛选逻辑
    private func applyFilter() {
        var filteredCollections = [ToolCollection]()
            
        // 遍历完整的工具列表
        for collection in masterCollections {
            // 筛选出未被隐藏的工具
            let visibleTools = collection.tools.filter { tool in
                !hiddenToolIDs.contains(tool.title) // 假设 Tool 有一个唯一的 titleKey
            }
                
            // 如果这个分类下还有可见的工具，才把这个分类加到结果中
            if !visibleTools.isEmpty {
                filteredCollections.append(
                    ToolCollection(category: collection.category, tools: visibleTools)
                )
            }
        }
            
        // 更新对外发布的属性，SwiftUI 会自动刷新使用到它的视图
        visibleCollections = filteredCollections
    }
}

private extension ToolManager {
    static func toolList() -> [ToolCollection] {
        return [
            ToolCollection(
                category: .converters,
                tools: [
                    Tool(
                        title: "Time",
                        icon: "tool.time",
                        viewProvider: { TimeConverterView() }
                    ),
                    Tool(
                        title: "Base Converter",
                        icon: "tool.baseConverter",
                        viewProvider: { BaseConverterView() }
                    )
                ]
            ),
            ToolCollection(
                category: .generators,
                tools: [
                    Tool(
                        title: "UUID",
                        icon: "tool.uuid",
                        viewProvider: { UUIDGeneratorView() }
                    ),
                    Tool(
                        title: "QR Code",
                        icon: "tool.qrcode",
                        viewProvider: { QRCodeGeneratorView() }
                    ),
                    Tool(
                        title: "Read QR Code",
                        icon: "tool.readQrcode",
                        viewProvider: { ReadQRCodeView() }
                    ),
                    Tool(
                        title: "Hash",
                        icon: "tool.hash",
                        viewProvider: { HashGeneratorView() }
                    ),
                    Tool(
                        title: "Lorem Ipsum",
                        icon: "tool.LoremIpsum",
                        viewProvider: { LoremIpsumGeneratorView() }
                    ),
                    Tool(
                        title: "File Checksum",
                        icon: "tool.checksum",
                        viewProvider: { FileChecksumView() }
                    )
                ]
            ),
            ToolCollection(
                category: .formatters,
                tools: [
                    Tool(
                        title: "JSON",
                        icon: "tool.json",
                        viewProvider: { JSONFormatterView() }
                    ),
                    Tool(
                        title: "XML",
                        icon: "tool.xml",
                        viewProvider: { XMLFormatterView() }
                    ),
                    Tool(
                        title: "Plist",
                        icon: "tool.plist",
                        viewProvider: { PlistFormatterView() }
                    ),
                    Tool(
                        title: "URL Parser",
                        icon: "tool.urlParser",
                        viewProvider: { URLFormatterView() }
                    )
                ]
            ),
            ToolCollection(
                category: .encoders_decoders,
                tools: [
                    Tool(
                        title: "Base64",
                        icon: "tool.base64",
                        viewProvider: { Base64EncoderDecoderView() }
                    ),
                    Tool(
                        title: "URL",
                        icon: "tool.link",
                        viewProvider: { URLEncoderDecoderView() }
                    ),
                    Tool(
                        title: "JWT",
                        icon: "tool.jwt",
                        viewProvider: { JWTEncoderDecoderView() }
                    ),
                    Tool(
                        title: "HTML",
                        icon: "tool.html",
                        viewProvider: { HTMLEncoderDecoderView() }
                    )
                ]
            ),
            ToolCollection(
                category: .text,
                tools: [
                    Tool(
                        title: "Regex",
                        icon: "tool.regex",
                        viewProvider: { TextRegexView() }
                    ),
                    Tool(
                        title: "Text Diff",
                        icon: "tool.textDiff",
                        viewProvider: { TextDiffView() }
                    ),
                    Tool(
                        title: "Text Transformation",
                        icon: "tool.textTransformation",
                        viewProvider: { TextTransformationView() }
                    )
                ]
            ),
            ToolCollection(
                category: .media,
                tools: [
                    Tool(
                        title: "Color",
                        icon: "tool.color",
                        viewProvider: { MediaColorPickerView() }
                    )
                ]
            )
        ]
    }
}
