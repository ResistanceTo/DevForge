//
//  EditorLayout.swift
//  DevForge
//
//  Created by resistanceto on 2025-08-29.
//

import SwiftUI

struct EditorLayoutView: View {
    let title: LocalizedStringKey?
    @Binding var text: String
    var isReadOnly: Bool = false

    // MARK: 底部操作按钮，后期可能多扩展

    var pasteAction: (() -> Void)? = nil
    var clearAction: (() -> Void)? = nil
    var copyAction: (() -> Void)? = nil
    var saveAction: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = title {
                Text(title)
                    .font(.headline).foregroundColor(.secondary)
            }

            if isReadOnly {
                ScrollView {
                    // 使用 Text 替代 TextEditor
                    Text(text)
                        .font(.monospaced(.body)())
                        .frame(maxWidth: .infinity, alignment: .leading) // 确保文本从左上角开始并填满宽度
                        .padding(8) // 内边距
                }
                .textSelection(.enabled)
                .background(Color(.textBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            } else {
                TextEditor(text: $text)
                    .font(.monospaced(.body)())
                    .padding(8)
                    .background(Color(.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    .scrollIndicators(.hidden) // 其实没啥用
//                    .disableAutocorrection(true)
                    .autocorrectionDisabled(true) // macos不能用为什么写文档里面？无法理解
            }

            HStack {
                if let paste = pasteAction {
                    Button { paste() } label: { Label("Paste", systemImage: "doc.on.clipboard") }
                }
                if let clear = clearAction {
                    Button { clear() } label: { Label("Clear", systemImage: "xmark.circle") }
                }
                Spacer()
                if let copy = copyAction {
                    Button { copy() } label: { Label("Copy", systemImage: "doc.on.doc") }
                        .disabled($text.wrappedValue.isEmpty)
                }
                if let save = saveAction {
                    Button { save() } label: { Label("Save As...", systemImage: "square.and.arrow.down") }
                        .disabled(text == "")
                }
            }.buttonStyle(.borderless) // macOS 风格
        }
    }
}
