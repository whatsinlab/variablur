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
    ///   - height: The fade distance, in points.
    ///   - from: The point where blur is strongest. The default is `.top`.
    ///   - to: The point where blur fades toward zero. When `nil`, Variablur
    ///     uses the opposite of `from`.
    case top(
        _ curve: Curve = .easeInOut,
        height: CGFloat,
        from: UnitPoint = .top,
        to: UnitPoint? = nil
    )

    /// Creates directional blur that starts at the bottom edge.
    ///
    /// - Parameters:
    ///   - curve: The curve that maps distance from the start point to blur strength.
    ///   - height: The fade distance, in points.
    ///   - from: The point where blur is strongest. The default is `.bottom`.
    ///   - to: The point where blur fades toward zero. When `nil`, Variablur
    ///     uses the opposite of `from`.
    case bottom(
        _ curve: Curve = .easeInOut,
        height: CGFloat,
        from: UnitPoint = .bottom,
        to: UnitPoint? = nil
    )

    /// Creates directional blur that starts at the leading edge.
    ///
    /// - Parameters:
    ///   - curve: The curve that maps distance from the start point to blur strength.
    ///   - height: The fade distance, in points.
    ///   - from: The point where blur is strongest. The default is `.leading`.
    ///   - to: The point where blur fades toward zero. When `nil`, Variablur
    ///     uses the opposite of `from`.
    case leading(
        _ curve: Curve = .easeInOut,
        height: CGFloat,
        from: UnitPoint = .leading,
        to: UnitPoint? = nil
    )

    /// Creates directional blur that starts at the trailing edge.
    ///
    /// - Parameters:
    ///   - curve: The curve that maps distance from the start point to blur strength.
    ///   - height: The fade distance, in points.
    ///   - from: The point where blur is strongest. The default is `.trailing`.
    ///   - to: The point where blur fades toward zero. When `nil`, Variablur
    ///     uses the opposite of `from`.
    case trailing(
        _ curve: Curve = .easeInOut,
        height: CGFloat,
        from: UnitPoint = .trailing,
        to: UnitPoint? = nil
    )

    /// Creates leading and trailing directional blur.
    ///
    /// When `from` is `nil`, Variablur renders both leading and trailing edge
    /// blurs. When `from` has a value, Variablur renders one custom horizontal
    /// direction.
    ///
    /// - Parameters:
    ///   - curve: The curve that maps distance from the start point to blur strength.
    ///   - height: The fade distance, in points.
    ///   - from: The point where blur is strongest. Use `nil` to render both
    ///     horizontal edges.
    ///   - to: The point where blur fades toward zero. When `nil`, Variablur
    ///     uses the opposite of `from`.
    case horizontal(
        _ curve: Curve = .easeInOut,
        height: CGFloat,
        from: UnitPoint? = nil,
        to: UnitPoint? = nil
    )

    /// Creates top and bottom directional blur.
    ///
    /// When `from` is `nil`, Variablur renders both top and bottom edge blurs.
    /// When `from` has a value, Variablur renders one custom vertical direction.
    ///
    /// - Parameters:
    ///   - curve: The curve that maps distance from the start point to blur strength.
    ///   - height: The fade distance, in points.
    ///   - from: The point where blur is strongest. Use `nil` to render both
    ///     vertical edges.
    ///   - to: The point where blur fades toward zero. When `nil`, Variablur
    ///     uses the opposite of `from`.
    case vertical(
        _ curve: Curve = .easeInOut,
        height: CGFloat,
        from: UnitPoint? = nil,
        to: UnitPoint? = nil
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
        case let .top(curve, height, _, endPoint):
            return .top(curve, height: height, from: point, to: endPoint)
        case let .bottom(curve, height, _, endPoint):
            return .bottom(curve, height: height, from: point, to: endPoint)
        case let .leading(curve, height, _, endPoint):
            return .leading(curve, height: height, from: point, to: endPoint)
        case let .trailing(curve, height, _, endPoint):
            return .trailing(curve, height: height, from: point, to: endPoint)
        case let .horizontal(curve, height, _, endPoint):
            return .horizontal(curve, height: height, from: point, to: endPoint)
        case let .vertical(curve, height, _, endPoint):
            return .vertical(curve, height: height, from: point, to: endPoint)
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
        case let .top(curve, height, startPoint, _):
            return .top(curve, height: height, from: startPoint, to: point)
        case let .bottom(curve, height, startPoint, _):
            return .bottom(curve, height: height, from: startPoint, to: point)
        case let .leading(curve, height, startPoint, _):
            return .leading(curve, height: height, from: startPoint, to: point)
        case let .trailing(curve, height, startPoint, _):
            return .trailing(curve, height: height, from: startPoint, to: point)
        case let .horizontal(curve, height, startPoint, _):
            return .horizontal(curve, height: height, from: startPoint, to: point)
        case let .vertical(curve, height, startPoint, _):
            return .vertical(curve, height: height, from: startPoint, to: point)
        }
    }

    func configurations(radius: CGFloat) -> [VariablurConfiguration] {
        switch self {
        case let .all(curve):
            return [.all(radius: radius, curve: curve)]

        case let .top(curve, height, startPoint, endPoint),
             let .bottom(curve, height, startPoint, endPoint),
             let .leading(curve, height, startPoint, endPoint),
             let .trailing(curve, height, startPoint, endPoint):
            return [
                .directional(
                    radius: radius,
                    curve: curve,
                    from: startPoint,
                    to: endPoint ?? startPoint.variablurOpposite,
                    height: height
                ),
            ]

        case let .horizontal(curve, height, startPoint, endPoint):
            if let startPoint {
                return [
                    .directional(
                        radius: radius,
                        curve: curve,
                        from: startPoint,
                        to: endPoint ?? startPoint.variablurOpposite,
                        height: height
                    ),
                ]
            }
            return [
                .directional(radius: radius, curve: curve, from: .leading, to: .trailing, height: height),
                .directional(radius: radius, curve: curve, from: .trailing, to: .leading, height: height),
            ]

        case let .vertical(curve, height, startPoint, endPoint):
            if let startPoint {
                return [
                    .directional(
                        radius: radius,
                        curve: curve,
                        from: startPoint,
                        to: endPoint ?? startPoint.variablurOpposite,
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
