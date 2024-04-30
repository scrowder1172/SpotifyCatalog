//
//  ContentView.swift
//  SpotifyCatalog
//
//  Created by SCOTT CROWDER on 4/30/24.
//

import SwiftUI

struct MainView: View {
    
    @State private var searchString: String = "Summer"
    @State private var showSearchSettings: Bool = false
    @State private var selectedMarket: String = "US"
    @State private var isSearchRunning: Bool = false
    
    @State private var artistData: [Artist]?
    @State private var albumData: [Album]?
    @State private var trackData: [Track]?
    
    @State private var knownTypes: [AudioType] = [
        .init(name: "Album", isChecked: false),
        .init(name: "Artist", isChecked: false),
        .init(name: "Track", isChecked: true),
    ]
    
    let adaptiveLayout = [
        GridItem(.adaptive(minimum: 80, maximum: 120))
    ]
    
    var body: some View {
        ZStack{
            LinearGradient(
                stops: [Gradient.Stop(color: .pink.opacity(0.6), location: 0.6),
                        Gradient.Stop(color: .indigo.opacity(0.7), location: 1)],
                startPoint: .top,
                endPoint: .bottom
            )
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                HStack {
                    TextField("Search", text: $searchString)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
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
                
                if showSearchSettings {
                    VStack(alignment: .leading){
                        HStack{
                            Text("Market")
                            Picker("Market", selection: $selectedMarket) {
                                ForEach(Market.knownMarkets) { market in
                                    Text(market.country)
                                        .tag(market.id)
                                }
                            }
                            .tint(.black)
                        }
                        LazyVGrid(columns: adaptiveLayout) {
                            ForEach($knownTypes) { $audioType in
                                HStack{
                                    Image(systemName: audioType.isChecked ? "checkmark.square" : "square")
                                    Text(audioType.name)
                                }
                                .font(.caption)
                                .onTapGesture {
                                    audioType.isChecked.toggle()
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.gray.opacity(0.3))
                }
                
                
                Text("Results")
                    .font(.title)
                    .fontWeight(.heavy)
                List {
                    Text("Hello World")
                        .listRowBackground(Color.clear)
                    
                    if let artistData {
                        Section("Artists"){
                            ForEach(artistData) { artist in
                                Text(artist.name ?? "NA")
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                    
                    if let albumData {
                        Section("Albums") {
                            ForEach(albumData) { album in
                                Text(album.name)
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                    
                    if let trackData {
                        Section("Tracks") {
                            ForEach(trackData) { track in
                                Text(track.name ?? "NA")
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
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
        
        let spotifySearchBody = SpotifySearchBody(query: searchString, market: selectedMarket, type: knownTypes.filter { $0.isChecked }.map { $0.spotifyType })
        
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
