//
//  MRefreshAnimatableView.swift
//  RamblerYearlyEventApplication
//
//  Created by m.rakhmanov on 08.10.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import UIKit

enum MRefreshAnimatableViewConstants {
    enum KeyPaths {
        static let rotationAnimation = "rotationAnimation"
        static let shrinkAnimation = "shrinkAnimation"
        static let fadeAnimation = "fadeAnimation"
        static let blinkAnimation = "blinkAnimation"
    }
}

open class MRefreshAnimatableView: UIView, MRefreshAnimatableViewConforming {
	
	fileprivate let animationsFactory = MRefreshAnimationsFactory()
	fileprivate let sublayersFactory = MRefreshSublayersFactory()
    fileprivate let constants = MRefreshAnimatableViewConstants.self
	
    fileprivate var rotationAnimation: CABasicAnimation
	fileprivate var shrinkAnimation: CABasicAnimation
	fileprivate var fadeAnimation: CABasicAnimation
    fileprivate var blinkAnimation: CABasicAnimation
	
    fileprivate var pathLayer: CAShapeLayer?
    fileprivate var pathManager: SVGPathManager
    
    public init(frame: CGRect, pathManager: SVGPathManager) {
		rotationAnimation = animationsFactory.rotationAnimation()
		shrinkAnimation = animationsFactory.shrinkAnimation()
		fadeAnimation = animationsFactory.fadeAnimation()
        blinkAnimation = animationsFactory.blinkAnimation()
		
        self.pathManager = pathManager
        
		super.init(frame: frame)
        
		backgroundColor = UIColor.clear
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open func drawIndicatorView(proportion: CGFloat) {
        guard let path = try? pathManager.toPath(proportion: proportion) else { return }
        
        pathLayer?.removeFromSuperlayer()
        
        let configuration = LayerConfiguration(path: path,
                                               lineWidth: 1.0,
                                               fillColor: UIColor.clear.cgColor,
                                               strokeColor: UIColor.black.cgColor)
		let newPathLayer = sublayersFactory.layer(from: configuration)
        layer.addSublayer(newPathLayer)
        
        pathLayer = newPathLayer
	}
	
	open func stopAnimation() {
		addShrinkAnimation()
		addFadeAnimation()
		removeAllAnimationsUponCompletion()
	}
	
	open func startAnimation() {
		 restartAnimation()
	}
	
	private func restartAnimation() {
		layer.removeAllAnimations()
        layer.add(blinkAnimation, forKey: constants.KeyPaths.blinkAnimation)
    }
	
	private func addShrinkAnimation() {
    	layer.add(shrinkAnimation, forKey: constants.KeyPaths.shrinkAnimation)
    }
	
    private func addFadeAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + shrinkAnimation.duration / 2.0) {
            self.layer.add(self.fadeAnimation, forKey: self.constants.KeyPaths.fadeAnimation)
        }
    }
	
	private func removeAllAnimationsUponCompletion() {
        DispatchQueue.main.asyncAfter(deadline: .now() + shrinkAnimation.duration) {
			self.layer.removeAllAnimations()
			self.pathLayer?.removeFromSuperlayer()
		}
	}
}
