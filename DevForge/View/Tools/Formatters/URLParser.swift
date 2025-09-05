//
//  URLParser.swift
//  DevForge
//
//  Created by ResistanceTo on 2025/8/31.
//

import SwiftUI

struct URLFormatterView: View {
    // MARK: - State Properties
    
    @State private var inputText: String = "https://zhaohe.org/about/"
    
    // 核心状态：一个可选的 URLComponents 对象。所有输出都从这里派生。
    @State private var components: URLComponents?
    
    @State private var debounceTimer: Timer?
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 输入区域
            EditorLayoutView(
                title: "URL String",
                text: $inputText,
                pasteAction: { Utils.paste($inputText) },
                clearAction: { Utils.clear($inputText) }
            )
            .frame(minHeight: 100, maxHeight: 150)
            
            // 输出区域
            resultsList
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
    
    /// 结果列表
    @ViewBuilder
    private var resultsList: some View {
        VStack(alignment: .leading) {
            Text("Parsed Components")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // 使用 List 来展示解析结果
            if let comps = components {
                List {
                    // 基本组件
                    componentRow(title: "Scheme", value: comps.scheme)
                    componentRow(title: "Host", value: comps.host)
                    componentRow(title: "Port", value: comps.port?.description)
                    componentRow(title: "Path", value: comps.path)
                    componentRow(title: "User", value: comps.user)
                    componentRow(title: "Password", value: comps.password)
                    componentRow(title: "Fragment", value: comps.fragment)
                    
                    // 单独处理查询参数
                    if let queryItems = comps.queryItems, !queryItems.isEmpty {
                        Section("Query Parameters (\(queryItems.count))") {
                            ForEach(queryItems, id: \.self) { item in
                                queryItemRow(item: item)
                            }
                        }
                    }
                }
                .listStyle(.bordered(alternatesRowBackgrounds: true))
            } else {
                // 如果解析失败或输入为空
                Text("Enter a valid URL to see its components.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    /// 可复用的单行组件视图
    @ViewBuilder
    private func componentRow(title: String, value: String?) -> some View {
        // 如果值不存在，则不显示这一行
        if let value = value, !value.isEmpty {
            HStack {
                Text(title)
                    .foregroundColor(.secondary)
                Spacer()
                Text(value)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                
                Button(action: { Utils.copy(value) }) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.borderless)
            }
        }
    }
    
    /// 单独为查询参数设计的行视图
    private func queryItemRow(item: URLQueryItem) -> some View {
        HStack {
            Text(item.name)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.bold)
            Spacer()
            if let value = item.value {
                Text(value)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)
                
                Button(action: { Utils.copy(value) }) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.borderless)
            }
        }
    }

    // MARK: - Logic & Actions
    
    private func handleTextChange(newValue: String) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
            parseURL(from: newValue)
        }
    }
    
    /// 核心解析逻辑
    private func parseURL(from string: String) {
        if string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            components = nil
            return
        }
        components = URLComponents(string: string)
    }
}
