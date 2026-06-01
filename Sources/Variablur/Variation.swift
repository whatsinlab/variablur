//
//  Variation.swift
//  Variablur
//
//  Created by Shindge Wong on 5/29/26.
//  Copyright © 2026 Whatsin Lab. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI

/// A mask layout for a variable blur effect.
///
/// A variation describes where blur appears, which direction it fades, and
/// which ``Curve`` shapes the transition. Pass a variation to
/// ``SwiftUI/View/blur(_:variation:ignoreSafeArea:)``.
public enum Variation: Equatable, Sendable {
    /// Creates perimeter-oriented blur across the whole view.
    ///
    /// Use this case when the blur should follow the view's rounded display
    /// perimeter rather than a single directional edge.
    ///
    /// - Parameter curve: The curve that maps mask distance to blur strength.
    case all(_ curve: Curve = .easeInOut)

    /// Creates directional blur that starts at the top edge.
    ///
    /// - Parameters:
    ///   - curve: The curve that maps distance from the start point to blur strength.
    ///   - from: The point where blur is strongest. The default is `.top`.
    ///   - to: The point where blur fades toward zero. When `nil`, Variablur
    ///     uses the opposite of `from`.
    ///   - height: The fade distance, in points.
    case top(
        _ curve: Curve = .easeInOut,
        from: UnitPoint = .top,
        to: UnitPoint? = nil,
        height: CGFloat
    )

    /// Creates directional blur that starts at the bottom edge.
    ///
    /// - Parameters:
    ///   - curve: The curve that maps distance from the start point to blur strength.
    ///   - from: The point where blur is strongest. The default is `.bottom`.
    ///   - to: The point where blur fades toward zero. When `nil`, Variablur
    ///     uses the opposite of `from`.
    ///   - height: The fade distance, in points.
    case bottom(
        _ curve: Curve = .easeInOut,
        from: UnitPoint = .bottom,
        to: UnitPoint? = nil,
        height: CGFloat
    )

    /// Creates directional blur that starts at the leading edge.
    ///
    /// - Parameters:
    ///   - curve: The curve that maps distance from the start point to blur strength.
    ///   - from: The point where blur is strongest. The default is `.leading`.
    ///   - to: The point where blur fades toward zero. When `nil`, Variablur
    ///     uses the opposite of `from`.
    ///   - height: The fade distance, in points.
    case leading(
        _ curve: Curve = .easeInOut,
        from: UnitPoint = .leading,
        to: UnitPoint? = nil,
        height: CGFloat
    )

    /// Creates directional blur that starts at the trailing edge.
    ///
    /// - Parameters:
    ///   - curve: The curve that maps distance from the start point to blur strength.
    ///   - from: The point where blur is strongest. The default is `.trailing`.
    ///   - to: The point where blur fades toward zero. When `nil`, Variablur
    ///     uses the opposite of `from`.
    ///   - height: The fade distance, in points.
    case trailing(
        _ curve: Curve = .easeInOut,
        from: UnitPoint = .trailing,
        to: UnitPoint? = nil,
        height: CGFloat
    )

    /// Creates leading and trailing directional blur.
    ///
    /// When `from` is `nil`, Variablur renders both leading and trailing edge
    /// blurs. When `from` has a value, Variablur renders one custom horizontal
    /// direction.
    ///
    /// - Parameters:
    ///   - curve: The curve that maps distance from the start point to blur strength.
    ///   - from: The point where blur is strongest. Use `nil` to render both
    ///     horizontal edges.
    ///   - to: The point where blur fades toward zero. When `nil`, Variablur
    ///     uses the opposite of `from`.
    ///   - height: The fade distance, in points.
    case horizontal(
        _ curve: Curve = .easeInOut,
        from: UnitPoint? = nil,
        to: UnitPoint? = nil,
        height: CGFloat
    )

    /// Creates top and bottom directional blur.
    ///
    /// When `from` is `nil`, Variablur renders both top and bottom edge blurs.
    /// When `from` has a value, Variablur renders one custom vertical direction.
    ///
    /// - Parameters:
    ///   - curve: The curve that maps distance from the start point to blur strength.
    ///   - from: The point where blur is strongest. Use `nil` to render both
    ///     vertical edges.
    ///   - to: The point where blur fades toward zero. When `nil`, Variablur
    ///     uses the opposite of `from`.
    ///   - height: The fade distance, in points.
    case vertical(
        _ curve: Curve = .easeInOut,
        from: UnitPoint? = nil,
        to: UnitPoint? = nil,
        height: CGFloat
    )
}

