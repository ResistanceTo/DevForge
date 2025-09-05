//
//  ReadFile.swift
//  DevForge
//
//  Created by resistanceto on 2025-09-03.
//

import SwiftUI
import UniformTypeIdentifiers

/// 读取文件信息
struct ReadFileView: View {
    /// 允许传入的文件类型
    let allowedFileTypes: [UTType]

    /// 选中文件的路径
    @Binding var selectedFileURL: URL?
    
    /// 处理文件可能发生的错误
    @Binding var errorMessage: String?
    
    /// 文件内容
    @Binding var fileData: Data?
    
    @State private var isFileImporterPresented = false
    @State private var isDropTargeted = false

    var body: some View {
        VStack {
            Image(systemName: "doc.text.fill.viewfinder")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            
            if let url = selectedFileURL {
                Text(url.lastPathComponent)
                    .font(.headline)
                    .lineLimit(1)
                    .padding(.horizontal)
            } else {
                Text("Select or drop a file here")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            
            Button("Open File...") {
                self.isFileImporterPresented = true
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(self.isDropTargeted ? Color.accentColor.opacity(0.2) : Color.clear)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                .foregroundColor(self.isDropTargeted ? .blue : .accentColor.opacity(0.6))
        )
        .fileImporter(
            isPresented: self.$isFileImporterPresented,
            allowedContentTypes: self.allowedFileTypes,
            onCompletion: self.handleFileSelection
        )
        .onDrop(of: self.allowedFileTypes, isTargeted: self.$isDropTargeted) { providers in
            self.handleFileDrop(providers: providers)
            return true
        }
    }
    
    private func handleFileSelection(result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            Task {
                await self.readFile(from: url)
            }
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }
    
    private func handleFileDrop(providers: [NSItemProvider]) {
        Task {
            guard let provider = providers.first else {
                self.errorMessage = FileError.incorrectAddress.localizedDescription
                return
            }
            
            var url: URL?
            
            for allowedFileType in self.allowedFileTypes {
                if provider.hasItemConformingToTypeIdentifier(allowedFileType.identifier) {
                    do {
                        guard let item = try await provider.loadItem(forTypeIdentifier: allowedFileType.identifier) as? URL else { break }
                        url = item
                    } catch {
                        continue
                    }
                }
            }
            
            guard let finalURL = url else {
                self.errorMessage = FileError.typeError.localizedDescription
                return
            }
            await self.readFile(from: finalURL)
        }
    }
    
    private func readFile(from url: URL) async {
        self.selectedFileURL = url
        
        // 1. 将耗时的文件读取操作放到后台任务中
        let result: Result<Data, Error> = await Task.detached {
            let isAccessing = url.startAccessingSecurityScopedResource()
            defer { if isAccessing { url.stopAccessingSecurityScopedResource() } }
                    
            do {
                let data = try Data(contentsOf: url)
                return .success(data)
            } catch {
                return .failure(error)
            }
        }.value
        
        // 2. 回到主线程，根据结果更新最终的UI状态
        switch result {
        case .success(let data):
            self.fileData = data
            self.errorMessage = nil
        case .failure(let error):
            self.fileData = nil
            self.errorMessage = error.localizedDescription
        }
    }
}
