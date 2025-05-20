//
//  ImageLoaderView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageLoaderView: View {
    var urlString: String = Constants.randomImage
    var resizingMode: ContentMode = .fill
    var forceTransitionAnimation: Bool = false
    var forceReload: Bool = false
    var body: some View {
        Rectangle()
            .opacity(0.001)
            .overlay {
                WebImage(
                    url: URL(string: urlString)
//                    options: [.refreshCached, .retryFailed, .highPriority]
                )
                .resizable()
                .indicator(.activity)
                .aspectRatio(contentMode: resizingMode)
                .allowsHitTesting(false)
                .ifSatisfiedCondition(forceReload) { content in
                    content
                        .onAppear {
                            // 可选：完全清除缓存后再加载
                            if let url = URL(string: urlString) {
                                let key = SDWebImageManager.shared.cacheKey(for: url)
                                SDImageCache.shared.removeImage(forKey: key, cacheType: .all, completion: nil)
                            }
                        }
                }
            }
            .clipped()
            .ifSatisfiedCondition(forceTransitionAnimation) { content in
                content
                    .drawingGroup()
            }
        ///  让图像在出现之前就进行渲染
        ///  .drawingGroup(opaque: <#T##Bool#>, colorMode: <#T##ColorRenderingMode#>)
    }
}

#Preview {
    ImageLoaderView()
        .frame(width: 100, height: 200)
}
