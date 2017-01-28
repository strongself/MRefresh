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

public typealias ProcessingAnimationClosure = (CALayer) -> ()
public typealias EndAnimationClosure = (CALayer, @escaping () -> ()) -> ()

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
    
    public var processingAnimationClosure: ProcessingAnimationClosure?
    public var endAnimationClosure: EndAnimationClosure?
    
    public init(frame: CGRect, pathManager: SVGPathManager) {
		rotationAnimation = animationsFactory.rotationAnimation()
		shrinkAnimation = animationsFactory.shrinkAnimation()
		fadeAnimation = animationsFactory.fadeAnimation()
        blinkAnimation = animationsFactory.blinkAnimation()
		
        self.pathManager = pathManager
        super.init(frame: frame)
        
        processingAnimationClosure = defaultProcessingAnimationClosure()
        endAnimationClosure = defaultEndAnimationClosure()
        
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
		endAnimationClosure?(layer, removeAllAnimations)
	}
	
	open func startAnimation() {
        restartAnimation()
	}
	
	private func restartAnimation() {
		layer.removeAllAnimations()
        processingAnimationClosure?(layer)
    }
	
	private func removeAllAnimations() {
        layer.removeAllAnimations()
		pathLayer?.removeFromSuperlayer()
    }
    
    private func defaultProcessingAnimationClosure() -> ProcessingAnimationClosure {
        return { [weak self] layer in
            guard let strongSelf = self else {
                return
            }
            strongSelf.layer.add(strongSelf.blinkAnimation, forKey: strongSelf.constants.KeyPaths.blinkAnimation)
        }
    }
    
    private func defaultEndAnimationClosure() -> EndAnimationClosure {
        return { [weak self] layer, completion in
            guard let strongSelf = self else {
                return
            }
            
            layer.add(strongSelf.shrinkAnimation,
                      forKey: strongSelf.constants.KeyPaths.shrinkAnimation)
            DispatchQueue.main.asyncAfter(deadline: .now() + strongSelf.shrinkAnimation.duration / 2.0) {
                strongSelf.layer.add(strongSelf.fadeAnimation,
                                     forKey: strongSelf.constants.KeyPaths.fadeAnimation)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + strongSelf.shrinkAnimation.duration) {
                completion()
            }
        }
    }
}
