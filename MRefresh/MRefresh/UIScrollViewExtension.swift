import Foundation
import UIKit

extension UIScrollView {
    
    struct AssociatedKeys {
        static var pullToRefreshViewKey = "pullToRefreshViewKey"
    }
    
    var pullToRefreshView: AnimatableContainerView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.pullToRefreshViewKey) as? AnimatableContainerView
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self,
                                         &AssociatedKeys.pullToRefreshViewKey,
                                         newValue,
                                         .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    open var showsPullToRefresh: Bool {
        
        get {
            if let view = pullToRefreshView {
                return !view.isHidden
            }
            return false
        }
        set {
            guard let pullToRefreshView = pullToRefreshView else {
                return
            }
            
            if (!newValue && pullToRefreshView.isObserving) {
                removeObserver(pullToRefreshView, forKeyPath: #keyPath(UIScrollView.contentOffset))
                removeObserver(pullToRefreshView, forKeyPath: #keyPath(UIScrollView.frame))
                panGestureRecognizer.removeTarget(pullToRefreshView,
                                                  action: #selector(AnimatableContainerView.gestureRecognizerUpdated(_:)))
                pullToRefreshView.isObserving = false
            } else if (newValue && !pullToRefreshView.isObserving) {
                addObserver(pullToRefreshView,
                            forKeyPath: #keyPath(UIScrollView.contentOffset),
                            options: NSKeyValueObservingOptions.new,
                            context: nil)
                addObserver(pullToRefreshView,
                            forKeyPath: #keyPath(UIScrollView.frame),
                            options: NSKeyValueObservingOptions.new,
                            context: nil)
                panGestureRecognizer.addTarget(pullToRefreshView,
                                               action: #selector(AnimatableContainerView.gestureRecognizerUpdated(_:)))
                pullToRefreshView.isObserving = true
            }
            pullToRefreshView.isHidden = !showsPullToRefresh
        }
    }
    
    open func stopAnimating() {
        if let animating = pullToRefreshView?.isAnimating, animating == true {
            pullToRefreshView?.stopAnimating()
        }
    }
    
    open func addPullToRefresh(animatable: AnimatableViewConforming,
                               configuration: PullToRefreshConfiguration = .default,
                               handler: @escaping ActionHandler) {
        guard pullToRefreshView == nil else {
            return
        }
        
        let height = configuration.loadingContentInset
        
        let pullToRefreshFrame = CGRect(x: 0,
                                        y: -height,
                                        width: bounds.width,
                                        height: height)
        
        let viewConfiguration = AnimatableContainerViewConfiguration(
            frame: pullToRefreshFrame,
            animatable: animatable,
            scrollView: self,
            pullToRefreshViewCenterYOffset: configuration.pullToRefreshViewCenterYOffset,
            animationDistance: configuration.animationDistance,
            animationStart: configuration.animationStart,
            handler: handler,
            contentInsetChangeAnimationDuration: configuration.contentInsetChangeAnimationDuration
        )
        
        let newPullToRefreshView = AnimatableContainerView(frame: pullToRefreshFrame,
                                                           configuration: viewConfiguration)
        addSubview(newPullToRefreshView)
        sendSubviewToBack(newPullToRefreshView)
        
        pullToRefreshView = newPullToRefreshView
        
        showsPullToRefresh = true
    }
} 
