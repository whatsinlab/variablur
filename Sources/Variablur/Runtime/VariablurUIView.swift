//
//  VariablurUIView.swift
//  Variablur
//
//  Created by Shindge Wong on 5/29/26.
//  Copyright © 2026 Whatsin Lab. All rights reserved.
//

#if canImport(UIKit)
import OSLog
import UIKit

final class VariablurUIView: UIVisualEffectView {
    private let logger = Logger(subsystem: "com.whatsinlab.variablur", category: "VariablurUIView")

    private var configuration: VariablurConfiguration
    private var backdropFilter: NSObject?
    private var lastMaskSignature: String?

    private var currentScale: CGFloat {
        window?.screen.scale ?? UIScreen.main.scale
    }

    init(configuration: VariablurConfiguration) {
        self.configuration = configuration
        super.init(effect: UIBlurEffect(style: .regular))
        isUserInteractionEnabled = false
        installBackdropFilterIfNeeded()
        updateMask(for: bounds.size, force: true)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(configuration: VariablurConfiguration) {
        guard self.configuration != configuration else {
            return
        }

        self.configuration = configuration
        backdropFilter?.setValue(configuration.radius, forKey: BackdropFilterRuntime.radiusInputKey)
        updateMask(for: bounds.size, force: true)
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if let backdropLayer = subviews.first?.layer {
            backdropLayer.setValue(currentScale, forKey: BackdropFilterRuntime.layerCaptureScaleKey)
        }
        installBackdropFilterIfNeeded()
        updateMask(for: bounds.size, force: true)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateMask(for: bounds.size, force: false)
    }

    override func traitCollectionDidChange(_: UITraitCollection?) {
        // Intentionally kept empty to avoid runtime issues with private filter internals.
    }

    private var effectLayer: CALayer? {
        subviews.first?.layer
    }

    private func installBackdropFilterIfNeeded() {
        if backdropFilter != nil {
            return
        }

        guard let filterClass = NSClassFromString(BackdropFilterRuntime.filterClassName) as? NSObject.Type else {
            logger.error("Failed to resolve CAFilter runtime class.")
            return
        }

        guard
            let filter = filterClass.perform(
                NSSelectorFromString(BackdropFilterRuntime.filterFactorySelector),
                with: BackdropFilterRuntime.variableBackdropFilterType
            )?.takeUnretainedValue() as? NSObject
        else {
            logger.error("Failed to instantiate variable blur filter.")
            return
        }

        filter.setValue(configuration.radius, forKey: BackdropFilterRuntime.radiusInputKey)
        filter.setValue(true, forKey: BackdropFilterRuntime.edgeNormalizationInputKey)
        effectLayer?.filters = [filter]

        for subview in subviews.dropFirst() {
            subview.alpha = 0
        }

        backdropFilter = filter
    }

    private func updateMask(for size: CGSize, force: Bool) {
        guard size.width > 0, size.height > 0 else {
            return
        }

        installBackdropFilterIfNeeded()
        guard let backdropFilter else {
            return
        }

        let signature = "w:\(size.width)|h:\(size.height)|s:\(currentScale)|\(configuration.signature)"
        if !force, lastMaskSignature == signature {
            return
        }
        lastMaskSignature = signature

        guard let maskImage = VariablurMaskRenderer.makeMaskImage(
            size: size,
            scale: currentScale,
            configuration: configuration
        ) else {
            logger.error("Failed to generate variable blur mask image.")
            return
        }

        backdropFilter.setValue(maskImage, forKey: BackdropFilterRuntime.maskImageInputKey)
        refreshInstalledFilter(backdropFilter)
    }

    private func refreshInstalledFilter(_ filter: NSObject) {
        guard let effectLayer else {
            return
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        effectLayer.filters = []
        effectLayer.filters = [filter]
        CATransaction.commit()
    }
}
#endif
