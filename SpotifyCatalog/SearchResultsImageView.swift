//
//  SearchResultsImageView.swift
//  SpotifyCatalog
//
//  Created by SCOTT CROWDER on 5/16/24.
//

import SwiftUI

struct SearchResultsImageView: View {
    
    let image: Image
    
    var body: some View {
        image
            .resizable()
            .frame(width: 300, height: 200)
            .scaledToFit()
    }
}


#Preview {
    SearchResultsImageView(image: Image(systemName: "antenna.radiowaves.left.and.right.slash"))
}
