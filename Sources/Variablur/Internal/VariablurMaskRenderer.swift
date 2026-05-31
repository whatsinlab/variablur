//
//  VariablurMaskRenderer.swift
//  Variablur
//
//  Created by Shindge Wong on 5/29/26.
//  Copyright © 2026 Whatsin Lab. All rights reserved.
//

#if canImport(UIKit)
import CoreImage
import OSLog
import SwiftUI
import UIKit

private final class CachedMaskImage {
    let image: CGImage

    init(_ image: CGImage) {
        self.image = image
    }
}

@MainActor
enum VariablurMaskRenderer {
    private static let logger = Logger(subsystem: "com.whatsinlab.variablur", category: "VariablurMaskRenderer")
    private static let renderedMasks = NSCache<NSString, CachedMaskImage>()

    private static let context = CIContext(options: [
        .workingColorSpace: CGColorSpace(name: CGColorSpace.linearSRGB) as Any,
        .outputColorSpace: CGColorSpace(name: CGColorSpace.linearSRGB) as Any,
        .cacheIntermediates: false,
        .priorityRequestLow: true,
    ])

    static func makeMaskImage(
        size: CGSize,
        scale: CGFloat,
        configuration: VariablurConfiguration
    ) -> CGImage? {
        let canvas = MaskCanvas(size: size, scale: scale)
        let key = cacheKey(canvas: canvas, scale: scale, configuration: configuration)

        if let cached = renderedMasks.object(forKey: key as NSString) {
            return cached.image
        }

        guard let invocation = KernelInvocation(canvas: canvas, scale: scale, configuration: configuration) else {
            return nil
        }

        guard let output = invocation.kernel.apply(extent: canvas.extent, arguments: invocation.arguments) else {
            logger.error("Failed to apply Core Image mask kernel.")
            return nil
        }

        guard let cgImage = context.createCGImage(output, from: canvas.extent) else {
            logger.error("Failed to render Core Image mask output.")
            return nil
        }

        renderedMasks.setObject(CachedMaskImage(cgImage), forKey: key as NSString)
        return cgImage
    }

    private static func cacheKey(
        canvas: MaskCanvas,
        scale: CGFloat,
        configuration: VariablurConfiguration
    ) -> String {
        "canvas=\(canvas.width)x\(canvas.height);scale=\(scale);\(configuration.signature)"
    }
}

private struct MaskCanvas {
    let width: Int
    let height: Int

    init(size: CGSize, scale: CGFloat) {
        width = max(1, Int(ceil(size.width * scale)))
        height = max(1, Int(ceil(size.height * scale)))
    }

    var extent: CGRect {
        CGRect(x: 0, y: 0, width: width, height: height)
    }
}

private struct KernelInvocation {
    let kernel: CIColorKernel
    let arguments: [Any]

    init?(canvas: MaskCanvas, scale: CGFloat, configuration: VariablurConfiguration) {
        switch configuration.mode {
        case let .all(curve):
            guard let kernel = VariablurShaderLibrary.allMask else {
                return nil
            }
            let encodedCurve = curve.encodedForMaskKernel()
            self.kernel = kernel
            arguments = [
                Float(canvas.width),
                Float(canvas.height),
                Float(Self.cornerRadius(canvas: canvas, scale: scale)),
                Float(max(1.0, 16.0 * Double(scale))),
                encodedCurve.mode,
                encodedCurve.values[0],
                encodedCurve.values[1],
                encodedCurve.values[2],
                encodedCurve.values[3],
                encodedCurve.values[4],
                encodedCurve.values[5],
                encodedCurve.values[6],
                encodedCurve.values[7],
                encodedCurve.values[8],
            ]

        case let .directional(curve, startPoint, endPoint, height):
            guard let kernel = VariablurShaderLibrary.directionalMask else {
                return nil
            }
            let ramp = DirectionalRamp(
                canvas: canvas,
                scale: scale,
                startPoint: startPoint,
                endPoint: endPoint,
                height: height
            )
            let encodedCurve = curve.encodedForMaskKernel()
            self.kernel = kernel
            arguments = [
                Float(canvas.width),
                Float(canvas.height),
                Float(ramp.start.x),
                Float(ramp.start.y),
                Float(ramp.end.x),
                Float(ramp.end.y),
                Float(ramp.length),
                encodedCurve.mode,
                encodedCurve.values[0],
                encodedCurve.values[1],
                encodedCurve.values[2],
                encodedCurve.values[3],
                encodedCurve.values[4],
                encodedCurve.values[5],
                encodedCurve.values[6],
                encodedCurve.values[7],
                encodedCurve.values[8],
            ]
        }
    }

    private static func cornerRadius(canvas: MaskCanvas, scale: CGFloat) -> Double {
        let screenBased = Double(UIScreen.main.variablurDisplayCornerRadius * scale)
        let fallback = Double(min(canvas.width, canvas.height)) * 0.12
        let chosen = screenBased > 0 ? screenBased : fallback
        return min(chosen, Double(min(canvas.width, canvas.height)) * 0.5)
    }
}

private struct DirectionalRamp {
    let start: CGPoint
    let end: CGPoint
    let length: Double

    init(
        canvas: MaskCanvas,
        scale: CGFloat,
        startPoint: UnitPoint,
        endPoint: UnitPoint,
        height: CGFloat
    ) {
        start = Self.point(for: startPoint, canvas: canvas)
        end = Self.point(for: endPoint, canvas: canvas)

        if height.isFinite {
            length = max(1.0, Double(height * scale))
        } else {
            let dx = end.x - start.x
            let dy = end.y - start.y
            length = max(1.0, sqrt(dx * dx + dy * dy))
        }
    }

    private static func point(for unit: UnitPoint, canvas: MaskCanvas) -> CGPoint {
        // Public UnitPoint follows SwiftUI/UIKit top-left coordinates. Core Image
        // destination coordinates use the image-space vertical orientation, so
        // flip Y before passing directional endpoints into the Metal kernel.
        CGPoint(
            x: unit.x * CGFloat(max(canvas.width - 1, 1)),
            y: (1 - unit.y) * CGFloat(max(canvas.height - 1, 1))
        )
    }
}

private struct EncodedCurve {
    let mode: Float
    let values: [Float]

    static func bezier(_ p1x: Double, _ p1y: Double, _ p2x: Double, _ p2y: Double) -> Self {
        EncodedCurve(
            mode: 0,
            values: [
                Float(p1x),
                Float(p1y),
                Float(p2x),
                Float(p2y),
                0,
                0,
                0,
                0,
                0,
            ]
        )
    }

    static func sampled(_ samples: [Double]) -> Self {
        let values = Array((samples + Array(repeating: 1.0, count: 9)).prefix(9))
        return EncodedCurve(mode: 1, values: values.map(Float.init))
    }
}

private extension Curve {
    func encodedForMaskKernel() -> EncodedCurve {
        switch kind {
        case let .bezier(x1, y1, x2, y2):
            return .bezier(x1, y1, x2, y2)
        case let .sampled(samples):
            return .sampled(samples)
        }
    }
}
#endif
