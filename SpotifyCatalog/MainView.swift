//
//  ContentView.swift
//  SpotifyCatalog
//
//  Created by SCOTT CROWDER on 4/30/24.
//

import SwiftUI

struct MainView: View {
    
    @State private var searchString: String = ""
    @State private var showSearchSettings: Bool = false
    @State private var selectedMarket: String = "US"
    @State private var isSearchRunning: Bool = false
    
    @State private var artistData: [Artist]?
    @State private var albumData: [Album]?
    @State private var trackData: [Track]?
    
    @State private var searchTypes: [AudioType] = [
        .init(name: "Album", isChecked: false),
        .init(name: "Artist", isChecked: true),
        .init(name: "Track", isChecked: false),
    ]
    
    @FocusState private var searchFieldFocus: Bool
    
    var body: some View {
        ZStack {
            
            LinearGradient(colors: [.blue.opacity(0.2), .green.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(alignment: .leading) {
                HStack {
                    TextField("Search", text: $searchString)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                        .focused($searchFieldFocus)
                        .overlay(alignment: .trailing) {
                            if searchFieldFocus {
                                Button {
                                    searchString = ""
                                    searchFieldFocus = false
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.gray)
                                }
                                .offset(x: -5)
                            }
                        }
                    Button {
                        Task {
                            await getResults()
                        }
                    } label: {
                        Image(systemName: "chevron.right.square")
                            .font(.system(size: 35))
                            .foregroundStyle(searchString.isEmpty ? .gray.opacity(0.3) : .black.opacity(0.4))
                    }
                    .disabled(searchString.isEmpty)
                    
                    Button {
                        showSearchSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                            .font(.system(size: 30))
                            .foregroundStyle(.black.opacity(0.4))
                    }
                }
                .padding(.vertical, 40)
                
                Spacer()
                
                ScrollView{
                    if let artistData {
                        Text("Artists")
                            .font(.largeTitle)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(artistData) { item in
                                    if let imageUrl = item.images?.first?.url {
                                        VStack(spacing: 0) {
                                            AsyncImage(url: URL(string: imageUrl), scale: 1) { phase in
                                                if let image = phase.image {
                                                    image
                                                        .resizable()
                                                        .frame(width: 300, height: 200)
                                                        .scaledToFit()
                                                } else if phase.error != nil {
                                                    Image(systemName: "antenna.radiowaves.left.and.right.slash")
                                                        .resizable()
                                                        .frame(width: 200, height: 200)
                                                        .scaledToFit()
                                                } else {
                                                    ProgressView()
                                                }
                                            }
                                            Text(item.name)
                                                .font(.footnote)
                                                .foregroundStyle(.secondary)
                                        }
                                        .visualEffect { content, proxy in
                                            content
                                                .rotation3DEffect(.degrees(-proxy.frame(in: .global).minX) / 8, axis: (x: 0, y: 1, z: 0))
                                        }
                                    }
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.viewAligned)
                    }
                    
                    if let albumData {
                        Text("Albums")
                            .font(.largeTitle)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(albumData) { item in
                                    if let imageUrl = item.images?.first?.url {
                                        VStack(spacing: 0) {
                                            AsyncImage(url: URL(string: imageUrl), scale: 1) { phase in
                                                if let image = phase.image {
                                                    image
                                                        .resizable()
                                                        .frame(width: 300, height: 200)
                                                        .scaledToFit()
                                                } else if phase.error != nil {
                                                    Image(systemName: "antenna.radiowaves.left.and.right.slash")
                                                        .resizable()
                                                        .frame(width: 200, height: 200)
                                                        .scaledToFit()
                                                } else {
                                                    ProgressView()
                                                }
                                            }
                                            Text(item.name)
                                                .font(.footnote)
                                                .foregroundStyle(.secondary)
                                        }
                                        .visualEffect { content, proxy in
                                            content
                                                .rotation3DEffect(.degrees(-proxy.frame(in: .global).minX) / 8, axis: (x: 0, y: 1, z: 0))
                                        }
                                    }
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.viewAligned)
                    }
                    
                    if let trackData {
                        Text("Tracks")
                            .font(.largeTitle)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(trackData) { item in
                                    if let imageUrl = item.album?.images?.first?.url {
                                        VStack(spacing: 0) {
                                            AsyncImage(url: URL(string: imageUrl), scale: 1) { phase in
                                                if let image = phase.image {
                                                    image
                                                        .resizable()
                                                        .frame(width: 300, height: 200)
                                                        .scaledToFit()
                                                } else if phase.error != nil {
                                                    Image(systemName: "antenna.radiowaves.left.and.right.slash")
                                                        .resizable()
                                                        .frame(width: 200, height: 200)
                                                        .scaledToFit()
                                                } else {
                                                    ProgressView()
                                                }
                                            }
                                            Text(item.name)
                                                .font(.footnote)
                                                .foregroundStyle(.secondary)
                                        }
                                        .visualEffect { content, proxy in
                                            content
                                                .rotation3DEffect(.degrees(-proxy.frame(in: .global).minX) / 8, axis: (x: 0, y: 1, z: 0))
                                        }
                                    }
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.viewAligned)
                    }
                    
                }
            }
            .sheet(isPresented: $showSearchSettings) {
                SearchSettingsView(selectedMarket: $selectedMarket, searchTypes: $searchTypes)
                    .interactiveDismissDisabled()
                    .presentationDetents([.height(300)])
            }
            .padding()
            .overlay {
                if isSearchRunning {
                    ProgressView("Searching...")
                        .padding(40)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .tint(.white)
                        .clipShape(.rect(cornerRadius: 25))
                }
            }
        }
    }
    
    func getResults() async {
        isSearchRunning = true
        let urlString: String = "http://192.168.0.32:5000/api/spotify/search"
        guard let url = URL(string: urlString) else {
            isSearchRunning = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let spotifySearchBody = SpotifySearchBody(query: searchString, market: selectedMarket, type: searchTypes.filter { $0.isChecked }.map { $0.spotifyType })
        
        do {
            request.httpBody = try JSONEncoder().encode(spotifySearchBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let response = response as? HTTPURLResponse else {
                isSearchRunning = false
                return
            }
            
            guard response.statusCode == 200 else {
                print("Status code: \(response.statusCode)")
                isSearchRunning = false
                return
            }
            
            let decodedData = try JSONDecoder().decode(MessageResponse.self, from: data)
            artistData = decodedData.data.artists?.items
            albumData = decodedData.data.albums?.items
            trackData = decodedData.data.tracks?.items
            
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        
        isSearchRunning = false
    }
    
    func decodeUnknownData(data: Data, encoding: String.Encoding = .utf8) {
        if let string: String = String(data: data, encoding: encoding) {
            print("JSON String: \(string)")
        }
    }
}

#Preview {
    MainView()
}
