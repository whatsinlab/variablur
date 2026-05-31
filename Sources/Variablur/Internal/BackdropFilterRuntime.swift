//
//  BackdropFilterRuntime.swift
//  Variablur
//
//  Created by Shindge Wong on 5/29/26.
//  Copyright © 2026 Whatsin Lab. All rights reserved.
//

#if canImport(UIKit)
import UIKit

enum BackdropFilterRuntime {
    static let filterClassName = "CAFilter"
    static let filterFactorySelector = "filterWithType:"

    // Apple-private CAFilter type. This is a platform runtime identifier,
    // not the package name.
    static let variableBackdropFilterType = "variableBlur"

    static let radiusInputKey = "inputRadius"
    static let edgeNormalizationInputKey = "inputNormalizeEdges"
    static let maskImageInputKey = "inputMaskImage"

    static let layerCaptureScaleKey = "scale"
    static let displayCornerRadiusKey = "_displayCornerRadius"
}
#endif
