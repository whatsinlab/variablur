//
//  VariablurShaderLibrary.swift
//  Variablur
//
//  Created by Shindge Wong on 5/29/26.
//  Copyright © 2026 Whatsin Lab. All rights reserved.
//

#if canImport(UIKit)
import CoreImage
import Foundation
import OSLog

enum VariablurShaderLibrary {
    private static let logger = Logger(subsystem: "com.whatsinlab.variablur", category: "VariablurShaderLibrary")

    static let allMask = kernel(named: "variablurAllMask")
    static let directionalMask = kernel(named: "variablurDirectionalMask")

    private static let libraryData: Data? = {
        guard let url = Bundle.module.url(forResource: libraryName, withExtension: "metallib") else {
            logger.error("Missing bundled Metal library: \(libraryName).metallib")
            return nil
        }

        do {
            return try Data(contentsOf: url, options: .mappedIfSafe)
        } catch {
            logger.error("Failed to load bundled Metal library: \(error.localizedDescription)")
            return nil
        }
    }()

    private static var libraryName: String {
        #if os(macOS)
        "Variablur.macOS"
        #else
        "Variablur.iOS"
        #endif
    }

    private static func kernel(named name: String) -> CIColorKernel? {
        guard let libraryData else {
            return nil
        }

        do {
            return try CIColorKernel(functionName: name, fromMetalLibraryData: libraryData)
        } catch {
            logger.error("Failed to load Core Image kernel '\(name)': \(error.localizedDescription)")
            return nil
        }
    }
}
#endif
