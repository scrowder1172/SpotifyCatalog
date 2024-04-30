//
//  TabbedView.swift
//  SpotifyCatalog
//
//  Created by SCOTT CROWDER on 4/30/24.
//

import SwiftUI

struct TabbedView: View {
    
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
    
    @State private var rotationAngle: Double = 0
    @State private var showDetails: Bool = false
    @State private var isTrackFlipped: Bool = false
    
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
                                    VStack(spacing: 0) {
                                        if let imageUrl = item.album?.images?.first?.url {
                                            AsyncImage(url: URL(string: imageUrl), scale: 1) { phase in
                                                if let image = phase.image {
                                                    
                                                    FlipView(
                                                        front: {image
                                                            .resizable()
                                                            .frame(width: 300, height: 200)
                                                            .scaledToFit()
                                                            .accessibilityAddTraits(.isButton)
                                                            .rotation3DEffect(
                                                                Angle(degrees: rotationAngle), axis: (x: 0, y: 1, z: 0)
                                                            )
                                                            .onTapGesture {
                                                                withAnimation(.easeInOut(duration: 0.5)) {
                                                                    rotationAngle += 360
                                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                                        withAnimation(.easeInOut) {
                                                                            showDetails.toggle()
                                                                        }
                                                                    }
                                                                }
                                                            }},
                                                        back: { Color.clear },
                                                        isFlipped: $isTrackFlipped
                                                    )
                                                    .opacity(showDetails && !isTrackFlipped ? 0.5 : 1)
                                                    .onTapGesture {
                                                        toggleFlip(flipState: &isTrackFlipped)
                                                    }
                                                    
                                                } else if phase.error != nil {
                                                    Image(systemName: "antenna.radiowaves.left.and.right.slash")
                                                        .resizable()
                                                        .frame(width: 300, height: 200)
                                                        .scaledToFit()
                                                } else {
                                                    ProgressView()
                                                }
                                            }
                                        } else {
                                            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                                                .resizable()
                                                .frame(width: 300, height: 200)
                                                .scaledToFit()
                                        }
                                        Text(item.name)
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                            .truncationMode(.tail)
                                            .frame(maxWidth: 200)
                                    }
                                    .visualEffect { content, proxy in
                                        content
                                            .rotation3DEffect(.degrees(-proxy.frame(in: .global).minX) / 8, axis: (x: 0, y: 1, z: 0))
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
            
            if showDetails {
                ContentUnavailableView {
                    Label("Details about the artist, ablum, or track", systemImage: "music.note.house.fill")
                }
                ContentUnavailableView(label: {
                    Label("DETAILS", systemImage: "music.note.house.fill")
                }, description: {
                    Text("Details about the selected item will appear here")
                }, actions: {
                    Button {
                        showDetails.toggle()
                    } label: {
                        Text("Close")
                    }
                    .buttonStyle(.borderedProminent)
                })
                .frame(maxWidth: .infinity, maxHeight: 400)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 10)
//                .transition(.move(edge: .bottom))
            }
        }
    }
    
    func toggleFlip(flipState: inout Bool) {
        withAnimation(.easeInOut(duration: 1)) {
            flipState.toggle()
        }
        withAnimation {
            showDetails = true
        }
    }
    
    func getResults() async {
        isSearchRunning = true
        let urlString: String = "https://crowdercode.com/api/spotify/search"
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
            trackData = decodedData.data.tracks?.items.sorted { $0.album?.name ?? "" < $1.album?.name ?? ""}
            
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

struct FlipView<Front: View, Back: View>: View {
    var front: () -> Front
    var back: () -> Back
    
    @Binding var isFlipped: Bool
    
    var body: some View {
        ZStack {
            front()
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(isFlipped ? 360 : 0), axis: (x: 0, y: 1, z: 0))
            
            back()
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(isFlipped ? 0: 360), axis: (x: 0, y: 1, z: 0))
        }
    }
}
