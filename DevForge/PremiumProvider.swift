//
//  PremiumProvider.swift
//  DevForge
//
//  Created by resistanceto on 2025-09-05.
//

import Observation
import SwiftUI

@MainActor
protocol PremiumStatusProvider: Observable {
    var hasPremium: Bool { get }
    func prepare() async

    @ViewBuilder func makeSponsorView() -> AnyView
    @ViewBuilder func makeThankYouView() -> AnyView
}

@MainActor
@Observable
final class DemoPremiumProvider: PremiumStatusProvider {
    var hasPremium: Bool = true
    func prepare() async {}

    @ViewBuilder func makeSponsorView() -> AnyView {
        AnyView(DemoSponsorView())
    }

    @ViewBuilder func makeThankYouView() -> AnyView {
        AnyView(DemoThankYouView())
    }
}

private struct PremiumProviderKey: EnvironmentKey {
    @MainActor static var defaultValue: any PremiumStatusProvider = DemoPremiumProvider()
}

extension EnvironmentValues {
    var premiumProvider: any PremiumStatusProvider {
        get { self[PremiumProviderKey.self] }
        set { self[PremiumProviderKey.self] = newValue }
    }
}
