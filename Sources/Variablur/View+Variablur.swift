//
//  View+Variablur.swift
//  Variablur
//
//  Created by Shindge Wong on 5/29/26.
//  Copyright © 2026 Whatsin Lab. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI

extension View {
    /// Applies a blur whose strength varies across the view.
    ///
    /// Use this modifier to add a blur overlay whose mask is described by a
    /// ``Variation``. The `radius` value controls the strongest blur amount;
    /// the variation controls where that strength appears and how it fades.
    ///
    /// The following example blurs the bottom edge of a scroll view and fades
    /// the effect into the content over 96 points:
    ///
    /// ```swift
    /// ScrollView {
    ///     content
    /// }
    /// .blur(18, variation: .bottom(.easeOut, height: 96))
    /// ```
    ///
    /// - Parameters:
    ///   - radius: The maximum blur radius, in points.
    ///   - variation: The placement, direction, and curve of the blur mask.
    ///   - ignoreSafeArea: A Boolean value that indicates whether the blur
    ///     overlay extends into safe areas.
    /// - Returns: A view with the variable blur overlay applied.
    @ViewBuilder
    public func blur(
        _ radius: CGFloat,
        variation: Variation,
        ignoreSafeArea: Bool = true
    ) -> some View {
        #if canImport(UIKit)
        let configurations = variation.configurations(radius: radius)
        overlay(
            ZStack {
                ForEach(Array(configurations.enumerated()), id: \.offset) { _, configuration in
                    VariablurView(configuration: configuration)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .variablurConditionalIgnoreSafeArea(ignoreSafeArea)
        )
        #else
        self
        #endif
    }

}

#if canImport(UIKit)
private extension View {
    @ViewBuilder
    func variablurConditionalIgnoreSafeArea(_ ignoreSafeArea: Bool) -> some View {
        if ignoreSafeArea {
            ignoresSafeArea()
        } else {
            self
        }
    }
}
#endif
#endif
