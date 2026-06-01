//
//  VariablurTests.swift
//  Variablur
//
//  Created by Shindge Wong on 5/29/26.
//  Copyright © 2026 Whatsin Lab. All rights reserved.
//

import Testing
@testable import Variablur

#if canImport(SwiftUI)
import SwiftUI

@Test func bottomVariationDefaultsFromBottomToTop() async throws {
    let configurations = Variation.bottom(.linear, height: 128).configurations(radius: 32)

    #expect(configurations.count == 1)
    #expect(configurations.first?.radius == 32)

    guard case let .directional(curve, startPoint, endPoint, height) = configurations.first?.mode else {
        #expect(Bool(false), "Expected directional configuration")
        return
    }

    #expect(curve == .linear)
    #expect(startPoint == .bottom)
    #expect(endPoint == .top)
    #expect(height == 128)
}

@Test func bottomVariationDefaultsToOppositeOfCustomFromPoint() async throws {
    let configurations = Variation.bottom(
        .easeInOut,
        from: .bottomTrailing,
        height: 128
    ).configurations(radius: 24)

    guard case let .directional(curve, startPoint, endPoint, _) = configurations.first?.mode else {
        #expect(Bool(false), "Expected directional configuration")
        return
    }

    #expect(curve == .easeInOut)
    #expect(startPoint == .bottomTrailing)
    #expect(endPoint == .topLeading)
}

@Test func topVariationSupportsFullyCustomDirection() async throws {
    let configurations = Variation.top(
        .easeIn,
        from: .bottomTrailing,
        to: .top,
        height: 72
    ).configurations(radius: 18)

    guard case let .directional(curve, startPoint, endPoint, height) = configurations.first?.mode else {
        #expect(Bool(false), "Expected directional configuration")
        return
    }

    #expect(curve == .easeIn)
    #expect(startPoint == .bottomTrailing)
    #expect(endPoint == .top)
    #expect(height == 72)
}

@Test func directionalVariationSupportsFluentFromTo() async throws {
    let configurations = Variation.bottom(.linear, height: 96)
        .from(.bottomTrailing)
        .to(.topLeading)
        .configurations(radius: 20)

    guard case let .directional(curve, startPoint, endPoint, height) = configurations.first?.mode else {
        #expect(Bool(false), "Expected directional configuration")
        return
    }

    #expect(curve == .linear)
    #expect(startPoint == .bottomTrailing)
    #expect(endPoint == .topLeading)
    #expect(height == 96)
}

@Test func directionalVariationFluentFromPreservesExistingTo() async throws {
    let configurations = Variation.top(.easeOut, height: 72)
        .to(.bottom)
        .from(.topTrailing)
        .configurations(radius: 18)

    guard case let .directional(curve, startPoint, endPoint, height) = configurations.first?.mode else {
        #expect(Bool(false), "Expected directional configuration")
        return
    }

    #expect(curve == .easeOut)
    #expect(startPoint == .topTrailing)
    #expect(endPoint == .bottom)
    #expect(height == 72)
}

@Test func allVariationDoesNotCreateDirectionalConfiguration() async throws {
    let configurations = Variation.all(.easeInOut).configurations(radius: 12)

    #expect(configurations.count == 1)
    guard case let .all(curve) = configurations.first?.mode else {
        #expect(Bool(false), "Expected all configuration")
        return
    }

    #expect(curve == .easeInOut)
}

@Test func horizontalVariationCreatesBothSideConfigurations() async throws {
    let configurations = Variation.horizontal(.linear, height: 44).configurations(radius: 10)

    #expect(configurations.count == 2)

    guard case let .directional(firstCurve, firstStart, firstEnd, firstHeight) = configurations[0].mode,
          case let .directional(secondCurve, secondStart, secondEnd, secondHeight) = configurations[1].mode
    else {
        #expect(Bool(false), "Expected two directional configurations")
        return
    }

    #expect(firstCurve == .linear)
    #expect(firstStart == .leading)
    #expect(firstEnd == .trailing)
    #expect(firstHeight == 44)

    #expect(secondCurve == .linear)
    #expect(secondStart == .trailing)
    #expect(secondEnd == .leading)
    #expect(secondHeight == 44)
}

@Test func horizontalVariationSupportsCustomFromPoint() async throws {
    let configurations = Variation.horizontal(
        .easeOut,
        from: .leading,
        height: 64
    ).configurations(radius: 10)

    #expect(configurations.count == 1)

    guard case let .directional(curve, startPoint, endPoint, height) = configurations.first?.mode else {
        #expect(Bool(false), "Expected directional configuration")
        return
    }

    #expect(curve == .easeOut)
    #expect(startPoint == .leading)
    #expect(endPoint == .trailing)
    #expect(height == 64)
}

@Test func horizontalVariationSupportsFluentCustomDirection() async throws {
    let configurations = Variation.horizontal(.easeIn, height: 80)
        .from(.leading)
        .to(.trailing)
        .configurations(radius: 16)

    #expect(configurations.count == 1)

    guard case let .directional(curve, startPoint, endPoint, height) = configurations.first?.mode else {
        #expect(Bool(false), "Expected directional configuration")
        return
    }

    #expect(curve == .easeIn)
    #expect(startPoint == .leading)
    #expect(endPoint == .trailing)
    #expect(height == 80)
}

@Test func variationSupportsCustomCurve() async throws {
    let curve = Curve(0.2, 0.8, 0.4, 1)
    let configurations = Variation.bottom(
        curve,
        height: 88
    ).configurations(radius: 14)

    guard case let .directional(resolvedCurve, _, _, height) = configurations.first?.mode else {
        #expect(Bool(false), "Expected directional configuration")
        return
    }

    #expect(resolvedCurve == curve)
    #expect(height == 88)
}

@Test func curveSupportsSmoothBlurStylePresets() async throws {
    let presets: [Curve] = [
        .linear,
        .sineIn, .sineOut, .sineInOut,
        .quadIn, .quadOut, .quadInOut,
        .cubicIn, .cubicOut, .cubicInOut,
        .quartIn, .quartOut, .quartInOut,
        .quintIn, .quintOut, .quintInOut,
        .expoIn, .expoOut, .expoInOut,
        .circIn, .circOut, .circInOut,
    ]

    #expect(presets.count == 22)
    #expect(Curve.sineInOut == Curve(0.37, 0, 0.63, 1))
    #expect(Curve.expoOut == Curve(0.16, 1, 0.3, 1))
    #expect(Curve.circIn == Curve(0.55, 0, 1, 0.45))
}

@Test func variationSupportsNativeUnitCurveWhenAvailable() async throws {
    if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
        let configurations = Variation.bottom(
            Curve(.easeInOut),
            height: 88
        ).configurations(radius: 14)

        guard case let .directional(curve, _, _, height) = configurations.first?.mode else {
            #expect(Bool(false), "Expected directional configuration")
            return
        }

        if case .sampled(let samples) = curve.kind {
            #expect(samples.count == 9)
        } else {
            #expect(Bool(false), "Expected sampled transition")
        }
        #expect(height == 88)
    }
}

#else

@Test func swiftUIUnavailablePlaceholder() async throws {
    #expect(true)
}

#endif
