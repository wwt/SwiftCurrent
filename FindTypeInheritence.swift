/*
    usage:
        xcrun --sdk macosx swiftc -parse-as-library findFlowRepresentables.swift -o FindTypeInheritence 
        ./FindTypeInheritence [directory] [inheritedType]
*/
// swiftlint:disable line_length
import Foundation

@main
struct FindTypeInheritence {
    static let SUBSTRUCTURE_KEY = "key.substructure"
    static let NAME_KEY = "key.name"
    static let INHERITEDTYPES_KEY = "key.inheritedtypes"

    static func main() throws {
        let directoryPath = CommandLine.arguments[1]
        let seekingInheritedType = CommandLine.arguments[2]
        var frFiles: [String] = []
        let filepaths = getSwiftFiles(from: directoryPath)
        var astJsonArray: [String] = []

        for path in filepaths {
            do {
                astJsonArray.append(try shell("sourcekitten structure --file \(path)"))
            } catch { print("\(error)") }
        }

        var counter = 0
        for structure in astJsonArray {
            guard let json = structure.data(using: .utf8) else { print("Error: Invalid JSON from SourceKitten"); continue }
            guard let file = try JSONSerialization.jsonObject(with: json, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] else { print("Error: Could not serialize JSON"); continue }

            if let substructure = file[FindTypeInheritence.SUBSTRUCTURE_KEY] as? [[String: Any]],
                let typeName = substructure.first?[FindTypeInheritence.NAME_KEY] as? String,
                let inheritedTypes = substructure.first?[FindTypeInheritence.INHERITEDTYPES_KEY] as? [[String: String]],
                inheritedTypes.compactMap({ $0[FindTypeInheritence.NAME_KEY] }).contains(seekingInheritedType) {

                print("Appending \(typeName)")
                frFiles.append(typeName)
                counter += 1
            } else {
                astJsonArray.remove(at: counter)
            }
        }

        frFiles.forEach { print($0) }

        print("astJsonArray count: \(astJsonArray.count)")
        print("frFiles count: \(frFiles.count)")
    }
}

func shell(_ command: String) throws -> String {
    let process = Process()
    let pipe = Pipe()

    process.standardOutput = pipe
    process.standardError = pipe
    process.arguments = ["-c", command]
    process.executableURL = URL(fileURLWithPath: "/bin/zsh")

    do {
        try process.run()
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
        // FileManager().currentDirectoryPath
        return files.map {
            var str = $0.absoluteString
            str = String(str.suffix(from: str.range(of: directory)!.lowerBound))
            // print(str)
            return str
        }
    }
    return []
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
