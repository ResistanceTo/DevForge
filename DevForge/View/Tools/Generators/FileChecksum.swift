//
//  FileChecksum.swift
//  DevForge
//
//  Created by resistanceto on 2025-09-03.
//

import SwiftUI

struct FileChecksumView: View {
    // 用于比对结果的状态
    enum ComparisonStatus {
        case idle, match, mismatch
        
        var color: Color {
            switch self {
            case .idle: .clear
            case .match: .green
            case .mismatch: .red
            }
        }
        
        var text: String {
            switch self {
            case .idle: ""
            case .match: "✅ Checksums match"
            case .mismatch: "❌ Checksums do not match"
            }
        }
    }

    // MARK: - State Properties

    @State private var selectedFile: URL?
    @State private var errorMessage: String?
    @State private var selectedFileData: Data?
        
    @State private var selectedAlgorithm: HashAlgorithm = .md5
    @State private var isUppercase: Bool = true
        
    @State private var calculatedHash: String = ""
    @State private var comparisonHash: String = ""
        
    @State private var isCalculating: Bool = false
    @State private var comparisonStatus: ComparisonStatus = .idle
        
    // MARK: - Body

    var body: some View {
        ScrollView {
            // ✅ 1. 使用一个 VStack 作为所有内容的容器
            VStack(alignment: .leading, spacing: 20) {
                // 将所有 Section 的内容都放入这一个卡片中
                configSection
                Divider()
                ReadFileView(
                    allowedFileTypes: [.data],
                    selectedFileURL: $selectedFile,
                    errorMessage: $errorMessage,
                    fileData: $selectedFileData
                )
                Divider()
                outputSection
                Divider()
                comparisonSection
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 5)
                }
            }
            // ✅ 2. 为整个 VStack 应用统一的卡片样式
            .padding(24)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.separator.opacity(0.5), lineWidth: 0.5)
            )
            // ✅ 3. 设定最大宽度，保持布局美观
            .frame(maxWidth: 700)
            .padding()
        }
        // ✅ 核心修改点: 所有的计算逻辑都由状态变化来驱动
        .onChange(of: selectedFileData) { _, _ in updateHash() }
        .onChange(of: selectedAlgorithm) { _, _ in updateHash() }
        .onChange(of: isUppercase) { _, _ in updateHash() }
        .onChange(of: calculatedHash) { _, _ in compareHashes() }
        .onChange(of: comparisonHash) { _, _ in compareHashes() }
    }
    
    /// ✅ 新增: 只负责使用内存中的数据进行哈希计算 (同步，极快)
    private func updateHash() {
        // 如果文件数据为空，则清空结果
        guard let data = selectedFileData else {
            calculatedHash = ""
            return
        }
           
        // UI上显示正在计算（虽然会非常快）
        isCalculating = true
           
        // 计算逻辑现在非常简单
        let computed = Utils.computeHash(from: data, for: selectedAlgorithm)
        calculatedHash = isUppercase ? computed.uppercased() : computed.lowercased()
           
        // 立即结束计算状态
        isCalculating = false
    }

    // MARK: - Subviews
        
    private var configSection: some View {
        VStack(spacing: 12) {
            LabeledContent("Uppercase Output") {
                Toggle("Uppercase Output", isOn: $isUppercase).labelsHidden()
            }
            LabeledContent("Hash Algorithm") {
                Picker("Hash Algorithm", selection: $selectedAlgorithm) {
                    ForEach(HashAlgorithm.allCases, id: \.self) {
                        Text($0.rawValue).tag($0)
                    }
                }
                .labelsHidden()
                .frame(maxWidth: 200) // 可以给 Picker 一个最大宽度
            }
        }
    }
        
    private var outputSection: some View {
        LabeledContent("Calculated Checksum") {
            TextField("Checksum will appear here", text: .constant(calculatedHash))
                .font(.monospaced(.body)())
                .textFieldStyle(.roundedBorder)
                .disabled(true)
                
            Button(action: { Utils.copy(calculatedHash) }) { Image(systemName: "doc.on.doc") }
                .buttonStyle(.borderless).disabled(calculatedHash.isEmpty)
        }
    }
        
    private var comparisonSection: some View {
        VStack {
            LabeledContent("Compare With") {
                TextField("Paste a checksum to compare", text: $comparisonHash)
                    .font(.monospaced(.body)())
                    .textFieldStyle(.roundedBorder)
                    
                Button(action: { Utils.paste($comparisonHash) }) { Image(systemName: "doc.on.clipboard") }
                    .buttonStyle(.borderless)
            }
                
            if comparisonStatus != .idle {
                Text(comparisonStatus.text)
                    .font(.footnote.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(4)
                    .background(comparisonStatus.color.opacity(0.2))
                    .cornerRadius(4)
                    .padding(.top, 8)
            }
        }
    }
    
    private func compareHashes() {
        guard !calculatedHash.isEmpty, !comparisonHash.isEmpty else {
            comparisonStatus = .idle
            return
        }
            
        if calculatedHash.lowercased() == comparisonHash.lowercased() {
            comparisonStatus = .match
        } else {
            comparisonStatus = .mismatch
        }
    }
}
