/*
    usage:
        xcrun --sdk macosx swiftc -parse-as-library findFlowRepresentables.swift -o FindFlowRepresentables 
        sourcekitten structure --file FR1.swift | ./FindFlowRepresentables
*/

import Foundation

@main
struct FindFlowRepresentables {
    static func main() throws {
        guard let json = readSTDIN()?.data(using: .utf8) else { print("Error: Invalid JSON passed"); return }

        let directoryPath = CommandLine.arguments[1]
        var frFiles: [String] = []

        print("foooo \(FileManager().currentDirectoryPath)")

        let filepaths = getSwiftFiles(from: directoryPath)
        var structureArray: [String] = []

        for path in filepaths {
            do {
                structureArray.append(try shell("sourcekitten structure --file \(path)"))
            } catch {
                print("\(error)")
            }
        }
        print(structureArray.count)
        guard let file = try? JSONDecoder().decode(File.self, from: json) else { print("Error: Could not parse JSON"); return }

        if let substructure = file.keySubstructure.first,
           let containsFlowRep = substructure.keyInheritedtypes?.contains(where: { $0.keyName == "FlowRepresentable" }),
           containsFlowRep == true {
            frFiles.append(substructure.keyName)
        }

        frFiles.forEach { print($0) }
    }
}

func shell(_ command: String) throws -> String {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.executableURL = URL(fileURLWithPath: "/bin/zsh")

    do {
        try task.run()
    } catch { throw error }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!

    return output
}

func getSwiftFiles(from directory: String) -> [String] {
    let url = URL(fileURLWithPath: directory)
    var files = [URL]()

    if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
        for case let fileURL as URL in enumerator {
            do {
                let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                if fileAttributes.isRegularFile! && fileURL.absoluteString.contains(".swift") {
                    files.append(fileURL)
                }
            } catch { print(error, fileURL) }
        }
        print("All Swift files in \(directory): ")
        return files.map {
            var str = $0.absoluteString
            str = String(str.suffix(from: str.range(of: directory)!.lowerBound))
            print(str)
            return str
        }
    }
    return []
}

// MARK: - File
struct File: Codable {
    let keyDiagnosticStage: String
    let keyLength, keyOffset: Int
    let keySubstructure: [KeySubstructure]

    enum CodingKeys: String, CodingKey {
        case keyDiagnosticStage = "key.diagnostic_stage"
        case keyLength = "key.length"
        case keyOffset = "key.offset"
        case keySubstructure = "key.substructure"
    }
}

// MARK: - KeySubstructure
struct KeySubstructure: Codable {
    let keyAccessibility: String?
    let keyBodylength, keyBodyoffset: Int?
    let keyElements: [KeyElement]?
    let keyInheritedtypes: [KeyInheritedtype]?
    let keyKind: String
    let keyLength: Int
    let keyName: String
    let keyNamelength, keyNameoffset, keyOffset: Int
    let keySubstructure: [KeySubstructure]?
    let keySetterAccessibility, keyTypename: String?

    enum CodingKeys: String, CodingKey {
        case keyAccessibility = "key.accessibility"
        case keyBodylength = "key.bodylength"
        case keyBodyoffset = "key.bodyoffset"
        case keyElements = "key.elements"
        case keyInheritedtypes = "key.inheritedtypes"
        case keyKind = "key.kind"
        case keyLength = "key.length"
        case keyName = "key.name"
        case keyNamelength = "key.namelength"
        case keyNameoffset = "key.nameoffset"
        case keyOffset = "key.offset"
        case keySubstructure = "key.substructure"
        case keySetterAccessibility = "key.setter_accessibility"
        case keyTypename = "key.typename"
    }
}

// MARK: - KeyElement
struct KeyElement: Codable {
    let keyKind: String
    let keyLength, keyOffset: Int

    enum CodingKeys: String, CodingKey {
        case keyKind = "key.kind"
        case keyLength = "key.length"
        case keyOffset = "key.offset"
    }
}

// MARK: - KeyInheritedtype
struct KeyInheritedtype: Codable {
    let keyName: String

    enum CodingKeys: String, CodingKey {
        case keyName = "key.name"
    }
}

func readSTDIN () -> String? {
  var input: String?

  while let line = readLine() {
      if input == nil {
          input = line
      } else {
          input! += "\n" + line
      }
  }

  return input
}
