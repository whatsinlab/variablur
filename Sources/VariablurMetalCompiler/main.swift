//
//  main.swift
//  Variablur
//
//  Created by Shindge Wong on 5/29/26.
//  Copyright © 2026 Whatsin Lab. All rights reserved.
//

#if os(macOS)
import Foundation

enum CompilerFailure: Error, LocalizedError {
    case missing(String)
    case commandFailed(String)
    case outputOutsidePluginDirectory(String)

    var errorDescription: String? {
        switch self {
        case let .missing(name):
            return "Missing required argument: \(name)"
        case let .commandFailed(output):
            return output
        case let .outputOutsidePluginDirectory(path):
            return "Output path is outside the plugin work directory: \(path)"
        }
    }
}

struct Invocation {
    let input: String
    let iosOutput: String
    let macOSOutput: String
    let workDirectory: String
}

func argument(_ name: String) -> String? {
    guard let index = CommandLine.arguments.firstIndex(of: name),
          CommandLine.arguments.indices.contains(index + 1)
    else {
        return nil
    }
    return CommandLine.arguments[index + 1]
}

func parseInvocation() throws -> Invocation {
    guard let input = argument("--input") else {
        throw CompilerFailure.missing("--input")
    }
    guard let iosOutput = argument("--ios-output") else {
        throw CompilerFailure.missing("--ios-output")
    }
    guard let macOSOutput = argument("--macos-output") else {
        throw CompilerFailure.missing("--macos-output")
    }
    guard let workDirectory = argument("--work-directory") else {
        throw CompilerFailure.missing("--work-directory")
    }

    let root = URL(fileURLWithPath: workDirectory).standardizedFileURL.path
    for output in [iosOutput, macOSOutput] {
        let path = URL(fileURLWithPath: output).standardizedFileURL.path
        guard path.hasPrefix(root) else {
            throw CompilerFailure.outputOutsidePluginDirectory(path)
        }
    }

    return Invocation(
        input: input,
        iosOutput: iosOutput,
        macOSOutput: macOSOutput,
        workDirectory: workDirectory
    )
}

@discardableResult
func runXcrun(_ arguments: [String]) throws -> String {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
    process.arguments = arguments

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    try process.run()
    process.waitUntilExit()

    let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    guard process.terminationStatus == 0 else {
        throw CompilerFailure.commandFailed(output)
    }
    return output
}

func compile(input: String, sdk: String, minVersionFlag: String, minVersion: String, output: String) throws {
    let outputURL = URL(fileURLWithPath: output)
    try FileManager.default.createDirectory(
        at: outputURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )

    let airURL = outputURL.deletingPathExtension().appendingPathExtension("air")
    defer {
        try? FileManager.default.removeItem(at: airURL)
    }

    try runXcrun([
        "--sdk", sdk,
        "metal",
        "-c",
        "-fcikernel",
        "-fmodules=none",
        minVersionFlag + minVersion,
        input,
        "-o", airURL.path,
    ])

    try runXcrun([
        "--sdk", sdk,
        "metallib",
        "-cikernel",
        airURL.path,
        "-o", outputURL.path,
    ])
}

do {
    let invocation = try parseInvocation()
    try compile(
        input: invocation.input,
        sdk: "iphoneos",
        minVersionFlag: "-mios-version-min=",
        minVersion: "14.0",
        output: invocation.iosOutput
    )
    try compile(
        input: invocation.input,
        sdk: "macosx",
        minVersionFlag: "-mmacosx-version-min=",
        minVersion: "11.0",
        output: invocation.macOSOutput
    )
} catch {
    FileHandle.standardError.write(Data((error.localizedDescription + "\n").utf8))
    Foundation.exit(1)
}
#else
import Foundation

FileHandle.standardError.write(Data("VariablurMetalCompiler requires macOS.\n".utf8))
Foundation.exit(1)
#endif
