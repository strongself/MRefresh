import Foundation
import UIKit

/// The general idea is that the animatable view should be in the
/// center of the area between the first cell of the scroll view
/// and the top of the screen
///
/// The animatable view is living inside the container which height
/// represents the amount that the user needs to scroll up to
/// start the animation
public struct PullToRefreshConfiguration {
    public static let `default` = PullToRefreshConfiguration(
        pullToRefreshViewCenterYOffset: 0,
        loadingContentInset: 100,
        animationDistance: 100,
        animationStart: 40,
        contentInsetChangeAnimationDuration: 0.25
    )
    
    /// how much we want the view to be offset against the center of the area described above
    let pullToRefreshViewCenterYOffset: CGFloat
    /// the inset of the scroll view when pull to refresh is loading
    let loadingContentInset: CGFloat
    /// the distance the user needs to pull the scroll view
    /// after the animation is started to put the view in loading state
    let animationDistance: CGFloat
    /// the distance the user needs to pull the scroll view
    /// to start the animation
    let animationStart: CGFloat
    /// the duration of the content inset change
    let contentInsetChangeAnimationDuration: Double
    
    public init(pullToRefreshViewCenterYOffset: CGFloat,
                loadingContentInset: CGFloat,
                animationDistance: CGFloat,
                animationStart: CGFloat,
                contentInsetChangeAnimationDuration: Double) {
        self.pullToRefreshViewCenterYOffset = pullToRefreshViewCenterYOffset
        self.loadingContentInset = loadingContentInset
        self.animationDistance = animationDistance
        self.animationStart = animationStart
        self.contentInsetChangeAnimationDuration = contentInsetChangeAnimationDuration
    }
}

