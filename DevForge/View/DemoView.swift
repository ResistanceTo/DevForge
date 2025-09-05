//
//  DemoSponsorView.swift
//  DevForge
//
//  Created by resistanceto on 2025-09-05.
//

import SwiftUI

struct DemoSponsorView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button("DemoSponsorView") {
            dismiss()
        }
    }
}

struct DemoThankYouView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button("DemoThankYouView") {
            dismiss()
        }
    }
}
