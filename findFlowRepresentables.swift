/*
    usage:
        xcrun --sdk macosx swiftc -parse-as-library findFlowRepresentables.swift -o FindFlowRepresentables 
        sourcekitten structure --file FR1.swift | ./FindFlowRepresentables
*/
            // swiftlint:disable line_length
import Foundation

@main
struct FindFlowRepresentables {
    static func main() throws {
        // guard let json = readSTDIN()?.data(using: .utf8) else { print("Error: Invalid JSON passed"); return }

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
        // print(structureArray[0])

        for structure in structureArray {
            guard let json = structure.data(using: .utf8) else { print("Error: Invalid JSON from SourceKitten"); return }
            // guard let file = try? JSONDecoder().decode(File.self, from: json) else { print("Error: Could not parse JSON"); return }
            guard let file = try JSONSerialization.jsonObject(with: json, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] else { print("Error: Could not parse JSON"); return }

            let substructure = file!["key.substructure"] as? [[String: Any]]
            let typesDict = substructure!.first { $0.keys.contains("key.substructure") } as? [String: Any]
            let inheritedtypes = typesDict!["key.inheritedtypes"] as? [[String: Any]]
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
    let keySubstructure: [FileKeySubstructure]

    enum CodingKeys: String, CodingKey {
        case keyDiagnosticStage = "key.diagnostic_stage"
        case keyLength = "key.length"
        case keyOffset = "key.offset"
        case keySubstructure = "key.substructure"
    }
}

// MARK: - FileKeySubstructure
struct FileKeySubstructure: Codable {
    let keyAccessibility: String?
    let keyAttributes: [KeyAttribute]?
    let keyBodylength, keyBodyoffset: Int
    let keyElements: [KeyElement]?
    let keyInheritedtypes: [KeyInheritedtype]?
    let keyKind: String
    let keyLength: Int
    let keyName: String
    let keyNamelength, keyNameoffset, keyOffset: Int
    let keySubstructure: [PurpleKeySubstructure]

    enum CodingKeys: String, CodingKey {
        case keyAccessibility = "key.accessibility"
        case keyAttributes = "key.attributes"
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
    }
}

// MARK: - KeyAttribute
struct KeyAttribute: Codable {
    let keyAttribute: String
    let keyLength, keyOffset: Int

    enum CodingKeys: String, CodingKey {
        case keyAttribute = "key.attribute"
        case keyLength = "key.length"
        case keyOffset = "key.offset"
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

// MARK: - PurpleKeySubstructure
struct PurpleKeySubstructure: Codable {
    let keyAccessibility: String?
    let keyAttributes: [KeyAttribute]?
    let keyKind: PurpleKeyKind
    let keyLength: Int
    let keyName: String
    let keyNamelength, keyNameoffset, keyOffset: Int
    let keySetterAccessibility, keyTypename: String?
    let keyBodylength, keyBodyoffset: Int?
    let keySubstructure: [FluffyKeySubstructure]?

    enum CodingKeys: String, CodingKey {
        case keyAccessibility = "key.accessibility"
        case keyAttributes = "key.attributes"
        case keyKind = "key.kind"
        case keyLength = "key.length"
        case keyName = "key.name"
        case keyNamelength = "key.namelength"
        case keyNameoffset = "key.nameoffset"
        case keyOffset = "key.offset"
        case keySetterAccessibility = "key.setter_accessibility"
        case keyTypename = "key.typename"
        case keyBodylength = "key.bodylength"
        case keyBodyoffset = "key.bodyoffset"
        case keySubstructure = "key.substructure"
    }
}

enum PurpleKeyKind: String, Codable {
    case sourceLangSwiftDeclFunctionMethodInstance = "source.lang.swift.decl.function.method.instance"
    case sourceLangSwiftDeclVarInstance = "source.lang.swift.decl.var.instance"
    case sourceLangSwiftExprCall = "source.lang.swift.expr.call"
}

// MARK: - FluffyKeySubstructure
struct FluffyKeySubstructure: Codable {
    let keyKind: FluffyKeyKind
    let keyLength: Int
    let keyName: String?
    let keyNamelength, keyNameoffset, keyOffset: Int
    let keyTypename: String?
    let keyBodylength, keyBodyoffset: Int?
    let keyElements: [KeyElement]?
    let keySubstructure: [TentacledKeySubstructure]?

    enum CodingKeys: String, CodingKey {
        case keyKind = "key.kind"
        case keyLength = "key.length"
        case keyName = "key.name"
        case keyNamelength = "key.namelength"
        case keyNameoffset = "key.nameoffset"
        case keyOffset = "key.offset"
        case keyTypename = "key.typename"
        case keyBodylength = "key.bodylength"
        case keyBodyoffset = "key.bodyoffset"
        case keyElements = "key.elements"
        case keySubstructure = "key.substructure"
    }
}

enum FluffyKeyKind: String, Codable {
    case sourceLangSwiftDeclVarParameter = "source.lang.swift.decl.var.parameter"
    case sourceLangSwiftExprCall = "source.lang.swift.expr.call"
    case sourceLangSwiftExprClosure = "source.lang.swift.expr.closure"
    case sourceLangSwiftStmtIf = "source.lang.swift.stmt.if"
}

// MARK: - TentacledKeySubstructure
struct TentacledKeySubstructure: Codable {
    let keyBodylength, keyBodyoffset: Int
    let keyKind: String
    let keyLength, keyNamelength, keyNameoffset, keyOffset: Int
    let keySubstructure: [StickyKeySubstructure]?

    enum CodingKeys: String, CodingKey {
        case keyBodylength = "key.bodylength"
        case keyBodyoffset = "key.bodyoffset"
        case keyKind = "key.kind"
        case keyLength = "key.length"
        case keyNamelength = "key.namelength"
        case keyNameoffset = "key.nameoffset"
        case keyOffset = "key.offset"
        case keySubstructure = "key.substructure"
    }
}

// MARK: - StickyKeySubstructure
struct StickyKeySubstructure: Codable {
    let keyBodylength, keyBodyoffset: Int?
    let keyKind: String
    let keyLength: Int
    let keyName: String?
    let keyNamelength, keyNameoffset, keyOffset: Int
    let keySubstructure: [StickyKeySubstructure]?
    let keyElements: [KeyElement]?

    enum CodingKeys: String, CodingKey {
        case keyBodylength = "key.bodylength"
        case keyBodyoffset = "key.bodyoffset"
        case keyKind = "key.kind"
        case keyLength = "key.length"
        case keyName = "key.name"
        case keyNamelength = "key.namelength"
        case keyNameoffset = "key.nameoffset"
        case keyOffset = "key.offset"
        case keySubstructure = "key.substructure"
        case keyElements = "key.elements"
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
