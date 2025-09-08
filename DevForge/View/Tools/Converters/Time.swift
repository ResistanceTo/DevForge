//
//  Time.swift
//  DevForge
//
//  Created by ResistanceTo on 2025/8/30.
//

import SwiftUI

// 为了方便管理，我们定义一个时间格式的结构体
struct TimeFormatResult: Identifiable {
    let id = UUID()
    let name: String
    var value: String
}

struct TimeConverterView: View {
    // MARK: - State Properties
    
    // 单一数据源：所有格式都由此 Date 派生
    @State private var selectedDate: Date = .now
    
    // 用于时间戳输入框的双向绑定
    @State private var timestampInSecondsString: String = ""
    
    // 用于驱动时钟实时更新
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - Computed Properties (Outputs)
    
    private var results: [TimeFormatResult] {
        // 将所有格式化逻辑放在这里，UI 会自动更新
        [
            TimeFormatResult(
                name: "Unix Timestamp (Seconds)",
                value: "\(Int64(selectedDate.timeIntervalSince1970))"
            ),
            TimeFormatResult(
                name: "Unix Timestamp (Milliseconds)",
                value: "\(Int64(selectedDate.timeIntervalSince1970 * 1000))"
            ),
            TimeFormatResult(
                name: "ISO 8601",
                value: selectedDate.ISO8601Format()
            ),
            TimeFormatResult(
                name: "Formatted",
                value: selectedDate.formatted(date: .long, time: .standard)
            ),
            TimeFormatResult(
                name: "RFC3339",
                value: rfc3339Formatted(date: selectedDate)
            )
        ]
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 输入区域
            inputSection
            
            // 输出区域
            resultsSection
        }
        .padding()
        // 当日期选择器改变时 -> 更新时间戳字符串
        .onChange(of: selectedDate) { _, newDate in
            let newTimestampString = "\(Int64(newDate.timeIntervalSince1970))"
            if newTimestampString != timestampInSecondsString {
                timestampInSecondsString = newTimestampString
            }
        }
        // 当时间戳字符串改变时 -> 更新日期选择器
        .onChange(of: timestampInSecondsString) { _, newTimestampString in
            if let timeInterval = TimeInterval(newTimestampString) {
                let newDate = Date(timeIntervalSince1970: timeInterval)
                if abs(newDate.timeIntervalSince1970 - selectedDate.timeIntervalSince1970) > 0.1 {
                    selectedDate = newDate
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    /// 输入控制区域
    private var inputSection: some View {
        VStack(alignment: .leading) {
            Text("Input")
                .font(.headline)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                DatePicker("", selection: $selectedDate)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                
                VStack(spacing: 12) {
                    // 时间戳输入
                    TextField("Unix Timestamp (Seconds)", text: $timestampInSecondsString)
                        .textFieldStyle(.roundedBorder)
                        .font(.monospaced(.body)())
                    
                    // "现在" 按钮和实时更新开关
                    HStack {
                        Button("Now") {
                            selectedDate = .now
                        }
                    }
                }
            }
        }
    }
    
    /// 结果列表区域
    private var resultsSection: some View {
        VStack(alignment: .leading) {
            Text("Converted Formats")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(results) { result in
                        resultRow(for: result)
                    }
                }
            }
        }
    }
    
    /// 结果列表的单行视图
    private func resultRow(for result: TimeFormatResult) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(result.name)
                    .font(.system(.body, design: .default, weight: .bold))
                    .foregroundColor(.secondary)
                Spacer()
                copyButton(for: result.value)
            }
            
            Text(result.value)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color(.textBackgroundColor))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
    
    /// 拷贝按钮
    private func copyButton(for value: String) -> some View {
        Button(action: { Utils.copy(value) }) {
            Image(systemName: "doc.on.doc")
        }
        .frame(height: 18)
        .buttonStyle(.borderless)
        .disabled(value.isEmpty)
    }

    // MARK: - Logic & Actions
    
    /// RFC3339 格式需要手动创建 Formatter
    private func rfc3339Formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        return formatter.string(from: date)
    }
}

#Preview {
    TimeConverterView()
}
