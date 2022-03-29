import Foundation
import ArgumentParser
import SwiftSoup

struct DocsPostProcessor: ParsableCommand {
    enum Err: Error {
        case noOverviewFound
    }

    @Flag(help: "Replaces overview in the left navigation with rendered README")
    var replaceOverviewWithReadme = false

    @Argument(help: "The file, or directory with the HTML to change")
    var path: String

    mutating func run() throws {
        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(path)
        var files: [URL] = (url.pathExtension == "html") ? [url] : []
        if url.pathExtension != "html", let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]) {
            for case let fileURL as URL in enumerator {
                let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                if fileAttributes.isRegularFile == true, fileURL.pathExtension == "html" {
                    files.append(fileURL)
                }
            }
        }
        for file in files {
            let html = try String(contentsOf: file, encoding: .utf8)
            let doc: Document = try SwiftSoup.parse(html)
            if replaceOverviewWithReadme {
                try replaceOverviewWithReadme(document: doc)
                print("Replaced overview with README for: \(file.absoluteString)")
            }
            try doc.html().write(to: file, atomically: true, encoding: .utf8)
        }
    }

    func replaceOverviewWithReadme(document: Document) throws {
        if let nav = try? document.select("nav").first() {
            if let firstNavLink = try nav.getElementsByClass("nav-group-name-link").first(),
               let oldUrl = URL(string: try firstNavLink.attr("href")),
               oldUrl.lastPathComponent == "Overview.html" {
                try firstNavLink.attr("href", oldUrl.deletingLastPathComponent().appendingPathComponent("index.html").absoluteString)
            } else {
                throw Err.noOverviewFound
            }
        }
    }
}
