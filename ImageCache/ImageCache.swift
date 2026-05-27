//
//  ImageCache.swift
//  ImageCache
//
//  Created by Sachin Arkasali on 27/05/26.
//

import CryptoKit
import Foundation
import UIKit

actor ImageCache {
    static let shared = ImageCache()

    private let memoryCache = NSCache<NSURL, UIImage>()
    private let diskDirectory: URL
    private let fileManager: FileManager

    /// Coalesces concurrent requests for the same URL into one load operation.
    private var inflight: [URL: Task<UIImage, Error>] = [:]

    init(
        fileManager: FileManager = .default,
        diskDirectory: URL? = nil,
        memoryCountLimit: Int = 100,
        memoryCostLimit: Int = 50 * 1024 * 1024
    ) {
        self.fileManager = fileManager
        self.diskDirectory = diskDirectory ?? fileManager
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("TwoTierImageCache", isDirectory: true)

        memoryCache.countLimit = memoryCountLimit
        memoryCache.totalCostLimit = memoryCostLimit

        try? fileManager.createDirectory(
            at: self.diskDirectory,
            withIntermediateDirectories: true
        )
    }

    func loadImage(url: URL) async throws -> UIImage {
        if let image = memoryCache.object(forKey: url as NSURL) {
            return image
        }

        if let task = inflight[url] {
            return try await task.value
        }

        let task = Task<UIImage, Error> {
            let diskURL = diskURL(for: url)

            if let data = try? Data(contentsOf: diskURL),
               let image = UIImage(data: data) {
                memoryCache.setObject(image, forKey: url as NSURL, cost: data.count)
                return image
            }

            let (data, response) = try await URLSession.shared.data(from: url)
            try validate(response: response)

            guard let image = UIImage(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }

            try? data.write(to: diskURL, options: .atomic)
            memoryCache.setObject(image, forKey: url as NSURL, cost: data.count)
            return image
        }

        inflight[url] = task
        defer { inflight[url] = nil }

        return try await task.value
    }

    func clear() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: diskDirectory)
        try? fileManager.createDirectory(
            at: diskDirectory,
            withIntermediateDirectories: true
        )
    }

    private func diskURL(for url: URL) -> URL {
        diskDirectory.appendingPathComponent(url.absoluteString.sha256FileName)
    }

    private func validate(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            return
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}

private extension String {
    var sha256FileName: String {
        let digest = SHA256.hash(data: Data(utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
