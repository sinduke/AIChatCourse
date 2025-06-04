//
//  RootView.swift
//  AIChatCourse
//
//  Created by sinduke on 6/4/25.
//

import SwiftUI

/// SwiftUI 中的 AppDelegate 生命周期方法说明
///
/// ### onApplicationDidAppear:
/// 当应用首次显示时调用。该回调发生在 didFinishLaunchingWithOptions 之后、SwiftUI 视图渲染完成之后。
/// SwiftUI 环境下没有 didFinishLaunchingWithOptions，因为那一步在界面渲染之前就触发了。
///
/// ### onApplicationWillEnterForeground:
/// 当应用即将进入前台（活跃）状态时调用。它在 applicationDidBecomeActive 之前立即触发。
///
/// ### onApplicationDidBecomeActive:
/// 当应用从非活跃状态重新变为活跃状态时调用。
///
/// ### onApplicationWillResignActive:
/// 当应用即将离开活跃状态时调用。例如来电、控制中心下拉等临时事件发生时都会触发。
///
/// ### onApplicationDidEnterBackground:
/// 当应用进入后台但仍在运行时调用。如果用户终止应用，此方法会在 applicationWillTerminate 之前被调用。
/// 应用大约有 5 秒时间执行收尾任务后便会被系统挂起。
///
/// ### onApplicationWillTerminate:
/// 当应用被终止时调用，例如用户强制退出或设备关机。

public struct RootDelegate {
    
    var onApplicationDidAppear: (() -> Void)? = nil
    var onApplicationWillEnterForeground: ((Notification) -> Void)? = nil
    var onApplicationDidBecomeActive: ((Notification) -> Void)? = nil
    var onApplicationWillResignActive: ((Notification) -> Void)? = nil
    var onApplicationDidEnterBackground: ((Notification) -> Void)? = nil
    var onApplicationWillTerminate: ((Notification) -> Void)? = nil

    public init(
        onApplicationDidAppear: (() -> Void)? = nil,
        onApplicationWillEnterForeground: ((Notification) -> Void)? = nil,
        onApplicationDidBecomeActive: ((Notification) -> Void)? = nil,
        onApplicationWillResignActive: ((Notification) -> Void)? = nil,
        onApplicationDidEnterBackground: ((Notification) -> Void)? = nil,
        onApplicationWillTerminate: ((Notification) -> Void)? = nil
    ) {
        self.onApplicationDidAppear = onApplicationDidAppear
        self.onApplicationWillEnterForeground = onApplicationWillEnterForeground
        self.onApplicationDidBecomeActive = onApplicationDidBecomeActive
        self.onApplicationWillResignActive = onApplicationWillResignActive
        self.onApplicationDidEnterBackground = onApplicationDidEnterBackground
        self.onApplicationWillTerminate = onApplicationWillTerminate
    }
}

/// 将其作为应用程序的根视图，以便在 SwiftUI 视图中接收 UIApplicationDelegate 方法
public struct RootView: View {
    
    let delegate: RootDelegate?
    let content: () -> any View
    
    public init(delegate: RootDelegate? = nil, content: @escaping () -> any View) {
        self.delegate = delegate
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            AnyView(content())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onFirstAppear {
            delegate?.onApplicationDidAppear?()
        }
        .onNotificationReceieved(
            name: UIApplication.willEnterForegroundNotification,
            action: { notification in
                delegate?.onApplicationWillEnterForeground?(notification)
            }
        )
        .onNotificationReceieved(
            name: UIApplication.didBecomeActiveNotification,
            action: { notification in
                delegate?.onApplicationDidBecomeActive?(notification)
            }
        )
        .onNotificationReceieved(
            name: UIApplication.willResignActiveNotification,
            action: { notification in
                delegate?.onApplicationWillResignActive?(notification)
            }
        )
        .onNotificationReceieved(
            name: UIApplication.didEnterBackgroundNotification,
            action: { notification in
                delegate?.onApplicationDidEnterBackground?(notification)
            }
        )
        .onNotificationReceieved(
            name: UIApplication.willTerminateNotification,
            action: { notification in
                delegate?.onApplicationWillTerminate?(notification)
            }
        )
    }
    
}

#Preview("RootView") {
    ZStack {
        RootView(
            delegate: RootDelegate(
                onApplicationDidAppear: {
                    
                },
                onApplicationWillEnterForeground: { notification in
                    
                },
                onApplicationDidBecomeActive: { notification in
                    
                },
                onApplicationWillResignActive: { notification in
                    
                },
                onApplicationDidEnterBackground: { notification in
                    
                },
                onApplicationWillTerminate: { notification in
                    
                }
            ),
            content: {
                Text("Home")
            }
        )
        
        let delegate = RootDelegate(
            onApplicationDidAppear: nil,
            onApplicationWillEnterForeground: nil,
            onApplicationDidBecomeActive: nil,
            onApplicationWillResignActive: nil,
            onApplicationDidEnterBackground: nil,
            onApplicationWillTerminate: nil)
        
        RootView(
            delegate: delegate,
            content: {
                Text("Home")
            }
        )
    }
}
