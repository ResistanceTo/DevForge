//
//  QRCode.swift
//  DevForge
//
//  Created by resistanceto on 2025-08-27.
//

import CoreImage.CIFilterBuiltins
import SwiftUI

struct QRCodeGeneratorView: View {
    // MARK: - State Properties
    
    @State private var text = "DevForge"
    @State private var qrImage: NSImage?
    @State private var errorMessage: String?
    
    // 用于防抖的计时器
    @State private var debounceTimer: Timer?

    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 输入区域
            self.inputSection
            
            // 输出区域
            self.outputSection
            
            Spacer()
        }
        .padding()
        .onAppear(perform: self.generate) // 视图出现时先生成一次
        .onChange(of: self.text) { _, _ in
            // 使用防抖来避免频繁生成
            self.debounceTimer?.invalidate()
            self.debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                self.generate()
            }
        }
    }
    
    // MARK: - Subviews
    
    /// 输入区域的视图
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Input")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ZStack(alignment: .bottomTrailing) {
                TextEditor(text: self.$text)
                    .font(.monospaced(.body)())
                    .frame(height: 100)
                    .padding(8)
                    .background(Color(.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    
                // 字符数统计
                Text("\(self.text.count) characters")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(8)
            }
        }
    }
    
    /// 输出区域的视图
    @ViewBuilder
    private var outputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("QR Code")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if let image = qrImage {
                // 显示生成的二维码
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .frame(maxWidth: .infinity) // 让图片居中
                
                // 功能按钮
                HStack {
                    Spacer()
                    Button { self.copyImage() } label: { Label("Copy Image", systemImage: "doc.on.doc") }
                    Button { self.saveImage() } label: { Label("Save Image...", systemImage: "square.and.arrow.down") }
                    Spacer()
                }
                .buttonStyle(.borderless)
                .padding(.top, 10)
                
            } else {
                // 处理输入为空或生成失败的情况
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.1))
                    
                    Text(self.errorMessage ?? "Enter text to generate a QR Code.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 220, height: 220)
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Logic
    
    /// 生成二维码的核心逻辑（现在会更新状态）
    private func generate() {
        if self.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.qrImage = nil
            self.errorMessage = nil // 清空错误信息
            return
        }
        
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(self.text.utf8)

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                self.qrImage = NSImage(cgImage: cgImage, size: outputImage.extent.size)
                self.errorMessage = nil
                return
            }
        }
        
        // 如果生成失败
        self.qrImage = nil
        self.errorMessage = "Failed to generate QR Code. The text might be too long."
    }
    
    /// 拷贝图片到剪贴板
    private func copyImage() {
        guard let image = qrImage else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([image])
    }
    
    /// 保存图片到文件
    private func saveImage() {
        guard let image = qrImage else { return }
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png]
        savePanel.nameFieldStringValue = "DevForge_QRCode_\(Date.fileSaveSuffix).png"
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                guard let tiffData = image.tiffRepresentation,
                      let bitmap = NSBitmapImageRep(data: tiffData),
                      let pngData = bitmap.representation(using: .png, properties: [:])
                else {
                    // Show an alert to the user
                    print("Error: Failed to convert image to PNG data.")
                    return
                }
                
                do {
                    try pngData.write(to: url)
                } catch {
                    print("Error: Failed to save PNG data to URL. \(error)")
                }
            }
        }
    }
}

#Preview {
    QRCodeGeneratorView()
}
