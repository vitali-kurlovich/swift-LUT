//
//  LUTConvert.swift
//  swift-LUT
//
//  Created by Kurlovich Vitali on 11/3/26.
//

import Compression
import Foundation
import LUT

private let usage = """
OVERVIEW: Convert .cube LUT files into compressed binary .pcube files.

USAGE: lut-convert <input.cube>... [-o <path>] [-a <algorithm>] [--verify]

ARGUMENTS:
  <input.cube>            One or more .cube files to convert.

OPTIONS:
  -o, --output <path>     Output file (single input) or directory (any number of inputs).
                          Defaults to the input path with a .pcube extension.
  --verify                Load each written file back and check it matches the source.
  -h, --help              Show this help.
"""

private struct ConvertError: LocalizedError {
    let errorDescription: String?

    init(_ message: String) {
        errorDescription = message
    }
}

private struct Options {
    var inputs: [URL] = []
    var output: URL?
    var verify = false

    init(_ arguments: [String]) throws {
        var iterator = arguments.makeIterator()

        while let argument = iterator.next() {
            switch argument {
            case "-h", "--help":
                print(usage)
                exit(0)

            case "-o", "--output":
                guard let path = iterator.next() else {
                    throw ConvertError("Missing value for \(argument).")
                }
                output = URL(filePath: path)

            case "--verify":
                verify = true

            default:
                guard argument.hasPrefix("-") == false else {
                    throw ConvertError("Unknown option \(argument).")
                }
                inputs.append(URL(filePath: argument))
            }
        }

        guard inputs.isEmpty == false else {
            throw ConvertError("No input files.")
        }
    }

    private static func algorithm(named name: String) throws -> Algorithm {
        switch name.lowercased() {
        case "lzma": .lzma
        case "lzfse": .lzfse
        case "zlib": .zlib
        case "lz4": .lz4
        default: throw ConvertError("Unknown algorithm \(name).")
        }
    }

    func outputURL(for input: URL) -> URL {
        let fileName = input.deletingPathExtension().appendingPathExtension("pcube").lastPathComponent

        guard let output else {
            return input.deletingPathExtension().appendingPathExtension("pcube")
        }

        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: output.path(percentEncoded: false), isDirectory: &isDirectory)

        if (exists && isDirectory.boolValue) || inputs.count > 1 {
            return output.appending(path: fileName)
        }

        return output
    }
}

@main
struct LUTConvert {
    static func main() async {
        do {
            let options = try Options(Array(CommandLine.arguments.dropFirst()))
            try await run(options)
        } catch {
            FileHandle.standardError.write(Data("error: \(error.localizedDescription)\n".utf8))
            exit(1)
        }
    }

    private static func run(_ options: Options) async throws {
        if options.inputs.count > 1, let output = options.output {
            try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        }

        var failures = 0

        for input in options.inputs {
            let output = options.outputURL(for: input)

            do {
                let cube = try CubeLUT(input)
                try await BCubeLUTIO
                    .save(cube: cube, to: output)

                if options.verify {
                    let loaded = try BCubeLUTIO.load(output)
                    guard loaded.payload == cube.payload else {
                        throw ConvertError("Verification failed: \(output.path(percentEncoded: false)) does not match source.")
                    }

                    let loadedData = try await loaded.data()
                    let cubeData = try await cube.data()

                    guard loadedData == cubeData else {
                        throw ConvertError("Verification failed: \(output.path(percentEncoded: false)) does not match source.")
                    }
                }

                print("\(input.path(percentEncoded: false)) -> \(output.path(percentEncoded: false)) (\(sizeDescription(input)) -> \(sizeDescription(output)))")
            } catch {
                failures += 1
                FileHandle.standardError.write(Data("error: \(input.path(percentEncoded: false)): \(error.localizedDescription)\n".utf8))
            }
        }

        if failures > 0 {
            throw ConvertError("\(failures) of \(options.inputs.count) file(s) failed.")
        }
    }

    private static func sizeDescription(_ url: URL) -> String {
        let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }
}
