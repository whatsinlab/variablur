//
//  Curve.swift
//  Variablur
//
//  Created by Shindge Wong on 5/29/26.
//  Copyright © 2026 Whatsin Lab. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI

/// A timing curve that controls how blur strength changes across a mask.
///
/// `Curve` describes the progression from the strongest blur region to the
/// clear region of a ``Variation``. Use one of the built-in curves for common
/// easing shapes, or create a custom cubic Bezier curve with
/// ``init(_:_:_:_:)``.
public struct Curve: Equatable, Sendable {
    let kind: Kind

    init(kind: Kind) {
        self.kind = kind
    }

    /// Creates a cubic Bezier timing curve.
    ///
    /// The curve starts at `(0, 0)` and ends at `(1, 1)`. The four arguments
    /// define the two intermediate control points, using the same coordinate
    /// convention as SwiftUI timing curves.
    ///
    /// - Parameters:
    ///   - p1x: The x-coordinate of the first control point of the cubic Bezier curve.
    ///   - p1y: The y-coordinate of the first control point of the cubic Bezier curve.
    ///   - p2x: The x-coordinate of the second control point of the cubic Bezier curve.
    ///   - p2y: The y-coordinate of the second control point of the cubic Bezier curve.
    public init(
        _ p1x: Double,
        _ p1y: Double,
        _ p2x: Double,
        _ p2y: Double
    ) {
        self.init(kind: .bezier(p1x, p1y, p2x, p2y))
    }

    /// Creates a curve from a native SwiftUI unit curve.
    ///
    /// Because `UnitCurve` does not expose its control points, Variablur samples
    /// it once and evaluates the sampled table in the mask shader.
    ///
    /// - Parameter unitCurve: The SwiftUI curve to sample.
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    public init(_ unitCurve: UnitCurve) {
        self.init(kind: .sampled((0 ... 8).map { index in
            unitCurve.value(at: Double(index) / 8.0)
        }))
    }

    /// A linear progression.
    public static let linear = Self(0, 0, 1, 1)

    /// A cubic ease-in progression.
    public static let easeIn = Self(0.42, 0, 1, 1)

    /// A cubic ease-out progression.
    public static let easeOut = Self(0, 0, 0.58, 1)

    /// A cubic ease-in-out progression.
    public static let easeInOut = Self(0.42, 0, 0.58, 1)

    /// A sine ease-in progression.
    public static let sineIn = Self(0.12, 0, 0.39, 0)

    /// A sine ease-out progression.
    public static let sineOut = Self(0.61, 1, 0.88, 1)

    /// A sine ease-in-out progression.
    public static let sineInOut = Self(0.37, 0, 0.63, 1)

    /// A quadratic ease-in progression.
    public static let quadIn = Self(0.11, 0, 0.5, 0)

    /// A quadratic ease-out progression.
    public static let quadOut = Self(0.5, 1, 0.89, 1)

    /// A quadratic ease-in-out progression.
    public static let quadInOut = Self(0.45, 0, 0.55, 1)

    /// A cubic ease-in progression with a steeper start than ``easeIn``.
    public static let cubicIn = Self(0.32, 0, 0.67, 0)

    /// A cubic ease-out progression with a stronger finish than ``easeOut``.
    public static let cubicOut = Self(0.33, 1, 0.68, 1)

    /// A cubic ease-in-out progression with a stronger middle transition than
    /// ``easeInOut``.
    public static let cubicInOut = Self(0.65, 0, 0.35, 1)

    /// A quartic ease-in progression.
    public static let quartIn = Self(0.5, 0, 0.75, 0)

    /// A quartic ease-out progression.
    public static let quartOut = Self(0.25, 1, 0.5, 1)

    /// A quartic ease-in-out progression.
    public static let quartInOut = Self(0.76, 0, 0.24, 1)

    /// A quintic ease-in progression.
    public static let quintIn = Self(0.64, 0, 0.78, 0)

    /// A quintic ease-out progression.
    public static let quintOut = Self(0.22, 1, 0.36, 1)

    /// A quintic ease-in-out progression.
    public static let quintInOut = Self(0.83, 0, 0.17, 1)

    /// An exponential ease-in progression.
    public static let expoIn = Self(0.7, 0, 0.84, 0)

    /// An exponential ease-out progression.
    public static let expoOut = Self(0.16, 1, 0.3, 1)

    /// An exponential ease-in-out progression.
    public static let expoInOut = Self(0.87, 0, 0.13, 1)

    /// A circular ease-in progression.
    public static let circIn = Self(0.55, 0, 1, 0.45)

    /// A circular ease-out progression.
    public static let circOut = Self(0, 0.55, 0.45, 1)

    /// A circular ease-in-out progression.
    public static let circInOut = Self(0.85, 0, 0.15, 1)

    enum Kind: Equatable, Sendable {
        case bezier(Double, Double, Double, Double)
        case sampled([Double])
    }
}
#endif
