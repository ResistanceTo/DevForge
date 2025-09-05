//
//  ThankYouView.swift
//  DevForge
//
//  Created by resistanceto on 2025-09-05.
//

import SwiftUI

struct ThankYouView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            // 顶部视觉元素
            VStack {
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.yellow, .pink)
                Text("Thank You for Your Support!")
                    .font(.largeTitle.weight(.bold))
                Text("Your sponsorship is the greatest motivation for me to continue developing and maintaining DevForge.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()

            Divider()

            // App 图标选择
            VStack(alignment: .leading) {
                Text("Supporter Exclusive")
                    .font(.headline)
                Text("As a token of my appreciation, you can choose a special app icon:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

//                Picker("App Icon", selection: $selectedIcon) {
//                    Text("Default").tag(nil as String?) // 默认图标的 tag 是 nil
//                    Text("Gold").tag("GoldIcon" as String?) // 金色图标的 tag 是它的名字
//                    // 你可以添加更多图标...
//                }
//                .pickerStyle(.segmented)
//                .onChange(of: selectedIcon) { _, newIcon in
//                    // 调用 AppKit API 来更换图标
//                    NSApplication.shared.setAlternateIconName(newIcon)
//                }
            }

            Spacer()

            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .frame(minWidth: 500, minHeight: 400)
    }
}

#Preview {
    ThankYouView()
}
