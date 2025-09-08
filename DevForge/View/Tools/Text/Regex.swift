//
//  Regex.swift
//  DevForge
//
//  Created by ResistanceTo on 2025/8/31.
//

import SwiftUI

// 用于存储单个匹配结果的数据结构
struct RegexMatchResult: Identifiable {
    let id = UUID()
    let fullMatch: String
    let range: NSRange
    let capturedGroups: [String]
}

struct TextRegexView: View {
    // MARK: - State Properties
    
    @State private var regexPattern: String = ""
    @State private var testString: String = ""
    
    // 选项
    @State private var isCaseInsensitive: Bool = false
    @State private var isMultiline: Bool = false // .dotMatchesLineSeparators
    
    // 结果
    @State private var matchResults: [RegexMatchResult] = []
    @State private var errorMessage: String?
    
    @State private var debounceTimer: Timer?
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 正则表达式输入和选项
            regexInputSection
            
            TwoTieredLayout {
                EditorLayoutView(
                    title: "Input",
                    text: $testString,
                    pasteAction: { Utils.paste($testString) },
                    clearAction: {
                        testString = ""
                        matchResults.removeAll()
                    }
                )
            } right: {
                resultsSection
            }
        }
        .padding()
        .onChange(of: regexPattern) { _, _ in handleInputChange() }
        .onChange(of: testString) { _, _ in handleInputChange() }
        .onChange(of: isCaseInsensitive) { _, _ in performMatch() }
        .onChange(of: isMultiline) { _, _ in performMatch() }
        .onAppear {
            regexPattern = "(?<protocol>https?)://(?<domain>[a-zA-Z0-9.-]+)"
            testString = "DevForge is an open-source and free developer toolkit. Official website: https://zhaohe.org GitHub Repository: https://github.com/ResistanceTo/DevForge"
        }
    }
    
    // MARK: - Subviews
    
    /// 正则表达式输入框和选项
    private var regexInputSection: some View {
        VStack(alignment: .leading) {
            Text("Regular Expression")
                .font(.headline).foregroundColor(.secondary)
            
            TextField("Enter your regular expression here", text: $regexPattern)
                .font(.monospaced(.body)())
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
            
            HStack {
                Toggle("Case Insensitive", isOn: $isCaseInsensitive)
                Toggle("Dot Matches Newlines", isOn: $isMultiline)
                Spacer()
                Link("Regex Cheatsheet", destination: URL(string: "https://www.w3schools.in/python-regex/regular-expressions-cheat-sheet/")!)
            }
        }
    }
    
    /// 结果列表区域
    @ViewBuilder
    private var resultsSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Match Results (\(matchResults.count))")
                    .font(.headline)
                    .foregroundColor(.secondary)
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }
            
            List(matchResults) { result in
                DisclosureGroup {
                    // 展开后显示捕获组
                    if result.capturedGroups.isEmpty {
                        Text("No capture groups found.").foregroundColor(.secondary)
                    } else {
                        ForEach(result.capturedGroups.indices, id: \.self) { index in
                            HStack(alignment: .top) {
                                Text("Group \(index + 1):")
                                    .foregroundColor(.secondary)
                                Text(result.capturedGroups[index])
                                    .textSelection(.enabled)
                                Spacer()
                            }
                        }
                    }
                } label: {
                    // 主标签显示完整匹配
                    VStack(alignment: .leading) {
                        Text(result.fullMatch)
                            .fontWeight(.bold)
                            .textSelection(.enabled)
                        Text("Range: \(result.range.location)-\(result.range.location + result.range.length)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(.bordered(alternatesRowBackgrounds: true))
        }
    }
    
    // MARK: - Logic
    
    private func handleInputChange() {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
            performMatch()
        }
    }
    
    /// 执行正则匹配
    private func performMatch() {
        guard !regexPattern.isEmpty, !testString.isEmpty else {
            matchResults.removeAll()
            errorMessage = nil
            return
        }
        
        do {
            var options: NSRegularExpression.Options = []
            if isCaseInsensitive { options.insert(.caseInsensitive) }
            if isMultiline { options.insert(.dotMatchesLineSeparators) }
            
            let regex = try NSRegularExpression(pattern: regexPattern, options: options)
            let nsRange = NSRange(testString.startIndex..<testString.endIndex, in: testString)
            let matches = regex.matches(in: testString, options: [], range: nsRange)
            
            matchResults = matches.map { match in
                // 提取完整匹配
                let fullMatchRange = Range(match.range(at: 0), in: testString)!
                let fullMatchString = String(testString[fullMatchRange])
                
                // 提取所有捕获组
                var capturedGroups: [String] = []
                if match.numberOfRanges > 1 {
                    for i in 1..<match.numberOfRanges {
                        if let groupRange = Range(match.range(at: i), in: testString) {
                            capturedGroups.append(String(testString[groupRange]))
                        }
                    }
                }
                
                return RegexMatchResult(fullMatch: fullMatchString, range: match.range, capturedGroups: capturedGroups)
            }
            
            errorMessage = nil // 成功后清除错误信息
            
        } catch {
            matchResults.removeAll()
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    TextRegexView()
}
