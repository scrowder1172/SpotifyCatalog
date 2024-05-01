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
    
    
    /// Dynamic Scroll Bar Properties
    @State private var tabs: [TabModel] = [
        .init(id: TabModel.Tab.artist),
        .init(id: TabModel.Tab.album),
        .init(id: TabModel.Tab.track),
    ]
    @State private var activeTab: TabModel.Tab = .artist
    @State private var tabBarScrollState: TabModel.Tab?
    @State private var mainViewScrollState: TabModel.Tab?
    @State private var progress: CGFloat = .zero
    
    @ViewBuilder
    func ArtistView() -> some View {
        if let artistData {
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
        } else {
            ContentUnavailableView(label: {
                Label("No Artist Data", systemImage: "person")
            }, description: {
                Text("Search for artists to fill this view")
            }, actions: {
                Button {
                    Task {
                        await getResults()
                    }
                } label: {
                    Text("Search Again")
                }
                .buttonStyle(.borderedProminent)
                .disabled(searchString.isEmpty)
            })
        }
    }
    
    @ViewBuilder
    func AlbumsView() -> some View {
        if let albumData {
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
        } else {
            ContentUnavailableView(label: {
                Label("No Album Data", systemImage: "music.note.list")
            }, description: {
                Text("Search for albums to fill this view")
            }, actions: {
                Button {
                    Task {
                        await getResults()
                    }
                } label: {
                    Text("Search Again")
                }
                .buttonStyle(.borderedProminent)
                .disabled(searchString.isEmpty)
            })
        }
    }
    
    @ViewBuilder
    func TracksView() -> some View {
        if let trackData {
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
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
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
        } else {
            ContentUnavailableView(label: {
                Label("No Track Data", systemImage: "music.quarternote.3")
            }, description: {
                Text("Search for tracks to fill this view")
            }, actions: {
                Button {
                    Task {
                        await getResults()
                    }
                } label: {
                    Text("Search Again")
                }
                .buttonStyle(.borderedProminent)
                .disabled(searchString.isEmpty)
            })
        }
    }
    
    var body: some View {
        ZStack {
            
            LinearGradient(colors: [.blue.opacity(0.2), .green.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(alignment: .leading) {
                HeaderView()
                
                DynamicScrollTabBar()
                
                GeometryReader {
                    let size = $0.size
                    
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 0) {
                            ForEach(tabs) { tab in
                                switch tab.id {
                                case .album:
                                    AlbumsView()
                                        .frame(width: size.width, height: size.height)
                                        .contentShape(.rect)
                                case .artist:
                                    ArtistView()
                                        .frame(width: size.width, height: size.height)
                                        .contentShape(.rect)
                                case .track:
                                    TracksView()
                                        .frame(width: size.width, height: size.height)
                                        .contentShape(.rect)
                                }
                            }
                        }
                        .scrollTargetLayout()
                        .rect { rect in
                            progress = -rect.minX / size.width
                        }
                    }
                    .scrollPosition(id: $mainViewScrollState)
                    .scrollIndicators(.hidden)
                    .scrollTargetBehavior(.paging)
                    .onChange(of: mainViewScrollState) { oldValue, newValue in
                        if let newValue {
                            withAnimation(.snappy) {
                                tabBarScrollState = newValue
                                activeTab = newValue
                            }
                        }
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
    
    @ViewBuilder
    func HeaderView() -> some View {
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
    }
    
    @ViewBuilder
    func DynamicScrollTabBar() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach($tabs) { $tab in
                    Button {
                        withAnimation(.snappy) {
                            activeTab = tab.id
                            tabBarScrollState = tab.id
                            mainViewScrollState = tab.id
                        }
                    } label: {
                        Text(tab.id.rawValue)
                            .font(.title)
                            .fontWeight(.medium)
                            .padding(.vertical, 10)
                            .foregroundStyle(activeTab == tab.id ? Color.primary : .gray)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .rect { rect in
                        tab.size = rect.size
                        tab.minX = rect.minX
                    }
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: .init(get: {
            return tabBarScrollState
        }, set: { _ in
        }), anchor: .center)
        .overlay(alignment: .bottom) {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .frame(height: 1)
                    .padding(.horizontal, -15)
                
                let inputRange = tabs.indices.compactMap { return CGFloat($0) }
                let ouputRange = tabs.compactMap { return $0.size.width }
                let outputPositionRange = tabs.compactMap { return $0.minX }
                let indicatorWidth = progress.interpolate(inputRange: inputRange, outputRange: ouputRange)
                let indicatorPosition = progress.interpolate(inputRange: inputRange, outputRange: outputPositionRange)
                
                Rectangle()
                    .fill(.primary)
                    .frame(width: indicatorWidth, height: 1.5)
                    .offset(x: indicatorPosition)
            }
        }
        .safeAreaPadding(.horizontal, 15)
        .scrollIndicators(.hidden)
    }
}

extension CGFloat {
    func interpolate(inputRange: [CGFloat], outputRange: [CGFloat]) -> CGFloat {
        /// If Value less than it's Initial Input Range
        let x = self
        let length = inputRange.count - 1
        if x <= inputRange[0] { return outputRange[0] }
        
        for index in 1...length {
            let x1 = inputRange[index - 1]
            let x2 = inputRange[index]
            
            let y1 = outputRange[index - 1]
            let y2 = outputRange[index]
            
            /// Linear Interpolation Formula: y1 + ((y2-y1) / (x2-x1)) * (x-x1)
            if x <= inputRange[index] {
                let y = y1 + ((y2-y1) / (x2-x1)) * (x-x1)
                return y
            }
        }
        
        /// If Value Exceeds it's Maximum Input Range
        return outputRange[length]
    }
}


struct TabModel: Identifiable {
    enum Tab: String, CaseIterable {
        case artist = "Artists"
        case album = "Albums"
        case track = "Tracks"
    }
    
    private(set) var id: Tab
    var size: CGSize = .zero
    var minX: CGFloat = .zero
}

struct RectKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

extension View {
    @ViewBuilder
    func rect(completion: @escaping (CGRect) -> ()) -> some View {
        self
            .overlay {
                GeometryReader {
                    let rect = $0.frame(in: .scrollView(axis: .horizontal))
                    
                    Color.clear
                        .preference(key: RectKey.self, value: rect)
                        .onPreferenceChange(RectKey.self, perform: completion)
                }
            }
    }
}

#Preview {
    TabbedView()
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
