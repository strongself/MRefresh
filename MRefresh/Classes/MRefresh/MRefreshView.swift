//
//  MRefreshView.swift
//  RamblerYearlyEventApplication
//
//  Created by m.rakhmanov on 08.10.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import UIKit

enum MRefreshState {
    case stopped
    case triggered
    case loading
}

let π = CGFloat(M_PI)

enum MRefreshViewConstants {
    enum KeyPaths {
        static let contentOffset = "contentOffset"
        static let frame = "frame"
    }
}


class MRefreshView: UIView {
    
    fileprivate let scrollView: UIScrollView
    fileprivate let customView: UIView
    fileprivate let animatable: MRefreshAnimatable
    fileprivate let handler: ActionHandler
    fileprivate let constants = MRefreshViewConstants.self
    fileprivate let animationEndDistanceOffset: CGFloat
    fileprivate let animationStartDistance: CGFloat
    fileprivate let contentInsetChangeAnimationDuration: Double
    fileprivate var privateState: MRefreshState = .triggered
    
    var originalTopInset: CGFloat
    
    var isAnimating = false
    var isObserving = false
    
    var stoppedDragging: Bool {
        return !scrollView.isDragging || scrollView.isDecelerating
    }
    
    var enteredPullToRefreshZone: Bool {
        return scrollView.contentOffset.y + scrollView.contentInset.top <= 0
    }
    
    var state: MRefreshState {
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
                break
            case .loading:
                handler()
                if !self.isAnimating {
                    self.willStartAnimation()
                }
            }
        }
    }
    
    init(frame: CGRect, configuration: MRefreshViewConfiguration) {
        scrollView = configuration.scrollView
        customView = configuration.animatable.getView
        animatable = configuration.animatable
        handler = configuration.handler
        animationEndDistanceOffset = configuration.animationEndDistanceOffset
        animationStartDistance = configuration.animationStartDistance
        originalTopInset = scrollView.contentInset.top
        contentInsetChangeAnimationDuration = configuration.contentInsetChangeAnimationDuration
        
        super.init(frame: frame)
        addSubview(customView)
        autoresizingMask = UIViewAutoresizing.flexibleWidth
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let viewBounds = customView.bounds
        let customViewWidth = viewBounds.width
        let customViewHeight = viewBounds.height
        let originX = (bounds.width - customViewWidth) / 2.0
        let originY = (bounds.height - customViewHeight) / 2.0
        
        let customViewFrame = CGRect(x: originX,
                                     y: originY,
                                     width: customViewWidth,
                                     height: customViewHeight)
        customView.frame = customViewFrame
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if let scrollView = superview as? UIScrollView, newSuperview == nil {
            
            if scrollView.showsPullToRefresh && isObserving == true {
                scrollView.removeObserver(self, forKeyPath: constants.KeyPaths.contentOffset)
                scrollView.removeObserver(self, forKeyPath: constants.KeyPaths.frame)
                scrollView.panGestureRecognizer.removeTarget(self, action: #selector(MRefreshView.gestureRecognizerUpdated(_:)))
            }
            
            isObserving = false
        }
    }
    
    func updatePullToRefreshFramePosition() {
        let height = frame.height
        let width = frame.width
        
        let actualOffset = scrollView.contentOffset.y + originalTopInset
        let calculatedOriginY = (actualOffset - height) / 2.0
        let originY = fmin(calculatedOriginY, 0)
        
        let newFrame = CGRect(x: frame.origin.x,
                              y: originY,
                              width: width,
                              height: height)
        
        frame = newFrame
    }
    
    func gestureRecognizerUpdated(_ sender: UIPanGestureRecognizer) {
        updatePullToRefreshFramePosition()
        switch sender.state {
        case .began:
            if state != .loading {
                state = .triggered
            }
            break
        case .ended:
            if state == .stopped && isAnimating {
                resetScrollViewContentInset()
            } else if state == .loading && enteredPullToRefreshZone {
                scrollViewContentInsetForLoading()
            }
            break
        default:
            break
        }
    }
    
    func scrollViewDidScroll(contentOffset: CGPoint) {
        if !enteredPullToRefreshZone {
            return
        }
        updatePullToRefreshFramePosition()
        
        let threshold = bounds.height + animationEndDistanceOffset
        let absoulteOffsetY = fabs(contentOffset.y + originalTopInset)
        
        switch state {
        case .triggered:
            if absoulteOffsetY > threshold {
                state = .loading
            }
            let proportion = spinnerProportion(absoluteOffsetY: absoulteOffsetY,
                                               threshold: threshold,
                                               start: animationStartDistance)
            animatable.drawIndicatorView(proportion: proportion)
            break
            
        case .loading:
            if stoppedDragging {
                scrollViewContentInsetForLoading()
            }
            break
        default:
            break
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath {
            if keyPath == constants.KeyPaths.contentOffset,
                let currentOffset = change?[.newKey] as? NSValue {
                scrollViewDidScroll(contentOffset: currentOffset.cgPointValue)
            } else if keyPath == constants.KeyPaths.frame {
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
        state = .stopped
    }
    
    private func scrollViewAnimateChange(contentInset: UIEdgeInsets, animationBlock: ActionHandler?) {
        UIView.animate(withDuration: contentInsetChangeAnimationDuration) {
            animationBlock?()
            self.scrollView.contentInset = contentInset
        }
    }
    
    private func spinnerProportion(absoluteOffsetY: CGFloat, threshold: CGFloat, start: CGFloat) -> CGFloat {
        let increaseMultiplier = threshold / (threshold - start)
        let deltaOffset = max(absoluteOffsetY - start, 0)
        let proportion = min(deltaOffset * increaseMultiplier / threshold, 1.0)
        
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
