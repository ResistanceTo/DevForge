//
//  ReadFile+Text.swift
//  DevForge
//
//  Created by resistanceto on 2025-09-04.
//

import SwiftUI
import UniformTypeIdentifiers

struct ReadFileAndPlainTextView: View {
    enum InputMode: String, CaseIterable, Identifiable {
        case file
        case text
        var id: Self { self }

        var title: LocalizedStringKey {
            switch self {
            case .file: "File"
            case .text: "Text"
            }
        }
    }

    let title: LocalizedStringKey
    let allowedFileTypes: [UTType]

    // 这三个是读取文件三件套
    @Binding var selectedFileURL: URL?
    @Binding var errorMessage: String?
    @Binding var fileData: Data?

    // 纯文本部分
    @Binding var text: String
    var pasteAction: (() -> Void)? = nil
    var clearAction: (() -> Void)? = nil

    @State private var inputMode: InputMode = .text

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)

                Spacer()
                Picker("", selection: $inputMode) {
                    ForEach(InputMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
            }
            // 根据选择的模式，显示不同的输入UI
            if inputMode == .file {
                ReadFileView(
                    allowedFileTypes: allowedFileTypes,
                    selectedFileURL: $selectedFileURL,
                    errorMessage: $errorMessage,
                    fileData: $fileData
                )
            } else {
                // 直接复用我们之前创建的 EditorLayoutView！
                EditorLayoutView(
                    title: nil,
                    text: $text,
                    pasteAction: pasteAction,
                    clearAction: clearAction
                )
            }
        }
        .animation(.easeInOut, value: inputMode) // 为模式切换添加平滑动画
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
