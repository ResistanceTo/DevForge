//
//  Logger.swift
//  DevForge
//
//  Created by resistanceto on 2025-09-05.
//

import Foundation

/// 一个只在 Debug 模式下打印日志的辅助函数
/// - Parameters:
///   - message: 要打印的消息内容
///   - file: 调用此函数的文件名 (自动获取)
///   - function: 调用此函数的函数名 (自动获取)
///   - line: 调用此函数的代码行数 (自动获取)
func debugLog(
    _ message: @autoclosure () -> Any,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    print("[\(fileName):\(line)] \(function) - \(message())")
    #endif
}
