//
//  JSON.swift
//  DevForge
//
//  Created by resistanceto on 2025-08-27.
//

import Combine // 导入 Combine 框架用于防抖
import SwiftUI
import UniformTypeIdentifiers

struct JSONFormatterView: View {
    @State private var text = ""
    @State private var formattedText = ""

    @State private var inputFileName: String?

    @State private var selectedFile: URL?
    @State private var errorMessage: String?
    @State private var selectedFileData: Data?

    var body: some View {
        VStack(spacing: 16) {
            TwoTieredLayout {
                ReadFileAndPlainTextView(
                    title: "Input",
                    allowedFileTypes: [.json],
                    selectedFileURL: $selectedFile,
                    errorMessage: $errorMessage,
                    fileData: $selectedFileData,
                    text: $text,
                    pasteAction: { Utils.paste($text) },
                    clearAction: { Utils.clear($text) }
                )
            } right: {
                EditorLayoutView(
                    title: "Formatted Output",
                    text: $formattedText,
                    isReadOnly: true,
                    copyAction: { Utils.copy(formattedText) },
                    saveAction: { Utils.saveFile(formattedText, type: [.json], name: inputFileName ?? "json") }
                )
            }

            // 独立的错误信息显示区域
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.top, 5)
            }
        }
        .padding()
        .onAppear {
            text = "{\"name\": \"DevForge\"}"
        }
        .onChange(of: selectedFileData) { _, newValue in
            handleDropFile(newValue)
        }
        .debouncedOnChange(of: text,
                           perform: { newText in
                               formattedText = try FormatterUtils.beautifyJSONFromString(from: newText)
                           },
                           onError: $errorMessage,
                           errorAction: { formattedText = "" })
    }

    private func handleDropFile(_ fileData: Data?) {
        do {
            guard let data = fileData else {
                throw FileError.loadFileFailed
            }
            let beautifiedXML = try FormatterUtils.beautifyJSONFromData(from: data)
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
    JSONFormatterView()
}
