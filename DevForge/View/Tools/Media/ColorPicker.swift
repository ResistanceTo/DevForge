//
//  ColorPicker.swift
//  DevForge
//
//  Created by ResistanceTo on 2025/8/31.
//

import SwiftUI

// 用于存储解析后的颜色组件，方便转换
struct ColorComponents {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var hue: CGFloat = 0
    var saturation: CGFloat = 0
    var brightness: CGFloat = 0
    var alpha: CGFloat = 0
    
    init(color: Color) {
        // 1. 从 SwiftUI Color 创建 NSColor
        let nsColor = NSColor(color)

        // 2. (关键修复) 在提取组件前，先将颜色转换为 sRGB 色彩空间
        //    .usingColorSpace(.sRGB) 会返回一个新的、已解析为 sRGB 值的 NSColor 对象
        //    如果转换失败（虽然很少见），则安全退出
        guard let srgbColor = nsColor.usingColorSpace(.sRGB) else {
            print("Failed to convert color to sRGB space.")
            return
        }

        // 3. 现在，在转换后的、稳定的 srgbColor 对象上安全地提取组件
        srgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        srgbColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
    }
}

struct MediaColorPickerView: View {
    // MARK: - State Properties
        
    @State private var selectedColor: Color = .blue
    @State private var copiedValue: String?
        
    // MARK: - Computed Properties
        
    private var components: ColorComponents {
        ColorComponents(color: selectedColor)
    }
        
    private var results: [TimeFormatResult] {
        let comps = components
        let r = Int(comps.red * 255)
        let g = Int(comps.green * 255)
        let b = Int(comps.blue * 255)
        let a = comps.alpha
            
        return [
            TimeFormatResult(name: "Hex (RRGGBB)", value: String(format: "#%02X%02X%02X", r, g, b)),
            TimeFormatResult(name: "Hex (RRGGBBAA)", value: String(format: "#%02X%02X%02X%02X", r, g, b, Int(a * 255))),
            TimeFormatResult(name: "RGB", value: "rgb(\(r), \(g), \(b))"),
            TimeFormatResult(name: "RGBA", value: "rgba(\(r), \(g), \(b), \(String(format: "%.2f", a)))"),
            TimeFormatResult(name: "HSB", value: "hsb(\(Int(comps.hue * 360))°, \(Int(comps.saturation * 100))%, \(Int(comps.brightness * 100))%)"),
            TimeFormatResult(name: "SwiftUI (RGB)", value: "Color(red: \(String(format: "%.2f", comps.red)), green: \(String(format: "%.2f", comps.green)), blue: \(String(format: "%.2f", comps.blue)))"),
            TimeFormatResult(name: "SwiftUI (HSB)", value: "Color(hue: \(String(format: "%.2f", comps.hue)), saturation: \(String(format: "%.2f", comps.saturation)), brightness: \(String(format: "%.2f", comps.brightness)))")
        ]
    }

    // MARK: - Body
        
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // 左侧：颜色选择器和预览
            VStack(spacing: 16) {
                // 使用 SwiftUI 原生的 ColorPicker
                ColorPicker("Select Color", selection: $selectedColor, supportsOpacity: true)
                    .font(.headline)
                    
                // 颜色预览
                VStack {
                    Text("Preview")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Rectangle()
                        .fill(selectedColor)
                        .frame(height: 100)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        // 使用棋盘格作为背景，以正确预览透明度
                        .background(CheckerboardBackground())
                }
            }
            .frame(width: 250)
                
            // 右侧：转换结果列表
            resultsSection
        }
        .padding()
    }
        
    // MARK: - Subviews
        
    /// 结果列表区域
    private var resultsSection: some View {
        VStack(alignment: .leading) {
            Text("Converted Values")
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
        
    /// 结果列表的单行视图 (与 HashCalculatorView 类似)
    private func resultRow(for result: TimeFormatResult) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(result.name)
                    .font(.caption.weight(.semibold))
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
}

// 一个用于预览透明度的棋盘格背景
struct CheckerboardBackground: View {
    var body: some View {
        Canvas { context, size in
            let squareSize: CGFloat = 10
            for y in stride(from: 0, to: size.height, by: squareSize) {
                for x in stride(from: 0, to: size.width, by: squareSize) {
                    let isEvenRow = Int(y / squareSize) % 2 == 0
                    let isEvenCol = Int(x / squareSize) % 2 == 0
                    context.fill(
                        Path(CGRect(x: x, y: y, width: squareSize, height: squareSize)),
                        with: .color((isEvenRow == isEvenCol) ? .white : .gray.opacity(0.2))
                    )
                }
            }
        }
    }
}
