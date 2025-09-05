//
//  Date+Extension.swift
//  DevForge
//
//  Created by resistanceto on 2025-08-28.
//

import Foundation

extension Date {
    /// 生成一个适合用作文件后缀的、格式统一的日期时间字符串。
    /// 格式为: "yyyy-MM-dd_HH-mm-ss"
    static var fileSaveSuffix: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter.string(from: Date())
    }
}
