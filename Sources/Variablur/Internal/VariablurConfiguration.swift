//
//  VariablurConfiguration.swift
//  Variablur
//
//  Created by Shindge Wong on 5/29/26.
//  Copyright © 2026 Whatsin Lab. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI

enum VariablurMode: Equatable {
    case all(curve: Curve)
    case directional(
        curve: Curve,
        startPoint: UnitPoint,
        endPoint: UnitPoint,
        height: CGFloat
    )
}

struct VariablurConfiguration: Equatable {
    var radius: CGFloat
    var mode: VariablurMode
}

extension VariablurConfiguration {
    var signature: String {
        switch mode {
        case let .all(curve):
            return "r:\(radius)|mode:all|c:\(curve)"
        case let .directional(curve, startPoint, endPoint, height):
            return "r:\(radius)|mode:directional|c:\(curve)|sx:\(startPoint.x)|sy:\(startPoint.y)|ex:\(endPoint.x)|ey:\(endPoint.y)|h:\(height)"
        }
    }
}
#endif
