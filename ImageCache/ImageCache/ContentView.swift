//
//  ContentView.swift
//  ImageCache
//
//  Created by Sachin Arkasali on 27/05/26.
//

import SwiftUI

struct ContentView: View {
    private let imageURLs = [
        "https://picsum.photos/id/10/600/400",
        "https://picsum.photos/id/20/600/400",
        "https://picsum.photos/id/30/600/400",
        "https://picsum.photos/id/10/600/400",
        "https://picsum.photos/id/40/600/400",
        "https://picsum.photos/id/20/600/400"
    ].compactMap(URL.init(string:))

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(imageURLs.enumerated()), id: \.offset) { index, url in
                        VStack(alignment: .leading, spacing: 8) {
                            RemoteImage(url: url) {
                                Rectangle()
                                    .fill(.quaternary)
                                    .overlay {
                                        ProgressView()
                                    }
                            }
                            .frame(height: 130)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                            Text("Image \(index + 1)")
                                .font(.headline)

                            Text(url.absoluteString)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        .padding(10)
                        .background(.background)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
                    }
                }
                .padding()
            }
            .navigationTitle("Two-Tier Cache")
            .toolbar {
                Button("Clear") {
                    Task {
                        await ImageCache.shared.clear()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