extension Variation {
    /// Returns a copy of this variation with a custom directional start point.
    ///
    /// Use this method to customize an existing directional variation with a
    /// fluent syntax:
    ///
    /// ```swift
    /// .bottom(.easeOut, height: 96)
    ///     .from(.bottomTrailing)
    ///     .to(.topLeading)
    /// ```
    ///
    /// ``Variation/all(_:)`` variations are perimeter based and do not have a
    /// start point, so this method returns them unchanged.
    ///
    /// - Parameter point: The point where blur is strongest.
    /// - Returns: A variation with the specified start point.
    public func from(_ point: UnitPoint) -> Self {
        switch self {
        case .all:
            return self
        case let .top(curve, _, to, height):
            return .top(curve, from: point, to: to, height: height)
        case let .bottom(curve, _, to, height):
            return .bottom(curve, from: point, to: to, height: height)
        case let .leading(curve, _, to, height):
            return .leading(curve, from: point, to: to, height: height)
        case let .trailing(curve, _, to, height):
            return .trailing(curve, from: point, to: to, height: height)
        case let .horizontal(curve, _, to, height):
            return .horizontal(curve, from: point, to: to, height: height)
        case let .vertical(curve, _, to, height):
            return .vertical(curve, from: point, to: to, height: height)
        }
    }

    /// Returns a copy of this variation with a custom directional end point.
    ///
    /// Use this method with ``from(_:)`` to customize an existing directional
    /// variation while preserving its curve and height.
    ///
    /// ``Variation/all(_:)`` variations are perimeter based and do not have an
    /// end point, so this method returns them unchanged.
    ///
    /// - Parameter point: The point where blur fades toward zero.
    /// - Returns: A variation with the specified end point.
    public func to(_ point: UnitPoint) -> Self {
        switch self {
        case .all:
            return self
        case let .top(curve, from, _, height):
            return .top(curve, from: from, to: point, height: height)
        case let .bottom(curve, from, _, height):
            return .bottom(curve, from: from, to: point, height: height)
        case let .leading(curve, from, _, height):
            return .leading(curve, from: from, to: point, height: height)
        case let .trailing(curve, from, _, height):
            return .trailing(curve, from: from, to: point, height: height)
        case let .horizontal(curve, from, _, height):
            return .horizontal(curve, from: from, to: point, height: height)
        case let .vertical(curve, from, _, height):
            return .vertical(curve, from: from, to: point, height: height)
        }
    }

    func configurations(radius: CGFloat) -> [VariablurConfiguration] {
        switch self {
        case let .all(curve):
            return [.all(radius: radius, curve: curve)]

        case let .top(curve, from, to, height),
             let .bottom(curve, from, to, height),
             let .leading(curve, from, to, height),
             let .trailing(curve, from, to, height):
            return [
                .directional(
                    radius: radius,
                    curve: curve,
                    from: from,
                    to: to ?? from.variablurOpposite,
                    height: height
                ),
            ]

        case let .horizontal(curve, from, to, height):
            if let from {
                return [
                    .directional(
                        radius: radius,
                        curve: curve,
                        from: from,
                        to: to ?? from.variablurOpposite,
                        height: height
                    ),
                ]
            }
            return [
                .directional(radius: radius, curve: curve, from: .leading, to: .trailing, height: height),
                .directional(radius: radius, curve: curve, from: .trailing, to: .leading, height: height),
            ]

        case let .vertical(curve, from, to, height):
            if let from {
                return [
                    .directional(
                        radius: radius,
                        curve: curve,
                        from: from,
                        to: to ?? from.variablurOpposite,
                        height: height
                    ),
                ]
            }
            return [
                .directional(radius: radius, curve: curve, from: .top, to: .bottom, height: height),
                .directional(radius: radius, curve: curve, from: .bottom, to: .top, height: height),
            ]
        }
    }
}

extension VariablurConfiguration {
    static func all(radius: CGFloat, curve: Curve) -> Self {
        VariablurConfiguration(radius: radius, mode: .all(curve: curve))
    }

    static func directional(
        radius: CGFloat,
        curve: Curve,
        from startPoint: UnitPoint,
        to endPoint: UnitPoint,
        height: CGFloat
    ) -> Self {
        VariablurConfiguration(
            radius: radius,
            mode: .directional(
                curve: curve,
                startPoint: startPoint,
                endPoint: endPoint,
                height: height
            )
        )
    }
}

extension UnitPoint {
    var variablurOpposite: UnitPoint {
        UnitPoint(x: 1 - x, y: 1 - y)
    }
}
#endif
