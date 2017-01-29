//
//  UITableViewExtension.swift
//  RamblerYearlyEventApplication
//
//  Created by m.rakhmanov on 08.10.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {
    
    struct AssociatedKeys {
        static var pullToRefreshViewKey = "pullToRefreshViewKey"
    }
    
    var pullToRefreshView: MRefreshView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.pullToRefreshViewKey) as? MRefreshView
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
            let constants = MRefreshViewConstants.KeyPaths.self
            
            if (!showsPullToRefresh && pullToRefreshView.isObserving) {
                self.removeObserver(pullToRefreshView, forKeyPath: constants.contentOffset)
                self.removeObserver(pullToRefreshView, forKeyPath: constants.frame)
                self.panGestureRecognizer.removeTarget(pullToRefreshView,
                                                       action: #selector(MRefreshView.gestureRecognizerUpdated(_:)))
                pullToRefreshView.isObserving = false
            } else if (showsPullToRefresh && !pullToRefreshView.isObserving) {
                self.addObserver(pullToRefreshView,
                                 forKeyPath: constants.contentOffset,
                                 options: NSKeyValueObservingOptions.new,
                                 context: nil)
                self.addObserver(pullToRefreshView,
                                 forKeyPath: constants.frame,
                                 options: NSKeyValueObservingOptions.new,
                                 context: nil)
                self.panGestureRecognizer.addTarget(pullToRefreshView,
                                                    action: #selector(MRefreshView.gestureRecognizerUpdated(_:)))
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
	   
    open func addPullToRefresh(animatable: MRefreshAnimatableViewConforming,
                               configuration: MRefreshConfiguration,
                               handler: @escaping ActionHandler) {
        guard pullToRefreshView == nil else {
            return
        }
        
        let mRefreshViewSizeHeight = animatable.getView.frame.size.height + configuration.heightIncrease
        
        let pullToRefreshFrame = CGRect(x: 0,
                                        y: -mRefreshViewSizeHeight,
                                        width: bounds.width,
                                        height: mRefreshViewSizeHeight)
        
        let viewConfiguration = MRefreshViewConfiguration(frame: pullToRefreshFrame,
                                                          animatable: animatable,
                                                          scrollView: self,
                                                          animationEndDistanceOffset: configuration.animationEndDistanceOffset,
                                                          animationStartDistance: configuration.animationStartDistance,
                                                          handler: handler,
                                                          contentInsetChangeAnimationDuration: configuration.contentInsetChangeAnimationDuration)
        
        let newPullToRefreshView = MRefreshView(frame: pullToRefreshFrame,
                                                configuration: viewConfiguration)
        addSubview(newPullToRefreshView)
        sendSubview(toBack: newPullToRefreshView)
        
        pullToRefreshView = newPullToRefreshView
        
        showsPullToRefresh = true
    }
}
