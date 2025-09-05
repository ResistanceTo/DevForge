//
//  XML.swift
//  DevForge
//
//  Created by resistanceto on 2025-08-29.
//

import SwiftUI
import UniformTypeIdentifiers

struct XMLFormatterView: View {
    // MARK: - State Properties

    @State private var inputText = ""
    @State private var formattedText = ""
    @State private var inputFileName: String?

    // 用于防抖
    @State private var debounceTask: Task<Void, Never>?

    @State private var selectedFile: URL?
    @State private var errorMessage: String?
    @State private var selectedFileData: Data?

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            // 使用我们之前创建的通用布局视图
            TwoTieredLayout {
                ReadFileAndPlainTextView(
                    title: "Input",
                    allowedFileTypes: [.xml],
                    selectedFileURL: $selectedFile,
                    errorMessage: $errorMessage,
                    fileData: $selectedFileData,
                    text: $inputText,
                    pasteAction: { Utils.paste($inputText) },
                    clearAction: { Utils.clear($inputText) }
                )
            } right: {
                EditorLayoutView(
                    title: "Formatted Output",
                    text: $formattedText,
                    isReadOnly: true,
                    copyAction: { Utils.copy(formattedText) },
                    saveAction: { Utils.saveFile(formattedText, type: [.xml], name: inputFileName ?? "xml") }
                )
            }

            // 错误信息显示
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.top, 5)
            }
        }
        .padding()
        .debouncedOnChange(of: inputText,
                           perform: { newValue in
                               formattedText = try beautifyXML(from: newValue)
                           },
                           onError: $errorMessage,
                           errorAction: { formattedText = "" })
        .onAppear {
            inputText = "<info><name>DevForge</name><pricing>0</pricing></info>"
        }
        .onChange(of: selectedFileData) { _, newValue in
            handleDropFile(newValue)
        }
    }

    /// (仅适用于 macOS) 美化XML字符串，修改为抛出错误
    private func beautifyXML(from string: String) throws -> String {
        guard let data = string.data(using: .utf8) else {
            throw FormatError.serializationFailed
        }

        let document = try XMLDocument(data: data, options: .nodePreserveWhitespace)
        let beautifiedData = document.xmlData(options: .nodePrettyPrint)

        guard let beautifiedString = String(data: beautifiedData, encoding: .utf8) else {
            throw FormatError.deserializationFailed
        }

        return beautifiedString
    }

    private func handleDropFile(_ fileData: Data?) {
        do {
            guard let data = fileData else {
                throw FileError.loadFileFailed
            }
            guard let string = String(data: data, encoding: .utf8) else {
                throw FileError.loadFileFailed
            }
            let beautifiedXML = try beautifyXML(from: string)
            formattedText = beautifiedXML
            inputFileName = selectedFile?.lastPathComponent
            errorMessage = nil
        } catch {
            formattedText = ""
            inputFileName = selectedFile?.lastPathComponent
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    XMLFormatterView()
}
