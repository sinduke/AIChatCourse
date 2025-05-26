//
//  ChatRowCellView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/18/25.
//

import SwiftUI

struct ChatRowCellView: View {
    
    var imageName: String? = Constants.randomImage
    var headline: String? = "Alpha"
    var subheadline: String? = "This is last message in the chat."
    var hasNewChat: Bool = true
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                if let imageName {
                    ImageLoaderView(urlString: imageName)
                } else {
                    Rectangle()
                        .fill(.secondary.opacity(0.5))
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(.circle)
            
            VStack(alignment: .leading, spacing: 4) {
                if let headline {
                    Text(headline)
                        .font(.headline)
                }
                if let subheadline {
                    Text(subheadline)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(1)
            
            if hasNewChat {
                Text("NEW")
                    .badgeButton()
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(.background)
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        List {
            ChatRowCellView()
                .removeListRowFormatting()
            ChatRowCellView(imageName: nil)
                .removeListRowFormatting()
            ChatRowCellView(hasNewChat: false)
                .removeListRowFormatting()
            ChatRowCellView(headline: nil)
                .removeListRowFormatting()
            ChatRowCellView(subheadline: nil)
                .removeListRowFormatting()
        }
    }
}
