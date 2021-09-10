import Foundation
import ArgumentParser
import SwiftSoup

struct DocsPostProcessor: ParsableCommand {
    enum Err: Error {
        case noOverviewFound
    }

    @Flag(help: "Replaces overview in the left navigation with rendered README")
    var replaceOverviewWithReadme = false

    @Flag(help: "Replaces readme video link with an embedded vimeo player")
    var replaceReadmeVideoWithVimeoEmbed = false

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
            if replaceReadmeVideoWithVimeoEmbed, file.lastPathComponent == "index.html" {
                try replaceReadmeVideoWithVimeoEmbed(document: doc)
                print("Replaced readme video with vimeo embed")
            }
            try doc.html().write(to: file, atomically: true, encoding: .utf8)
        }
    }

    func replaceOverviewWithReadme(document: Document) throws {
        if let nav = try? document.select("nav").first() {
            if let firstNavLink = try nav.getElementsByClass("nav-group-name-link").first(),
               URL(fileURLWithPath: try firstNavLink.attr("href")).lastPathComponent == "Overview.html" {
                try firstNavLink.attr("href", "index.html")
            } else {
                throw Err.noOverviewFound
            }
        }
    }

    func replaceReadmeVideoWithVimeoEmbed(document: Document) throws {
        if let article = try? document.select("article").first() {
            let link = try article.getElementsByAttributeValue("href", "https://user-images.githubusercontent.com/33705774/132767762-7447753c-feba-4ef4-b54c-38bfe9d1ee82.mp4")
            try link.wrap("""
            <iframe src="https://player.vimeo.com/video/600610695?h=fd3976b77a" width="640" height="360" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen></iframe>
            """)
        }
    }
}
