//
//  ReadQRCode.swift
//  DevForge
//
//  Created by resistanceto on 2025-08-27.
//

import SwiftUI
import UniformTypeIdentifiers
import Vision

struct ReadQRCodeView: View {
    @State private var qrContents: [String] = []
    @State private var isProcessing: Bool = false
    
    // 文件导入三件套
    @State private var selectedFile: URL?
    @State private var errorMessage: String?
    @State private var selectedFileData: Data?
    
    var body: some View {
        ScrollView {
            // 使用一个统一的卡片作为主容器
            VStack(spacing: 0) {
                // 1. 文件输入区域
                ReadFileView(
                    allowedFileTypes: [.image], // 只允许图片类型
                    selectedFileURL: self.$selectedFile,
                    errorMessage: self.$errorMessage,
                    fileData: self.$selectedFileData
                )
                .frame(height: 250) // 给输入区一个合适的高度
                        
                // 2. 如果有解码内容，则显示输出区域
                if !qrContents.isEmpty {
                    Divider()
                    self.outputSection
                        .padding()
                }
                        
                // 3. 如果正在处理，显示加载动画
                if isProcessing {
                    ProgressView().padding()
                }
                        
                // 4. 如果没有内容且没有在加载，显示提示
                if qrContents.isEmpty && !isProcessing {
                    Text("No QR code detected yet.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                }
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.separator.opacity(0.5), lineWidth: 0.5)
            )
            .frame(maxWidth: 700)
            .padding()
        }
        // ✅ 核心逻辑修改: 监听 fileData 的变化
        .onChange(of: selectedFileData) { _, newData in
            guard let data = newData else {
                qrContents.removeAll()
                return
            }
            // 使用 Task 来调用新的 async 解码函数
            Task {
                await self.processQRCode(from: data)
            }
        }
    }
    
    // MARK: - Subviews
        
    /// 结果输出区域
    private var outputSection: some View {
        VStack(alignment: .leading) {
            Text("Decoded Content (\(qrContents.count))")
                .font(.headline)
                .foregroundColor(.secondary)
                
            // 使用 LazyVStack 构建自定义列表
            LazyVStack(spacing: 8) {
                ForEach(qrContents.indices, id: \.self) { index in
                    self.resultRow(for: qrContents[index])
                }
            }
        }
    }
        
    /// 结果列表的单行视图
    private func resultRow(for content: String) -> some View {
        HStack(alignment: .top) {
            Text(content)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                
            Button(action: { Utils.copy(content) }) {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.borderless)
        }
        .padding(12)
        .background(Color(.textBackgroundColor))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }

    // MARK: - Logic
        
    /// ✅ 新增: 统一的、异步的二维码处理函数
    private func processQRCode(from data: Data) async {
        isProcessing = true
        let contents = await readQRCode(from: data)
        qrContents = contents
        isProcessing = false
    }

    /// ✅ 核心修改: 将 readQRCode 改为 async 并在后台执行
    private func readQRCode(from data: Data) async -> [String] {
        return await Task.detached {
            let requestHandler = VNImageRequestHandler(data: data, options: [:])
            let request = VNDetectBarcodesRequest()
            request.symbologies = [.qr]
                
            do {
                try requestHandler.perform([request])
                guard let observations = request.results else {
                    return []
                }
                return observations.compactMap { $0.payloadStringValue }
            } catch {
                print("Failed to perform Vision request: \(error.localizedDescription)")
                await MainActor.run {
                    self.errorMessage = "Failed to read QR Code from image."
                }
                return []
            }
        }.value
    }
}

#Preview {
    ReadQRCodeView()
}
