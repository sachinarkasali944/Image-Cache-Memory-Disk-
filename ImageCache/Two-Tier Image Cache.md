# Two-Tier Image Cache: Memory + Disk

This project demonstrates a basic async image cache for iOS using only Apple frameworks.

## Goal

Build this API:

```swift
func loadImage(url: URL) async throws -> UIImage
```

The lookup order is:

1. Check memory cache with `NSCache`.
2. If memory misses, check the disk cache under `.cachesDirectory`.
3. If disk misses, download from the network.
4. Save a network result to both disk and memory.
5. Coalesce concurrent requests for the same URL so repeated cells do not start repeated downloads.

## Files

- `ImageCache/ImageCache.swift`: actor-based cache implementation.
- `ImageCache/RemoteImage.swift`: reusable SwiftUI view that loads a URL using the cache.
- `ImageCache/ContentView.swift`: sample grid with repeated URLs to demonstrate cache hits and in-flight coalescing.

## Why An Actor?

`ImageCache` is an `actor`, so its mutable state is protected by Swift concurrency:

```swift
private var inflight: [URL: Task<UIImage, Error>] = [:]
```

That dictionary tracks currently running loads. When many views request the same URL at the same time, the first request creates a task and later requests await the same task instead of starting new downloads.

## Memory Tier

The memory tier uses `NSCache<NSURL, UIImage>`:

```swift
memoryCache.countLimit = 100
memoryCache.totalCostLimit = 50 * 1024 * 1024
```

`NSCache` can evict objects under memory pressure. Each image is stored with `data.count` as its cost so large images count more heavily against the limit.

## Disk Tier

Images are stored under:

```swift
.cachesDirectory/TwoTierImageCache
```

The URL string is hashed with SHA-256 to create a safe filename. This avoids slashes, colons, query parameters, and other characters that are awkward in file paths.

## SwiftUI Usage

`RemoteImage` uses `.task(id: url)`, which starts loading when the view appears, restarts when the URL changes, and cancels when SwiftUI removes the view.

```swift
RemoteImage(url: url) {
    Rectangle()
        .fill(.quaternary)
        .overlay { ProgressView() }
}
```

## Interview Follow-Ups

- Disk size cap: store file modification dates and periodically delete least-recently-used files until the folder is below a byte limit.
- Cancellation: the cache stores a shared task, and `URLSession` cooperates with Swift task cancellation.
- Why `.cachesDirectory`: cached images are derived data and the system may purge them when storage is tight.
- Why hash filenames: URLs contain path separators and query strings; hashes produce stable filesystem-safe names.
- Why not `documentDirectory`: documents are user-visible and backed up, which is wrong for disposable cache data.

## Common Mistakes

- Starting a network request for every cell even when URLs repeat.
- Saving only to memory, causing all images to redownload after app restart.
- Using an unstable filename such as `UUID().uuidString` for disk cache keys.
- Leaving `NSCache` without count or cost limits.
