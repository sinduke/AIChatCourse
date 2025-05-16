//
//  HeroCellView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct HeroCellView: View {
    var title: String? = "This some Title"
    var subTitle: String? = "This some subTitle"
    var imageName: String? = Constants.randomImage
    var body: some View {
        ZStack {
            if let imageName {
                ImageLoaderView(urlString: imageName)
            } else {
                Rectangle()
                    .fill(.accent.gradient)
            }
        }
        .overlay(
            alignment: .bottomLeading,
            content: {
                VStack(alignment: .leading, spacing: 4) {
                    if let title {
                        Text(title)
                            .font(.headline)
                    }
                    if let subTitle {
                        Text(subTitle)
                            .font(.subheadline)
                            .lineLimit(2)
                    }
                }
                .foregroundStyle(.white)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .addingGradientbackgroundForText()
        })
        .cornerRadius(16)
    }
}

#Preview {
    ScrollView {
        VStack {
            HeroCellView()
                .frame(width: 350, height: 200)
            HeroCellView(imageName: nil)
                .frame(width: 350, height: 200)
            HeroCellView()
                .frame(width: 350, height: 400)
            HeroCellView(title: nil)
                .frame(width: 350, height: 200)
            HeroCellView(subTitle: nil)
                .frame(width: 350, height: 200)
        }
        .frame(maxWidth: .infinity)
    }
    
}
