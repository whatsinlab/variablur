//
//  UIScreen+DisplayCornerRadius.swift
//  Variablur
//
//  Created by Shindge Wong on 5/29/26.
//  Copyright © 2026 Whatsin Lab. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension UIScreen {
    var variablurDisplayCornerRadius: CGFloat {
        value(forKey: BackdropFilterRuntime.displayCornerRadiusKey) as? CGFloat ?? 0
    }
}
#endif
