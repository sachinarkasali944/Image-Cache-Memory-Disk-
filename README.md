# Two-Tier Image Cache

> Memory-first image loading with disk fallback and shared in-flight requests.

An actor-based image cache built with Apple frameworks, plus a reusable SwiftUI RemoteImage view. It demonstrates how to avoid repeated downloads while keeping the cache API small.

## Highlights

- NSCache memory tier with configurable limits.
- Disk storage in the caches directory, with SHA-256 filenames.
- Concurrent requests for one URL await the same task.
- SwiftUI loading placeholders, failure state, and URL-driven tasks.

## Open and run

1. Clone this repository and open `ImageCache/ImageCache.xcodeproj` in Xcode.
2. Select the app scheme and a simulator compatible with the deployment target in **Build Settings → iOS Deployment Target**. Use an Xcode version with SDK support for that target.
3. Build and run with **⌘R**. For a physical device, select your development team.

```bash
git clone https://github.com/sachinarkasali944/Image-Cache-Memory-Disk-.git
cd Image-Cache-Memory-Disk-
open "ImageCache/ImageCache.xcodeproj"
```

## Demo scope

Disk files are cached opportunistically; cache expiry and a disk-size eviction policy are not implemented. The sample downloads images from the network.

## Explore the code

- [Xcode project](./ImageCache/ImageCache.xcodeproj)
- [Project files](./ImageCache)

## Further reading

[Read the detailed implementation guide](./ImageCache/Two-Tier%20Image%20Cache.md).
