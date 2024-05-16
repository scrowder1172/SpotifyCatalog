//
//  DisplayDataView.swift
//  SpotifyCatalog
//
//  Created by SCOTT CROWDER on 5/16/24.
//

import SwiftUI

struct DisplayDataView<T: SpotifyData>: View {
    
    let spotifyItem: T
    
    var body: some View {
        Group{
            if let imageUrl = spotifyItem.images?.first?.url {
                VStack(spacing: 0) {
                    AsyncImage(url: URL(string: imageUrl), scale: 1) { phase in
                        if let image = phase.image {
                            SearchResultsImageView(image: image)
                        } else if phase.error != nil {
                            SearchResultsImageView(image: Image(systemName: "antenna.radiowaves.left.and.right.slash"))
                        } else {
                            ProgressView()
                        }
                    }
                    Text(spotifyItem.name)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .containerRelativeFrame(.horizontal, count: 1, spacing: 10)
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1.0 : 0.0)
                        .scaleEffect(x: phase.isIdentity ? 1.0 : 0.3,
                                     y: phase.isIdentity ? 1.0 : 0.3)
                        .offset(y: phase.isIdentity ? 0 : 50)
                }
            } else {
                Text("No image URL provided")
            }
        }
    }
}

#Preview {
    let artist: Artist = .init(id: "1", name: "Random Data")
    return ScrollView(.horizontal, showsIndicators: false){
        DisplayDataView(spotifyItem: artist)
    }
}
