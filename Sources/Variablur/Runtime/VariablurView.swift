//
//  VariablurView.swift
//  Variablur
//
//  Created by Shindge Wong on 5/29/26.
//  Copyright © 2026 Whatsin Lab. All rights reserved.
//

#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI
import UIKit

struct VariablurView: UIViewRepresentable {
    let configuration: VariablurConfiguration

    func makeUIView(context _: Context) -> VariablurUIView {
        VariablurUIView(configuration: configuration)
    }

    func updateUIView(_ uiView: VariablurUIView, context _: Context) {
        uiView.update(configuration: configuration)
    }
}
#endif
