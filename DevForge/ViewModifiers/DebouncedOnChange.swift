//
//  DebouncedOnChange.swift
//  DevForge
//
//  Created by resistanceto on 2025-09-03.
//

import Combine
import SwiftUI

/// 一个视图修饰符，它会监听一个值的变化，并在值停止变化一段时间后执行一个**可抛出错误**的操作。
struct DebouncedOnChangeModifier<V: Equatable>: ViewModifier {
    /// 要被onChange关注的变量
    let value: V
    /// 防抖时间
    let duration: Duration
    /// 是一个可抛出错误的闭包
    let action: (V) throws -> Void
    /// 错误信息
    let errorMessage: Binding<String?>
    /// 自定义一个捕获到错误后需要执行的函数
    let errorAction: (() -> Void)?

    @State private var debounceTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .onChange(of: value) { _, newValue in
                debounceTask?.cancel()
                debounceTask = Task {
                    do {
                        try await Task.sleep(for: duration)
                        guard !Task.isCancelled else { return }

                        // 在主线程上执行可能会失败的操作
                        await MainActor.run {
                            do {
                                // ✅ 3. 在 do-catch 块中调用 action
                                try action(newValue)
                                errorMessage.wrappedValue = nil
                            } catch {
                                errorMessage.wrappedValue = error.localizedDescription
                                errorAction?()
                            }
                        }
                    } catch is CancellationError {
                        // 忽略 Task.sleep 的取消错误
                    } catch {}
                }
            }
    }
}

extension View {
    /// 监听一个值的变化，并在值停止变化一段时间后执行一个**可抛出错误**的操作。
    func debouncedOnChange<V: Equatable>(
        of value: V,
        duration: Duration = .milliseconds(300),
        // perform 闭包现在标记为 throws
        perform action: @escaping (_ newValue: V) throws -> Void,
        onError errorMessage: Binding<String?> = .constant(nil),
        errorAction: (() -> Void)? = nil
    ) -> some View {
        modifier(
            DebouncedOnChangeModifier(
                value: value,
                duration: duration,
                action: action,
                errorMessage: errorMessage,
                errorAction: errorAction
            )
        )
    }
}
