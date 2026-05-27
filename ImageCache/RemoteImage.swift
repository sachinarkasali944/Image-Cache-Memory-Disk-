//
//  RemoteImage.swift
//  ImageCache
//
//  Created by Sachin Arkasali on 27/05/26.
//

import SwiftUI
import UIKit

struct RemoteImage<Placeholder: View>: View {
    let url: URL
    let contentMode: ContentMode
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var image: UIImage?
    @State private var didFail = false

    init(
        url: URL,
        contentMode: ContentMode = .fill,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = placeholder
    }

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholder()

                if didFail {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .clipped()
        .task(id: url) {
            image = nil
            didFail = false

            do {
                image = try await ImageCache.shared.loadImage(url: url)
            } catch is CancellationError {
                image = nil
            } catch {
                didFail = true
            }
        }
    }
}

extension RemoteImage where Placeholder == Color {
    init(url: URL, contentMode: ContentMode = .fill) {
        self.init(url: url, contentMode: contentMode) {
            Color.gray.opacity(0.15)
        }
    }
}
