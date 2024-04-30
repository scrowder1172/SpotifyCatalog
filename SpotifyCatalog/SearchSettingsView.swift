//
//  SearchSettingsView.swift
//  SpotifyCatalog
//
//  Created by SCOTT CROWDER on 4/30/24.
//

import SwiftUI

struct SearchSettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedMarket: String
    @Binding var searchTypes: [AudioType]
    
    let adaptiveLayout = [
        GridItem(.adaptive(minimum: 80, maximum: 120))
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Market") {
                    Picker("Market", selection: $selectedMarket) {
                        ForEach(Market.knownMarkets) { market in
                            Text(market.country)
                                .tag(market.id)
                        }
                    }
                }
                
                Section("Search For") {
                    LazyVGrid(columns: adaptiveLayout) {
                        ForEach($searchTypes) { $audioType in
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
                
                
            }
            .navigationTitle("Search Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SearchSettingsView(selectedMarket: .constant("US"), searchTypes: .constant([]))
}
