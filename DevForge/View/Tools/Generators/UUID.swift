//
//  UUIDGeneratorView.swift
//  DevForge
//
//  Created by ResistanceTo on 2025/8/26.
//

import SwiftUI

struct UUIDGeneratorView: View {
    // MARK: - State Properties
    
    @State private var isUppercase = true
    @State private var includeHyphens = true
    @State private var count = 5
    @State private var generatedUUIDs: [String] = []
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 使用新的整合控制区
            controlsSection
            
            Divider()
            
            resultsSection
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Subviews
    
    /// 整合了所有选项和生成按钮的控制面板 (方案一)
    private var controlsSection: some View {
        HStack(alignment: .center, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Toggle("Uppercase (A-Z)", isOn: $isUppercase)
                    .controlSize(.small)
                Toggle("Include Hyphens (-)", isOn: $includeHyphens)
                    .controlSize(.small)
            }
            
            Stepper("Count: \(count)", value: $count, in: 1 ... 100)
                .controlSize(.small)
                .frame(maxWidth: 150)
            
            Spacer()
            
            Button(action: generateUUIDs) {
                Label("Generate", systemImage: "arrow.clockwise.circle")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .background(Color(.textBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }

    /// 结果列表区域 (此部分代码无需修改)
    @ViewBuilder
    private var resultsSection: some View {
        if !generatedUUIDs.isEmpty {
            VStack(alignment: .leading) {
                HStack {
                    Text("Results (\(generatedUUIDs.count))")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button { Utils.copy(generatedUUIDs.joined(separator: "\n")) } label: { Label("Copy All", systemImage: "doc.on.doc.fill") }
                        .buttonStyle(.borderless)
                }
                
                List(generatedUUIDs, id: \.self) { uuid in
                    HStack {
                        Text(uuid)
                            .font(.monospaced(.body)())
                        Spacer()
                        copyButton(for: uuid)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.bordered(alternatesRowBackgrounds: true))
                .frame(minHeight: 200)
            }
        } else {
            VStack {
                Spacer()
                Text("Click 'Generate' to create UUIDs.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .frame(maxWidth: .infinity, minHeight: 200)
        }
    }
    
    private func copyButton(for uuid: String) -> some View {
        Button(action: { Utils.copy(uuid) }) {
            Image(systemName: "doc.on.doc")
        }
        .buttonStyle(.borderless)
        .frame(height: 18)
    }

    // MARK: - 功能部分
    
    private func generateUUIDs() {
        generatedUUIDs.removeAll()
        for _ in 0 ..< count {
            var uuidString = UUID().uuidString
            if !includeHyphens {
                uuidString = uuidString.replacingOccurrences(of: "-", with: "")
            }
            if !isUppercase {
                uuidString = uuidString.lowercased()
            }
            generatedUUIDs.append(uuidString)
        }
    }
}

#Preview {
    UUIDGeneratorView()
}
