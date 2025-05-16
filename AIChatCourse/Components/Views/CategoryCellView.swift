//
//  CategoryCellView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/16/25.
//

import SwiftUI

struct CategoryCellView: View {
    var title: String = "Man"
    var imageName: String = Constants.randomImage
    var font: Font = .title2
    var cornerRadius: CGFloat = 16
    
    var body: some View {
        ImageLoaderView(urlString: imageName)
            .aspectRatio(1, contentMode: .fit)
            .overlay(alignment: .bottomLeading, content: {
                Text(title)
                    .font(font)
                    .fontWeight(.semibold)
                    .padding(16)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .addingGradientbackgroundForText()
            })
            .cornerRadius(cornerRadius)
    }
}

#Preview {
    VStack(alignment: .leading) {
        CategoryCellView()
            .frame(width: 150)
        
        CategoryCellView()
            .frame(width: 300)
    }
}
