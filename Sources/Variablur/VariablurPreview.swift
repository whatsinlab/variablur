//
//  VariablurPreview.swift
//  Variablur
//
//  Created by Shindge Wong on 5/29/26.
//  Copyright © 2026 Whatsin Lab. All rights reserved.
//

#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI

private struct VariablurPreviewView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(0 ..< 20, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .frame(height: 96)
                }
            }
            .padding(.horizontal, 16)
        }
        .blur(16, variation: .bottom(.easeOut, height: 64))
    }
}

#Preview("Variablur") {
    VariablurPreviewView()
}
#endif
