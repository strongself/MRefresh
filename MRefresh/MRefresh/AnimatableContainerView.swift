import Foundation
import UIKit

enum RefreshState {
    case stopped
    case triggered
    case loading
}

struct AnimatableContainerViewConfiguration {
    let frame: CGRect
    let animatable: AnimatableViewConforming
    let scrollView: UIScrollView
    let pullToRefreshViewCenterYOffset: CGFloat
    let animationDistance: CGFloat
    let animationStart: CGFloat
    let handler: ActionHandler
    let contentInsetChangeAnimationDuration: Double
}

/// A container view which handles all the logic with respect to positioning the animatable view
/// It manages its own frame inside the scroll view and also the frame of the animatable subview
class AnimatableContainerView: UIView {

    fileprivate struct Constants {
        static let startingThreshold: CGFloat = 20.0
    }

    fileprivate let scrollView: UIScrollView
    fileprivate let customView: UIView
    fileprivate let animatable: AnimatableView
    fileprivate let handler: ActionHandler
    fileprivate let animationDistance: CGFloat
    fileprivate let animationStart: CGFloat
    fileprivate let contentInsetChangeAnimationDuration: Double
    fileprivate let pullToRefreshViewCenterYOffset: CGFloat
    fileprivate var privateState: RefreshState = .triggered
    
    var originalTopInset: CGFloat
    
    var isAnimating = false
    var isObserving = false
    
    var stoppedDragging: Bool {
        return !scrollView.isDragging || scrollView.isDecelerating
    }
    
    var enteredPullToRefreshZone: Bool {
        return scrollView.contentOffset.y + scrollView.contentInset.top <= Constants.startingThreshold
    }
    
    var state: RefreshState {
        get {
            return privateState
        }
        
        set {
            if privateState == newValue {
                return
            }
            privateState = newValue
            
            switch newValue {
            case .triggered:
                break
            case .stopped:
                if self.stoppedDragging {
                    self.resetScrollViewContentInset()
                }
            case .loading:
                handler()
                if !self.isAnimating {
                    self.willStartAnimation()
                }
            }
        }
    }
    
    init(frame: CGRect, configuration: AnimatableContainerViewConfiguration) {
        pullToRefreshViewCenterYOffset = configuration.pullToRefreshViewCenterYOffset
        scrollView = configuration.scrollView
        customView = configuration.animatable.getView
        animatable = configuration.animatable
        handler = configuration.handler
        animationDistance = configuration.animationDistance
        animationStart = configuration.animationStart
        originalTopInset = scrollView.contentInset.top
        contentInsetChangeAnimationDuration = configuration.contentInsetChangeAnimationDuration
        
        super.init(frame: frame)
        addSubview(customView)
        autoresizingMask = .flexibleWidth
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // calculating the new frame of a custom view
        let viewBounds = customView.bounds
        let customViewWidth = viewBounds.width
        let customViewHeight = viewBounds.height
        let originX = (bounds.width - customViewWidth) / 2.0
        let originY = (bounds.height - customViewHeight - pullToRefreshViewCenterYOffset) / 2.0
        
        let customViewFrame = CGRect(x: originX,
                                     y: originY,
                                     width: customViewWidth,
                                     height: customViewHeight)
        customView.frame = customViewFrame
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        guard let scrollView = superview as? UIScrollView, newSuperview == nil else {
            return
        }
        
        if scrollView.showsPullToRefresh && isObserving {
            scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
            scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.frame))
            scrollView.panGestureRecognizer.removeTarget(self, action: #selector(AnimatableContainerView.gestureRecognizerUpdated(_:)))
        }
        
        isObserving = false
    }
    
    func updatePullToRefreshFramePosition() {
        customView.isHidden = false
        let height = frame.height
        let width = frame.width
        
        let actualOffset = scrollView.contentOffset.y + originalTopInset

        // positioning the container in the center of the space betwe
        let calculatedOriginY = (actualOffset - height) / 2.0
        let originY = min(calculatedOriginY, -customView.bounds.height / 2.0 - height / 2.0)
        
        let newFrame = CGRect(x: frame.origin.x,
                              y: originY,
                              width: width,
                              height: height)
        
        frame = newFrame
    }
    
    @objc func gestureRecognizerUpdated(_ sender: UIPanGestureRecognizer) {
        if !enteredPullToRefreshZone && state == .triggered {
            customView.isHidden = true
            return
        }
        updatePullToRefreshFramePosition()
        switch sender.state {
        case .began:
            if state != .loading {
                state = .triggered
            }
        case .ended:
            if state == .stopped && isAnimating {
                resetScrollViewContentInset()
            } else if state == .loading && enteredPullToRefreshZone {
                scrollViewContentInsetForLoading()
            }
        default:
            break
        }
    }
    
    func scrollViewDidScroll(contentOffset: CGPoint) {
        if !enteredPullToRefreshZone && state == .triggered {
            customView.isHidden = true
            return
        }
        updatePullToRefreshFramePosition()
        let threshold = animationDistance + animationStart
        let absoluteOffsetY = abs(contentOffset.y + originalTopInset)
        
        switch state {
        case .triggered:
            if absoluteOffsetY > threshold {
                state = .loading
            }
            let proportion = spinnerProportion(absoluteOffsetY: absoluteOffsetY,
                                               threshold: threshold,
                                               start: animationStart)
            animatable.drawPullToRefresh(proportion: proportion)
            
        case .loading:
            if stoppedDragging {
                scrollViewContentInsetForLoading()
            }
        default:
            break
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath {
            if keyPath == #keyPath(UIScrollView.contentOffset),
                let currentOffset = change?[.newKey] as? NSValue {
                scrollViewDidScroll(contentOffset: currentOffset.cgPointValue)
            } else if keyPath == #keyPath(UIScrollView.frame) {
                layoutSubviews()
            }
        }
    }
    
    func scrollViewContentInsetForLoading() {
        let currentInsets = self.currentInsets(with: originalTopInset + bounds.height)
        scrollViewAnimateChange(contentInset: currentInsets, animationBlock: nil)
    }
    
    func currentInsets(with newTopInset: CGFloat) -> UIEdgeInsets {
        var currentInsets = scrollView.contentInset
        currentInsets.top = newTopInset
        return currentInsets
    }
    
    func resetScrollViewContentInset() {
        let currentInsets = self.currentInsets(with: originalTopInset)
        scrollViewAnimateChange(contentInset: currentInsets) {
            if self.state == .stopped {
                self.willStopAnimation()
            }
        }
    }
    
    func stopAnimating() {
        DispatchQueue.main.async {
            self.state = .stopped
        }
    }
    
    private func scrollViewAnimateChange(contentInset: UIEdgeInsets, animationBlock: ActionHandler?) {
        UIView.animate(withDuration: contentInsetChangeAnimationDuration) {
            animationBlock?()
            self.scrollView.contentInset = contentInset
        }
    }
    
    private func spinnerProportion(absoluteOffsetY: CGFloat, threshold: CGFloat, start: CGFloat) -> CGFloat {
        let deltaOffset = max(absoluteOffsetY - start, 0)
        let proportion = min(deltaOffset / (threshold - start), 1.0)
        
        return proportion
    }
    
    private func willStartAnimation() {
        animatable.startAnimation()
        isAnimating = true
    }
    
    private func willStopAnimation() {
        animatable.stopAnimation()
        isAnimating = false
    }
}
