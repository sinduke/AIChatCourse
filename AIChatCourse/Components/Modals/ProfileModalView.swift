//
//  ProfileModalView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/20/25.
//

import SwiftUI

struct ProfileModalView: View {
    var imageName: String? = Constants.randomImage
    var title: String? = "Alpha"
    var subtitle: String? = "Alien"
    var headline: String? = "An alien in the park."
    var onXMarkPressed: () -> Void = { }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                VStack {
                    if let imageName {
                        ImageLoaderView(
                            urlString: imageName,
                            forceTransitionAnimation: true
                        )
                        .aspectRatio(1, contentMode: .fit)
                    }
                }
                
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.black)
                    .padding(4)
                    
                    .anyButton {
                        onXMarkPressed()
                    }
                    .padding(8)
                
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let title {
                    Text(title)
                        .font(.title)
                        .fontWeight(.semibold)
                }
                if let subtitle {
                    Text(subtitle)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                if let headline {
                    Text(headline)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        ProfileModalView()
            .padding(40)
    }
}

#Preview("\"\" Image") {
    ZStack {
        Color.gray.ignoresSafeArea()
        ProfileModalView(imageName: "")
            .padding(40)
    }
}

#Preview("nil Image") {
    ZStack {
        Color.gray.ignoresSafeArea()
        ProfileModalView(imageName: nil)
            .padding(40)
    }
}
