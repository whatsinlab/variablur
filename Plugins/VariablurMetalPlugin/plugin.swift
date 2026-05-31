//
//  plugin.swift
//  Variablur
//
//  Created by Shindge Wong on 5/29/26.
//  Copyright © 2026 Whatsin Lab. All rights reserved.
//

import Foundation
import PackagePlugin

@main
struct VariablurMetalPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let target = target as? SourceModuleTarget else {
            return []
        }

        let kernels = target.sourceFiles.filter { file in
            file.url.lastPathComponent.hasSuffix(".ci.metal")
        }

        guard !kernels.isEmpty else {
            return []
        }

        let compiler = try context.tool(named: "VariablurMetalCompiler")
        return kernels.map { file in
            let baseName = file.url.deletingPathExtension().lastPathComponent
                .replacingOccurrences(of: ".ci", with: "")
            let iosOutput = context.pluginWorkDirectoryURL.appending(path: "\(baseName).iOS.metallib")
            let macOSOutput = context.pluginWorkDirectoryURL.appending(path: "\(baseName).macOS.metallib")

            return .buildCommand(
                displayName: "Compile Variablur Core Image kernels",
                executable: compiler.url,
                arguments: [
                    "--input", file.url.path(percentEncoded: false),
                    "--ios-output", iosOutput.path(percentEncoded: false),
                    "--macos-output", macOSOutput.path(percentEncoded: false),
                    "--work-directory", context.pluginWorkDirectoryURL.path(percentEncoded: false),
                ],
                inputFiles: [file.url],
                outputFiles: [iosOutput, macOSOutput]
            )
        }
    }
}

