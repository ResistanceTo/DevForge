//
//  Base.swift
//  DevForge
//
//  Created by ResistanceTo on 2025/8/31.
//

import SwiftUI

struct BaseConverterView: View {
    // MARK: - 定义支持的进制类型
    
    enum BaseType: String, CaseIterable, Identifiable {
        case decimal
        case hexadecimal
        case octal
        case binary
        
        var id: Self { self }
        
        var title: LocalizedStringKey {
            switch self {
            case .decimal: "Decimal"
            case .hexadecimal: "Hexadecimal"
            case .octal: "Octal"
            case .binary: "Binary"
            }
        }
        
        var radix: Int {
            switch self {
            case .decimal: 10
            case .hexadecimal: 16
            case .octal: 8
            case .binary: 2
            }
        }
    }
    
    // MARK: - State Properties
    
    @State private var value: Int64 = 0
    
    @State private var decimalString: String = "0"
    @State private var hexadecimalString: String = "0"
    @State private var octalString: String = "0"
    @State private var binaryString: String = "0"
    
    @State private var addSeparators: Bool = true
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            configurationSection
                
            conversionSection
        }
        .padding(24)
        .background(Color(.windowBackgroundColor))
        .onChange(of: value) { _, newValue in
            updateStrings(from: newValue)
        }
        .onChange(of: addSeparators) { _, _ in
            updateStrings(from: value)
        }
        .onAppear {
            value = Int64(Date.now.timeIntervalSince1970)
        }
    }
    
    // MARK: - Subviews
    
    private var configurationSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Configuration")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack(spacing: 12) {
                Image(systemName: "textformat")
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                Text("Formatter")
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: $addSeparators.animation(.easeInOut(duration: 0.2)))
                    .toggleStyle(SwitchToggleStyle())
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(8)
        }
    }
    
    private var conversionSection: some View {
        VStack(spacing: 16) {
            ForEach(BaseType.allCases, id: \.id) { baseType in
                baseConversionRow(for: baseType)
            }
        }
    }
    
    private func baseConversionRow(for baseType: BaseType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(baseType.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: {
                        Utils.paste(bindingForBaseType(baseType))
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.on.clipboard")
                                .font(.system(size: 12, weight: .medium))
                            Text("Paste")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
//                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
//                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        Utils.copy(stringForBaseType(baseType))
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 12, weight: .medium))
                            Text("Copy")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .cornerRadius(4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(stringForBaseType(baseType).isEmpty)
                }
            }
            
            TextField(baseType.title, text: bindingForBaseType(baseType))
                .font(.system(.body, design: .monospaced))
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.textBackgroundColor))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(.separatorColor), lineWidth: 0.5)
                )
                .disableAutocorrection(true)
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Helper Methods
    
    private func bindingForBaseType(_ baseType: BaseType) -> Binding<String> {
        switch baseType {
        case .decimal: return decimalBinding()
        case .hexadecimal: return hexBinding()
        case .octal: return octalBinding()
        case .binary: return binaryBinding()
        }
    }
    
    private func stringForBaseType(_ baseType: BaseType) -> String {
        switch baseType {
        case .decimal: return decimalString
        case .hexadecimal: return hexadecimalString
        case .octal: return octalString
        case .binary: return binaryString
        }
    }
    
    // MARK: - Logic & Actions
    
    /// 当核心整数值变化时，更新所有文本框
    private func updateStrings(from intValue: Int64) {
        // 十进制根据配置进行格式化
        if addSeparators {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            decimalString = formatter.string(from: NSNumber(value: intValue)) ?? String(intValue)
        } else {
            decimalString = String(intValue)
        }
        
        hexadecimalString = String(intValue, radix: 16).uppercased()
        octalString = String(intValue, radix: 8)
        binaryString = String(intValue, radix: 2)
    }
    
    private func decimalBinding() -> Binding<String> {
        Binding(get: { self.decimalString }, set: {
            // 移除非数字和非分隔符
            let filtered = $0.filter("0123456789".contains)
            self.decimalString = filtered
            if let intValue = Int64(filtered) { self.value = intValue }
        })
    }
    
    private func hexBinding() -> Binding<String> {
        Binding(get: { self.hexadecimalString }, set: {
            let filtered = $0.filter("0123456789abcdefABCDEF".contains).uppercased()
            self.hexadecimalString = filtered
            if let intValue = Int64(filtered, radix: 16) { self.value = intValue }
        })
    }
    
    private func octalBinding() -> Binding<String> {
        Binding(get: { self.octalString }, set: {
            let filtered = $0.filter("01234567".contains)
            self.octalString = filtered
            if let intValue = Int64(filtered, radix: 8) { self.value = intValue }
        })
    }
    
    private func binaryBinding() -> Binding<String> {
        Binding(get: { self.binaryString }, set: {
            let filtered = $0.filter("01".contains)
            self.binaryString = filtered
            if let intValue = Int64(filtered, radix: 2) { self.value = intValue }
        })
    }
}

#Preview {
    BaseConverterView()
}
