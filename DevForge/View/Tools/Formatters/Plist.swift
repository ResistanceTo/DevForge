//
//  Plist.swift
//  DevForge
//
//  Created by resistanceto on 2025-08-29.
//

import SwiftUI
import UniformTypeIdentifiers

struct PlistFormatterView: View {
    // MARK: - State Properties (所有业务状态都在这里)

    @State private var formattedOutput = ""
    @State private var inputText: String = ""
//    @State private var debounceTask: Task<Void, Never>?

    // 文件名
    @State private var inputFileName: String?

    @State private var selectedFile: URL?
    @State private var errorMessage: String?
    @State private var selectedFileData: Data?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TwoTieredLayout {
                ReadFileAndPlainTextView(
                    title: "Input",
                    allowedFileTypes: [.propertyList],
                    selectedFileURL: $selectedFile,
                    errorMessage: $errorMessage,
                    fileData: $selectedFileData,
                    text: $inputText,
                    pasteAction: { Utils.paste($inputText) },
                    clearAction: { clear() }
                )
            } right: {
                EditorLayoutView(
                    title: "Formatted Output",
                    text: $formattedOutput,
                    isReadOnly: true,
                    copyAction: { Utils.copy(formattedOutput) },
                    saveAction: { Utils.saveFile(formattedOutput, type: [.propertyList], name: inputFileName ?? "plist") }
                )
            }

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.top, 5)
            }
        }
        .padding()
        .onAppear {
            inputText = "<plist version=\"1.0\"><dict><key>name</key><string>DevForge</string></dict></plist>"
        }
        .onChange(of: selectedFileData) { _, newValue in
            handleDropFile(newValue)
        }
        .debouncedOnChange(
            of: inputText,
            perform: { newValue in
                guard let data = newValue.data(using: .utf8) else {
                    self.errorMessage = "Invalid input data."
                    return
                }
                formattedOutput = try beautifyPlist(from: data)
            },
            onError: $errorMessage,
            errorAction: { formattedOutput = "" }
        )
    }

    /// 将 Plist Data 转换为格式化的 XML 字符串
    private func beautifyPlist(from data: Data) throws -> String {
        let plistObject = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        let beautifiedData = try PropertyListSerialization.data(fromPropertyList: plistObject, format: .xml, options: 0)

        guard let beautifiedString = String(data: beautifiedData, encoding: .utf8) else {
            throw FormatError.deserializationFailed
        }
        return beautifiedString
    }

//    private func handleTextChange(newValue: String) {
//        debounceTask?.cancel()
//        if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//            formattedOutput = ""
//            errorMessage = nil
//            inputFileName = nil // 清除旧的文件名
//            return
//        }
//        debounceTask = Task {
//            do {
//                // 直接从输入文本转换
//                guard let data = newValue.data(using: .utf8) else {
//                    self.errorMessage = "Invalid input data."
//                    return
//                }
//                let beautifiedXML = try beautifyPlist(from: data)
//
//                // 更新状态
//                self.formattedOutput = beautifiedXML
//                self.errorMessage = nil
//            } catch {
//                self.formattedOutput = ""
//                self.errorMessage = "Failed to process text: \(error.localizedDescription)"
//            }
//        }
//    }

    private func handleDropFile(_ fileData: Data?) {
        do {
            guard let data = fileData else {
                throw FileError.loadFileFailed
            }
            let beautifiedXML = try beautifyPlist(from: data)
            formattedOutput = beautifiedXML
            inputFileName = selectedFile?.lastPathComponent
            errorMessage = nil // 使用 nil 而不是空字符串
        } catch {
            formattedOutput = ""
            inputFileName = selectedFile?.lastPathComponent
            errorMessage = error.localizedDescription
        }
    }

    private func clear() {
        // 清空所有输入和输出
        inputText = ""
        inputFileName = nil
        formattedOutput = ""
        errorMessage = nil
    }
}

#Preview {
    PlistFormatterView()
}
