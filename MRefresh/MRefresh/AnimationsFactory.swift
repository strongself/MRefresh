import Foundation
import UIKit

fileprivate struct Constants {
    struct KeyPaths {
        static let rotationAnimation = "transform.rotation.z"
        static let scaleAnimation = "transform.scale"
        static let opacityAnimation = "opacity"
    }
    
    struct Durations {
        static let rotationAnimation = 0.8
        static let shrinkAnimation = 0.1
        static let fadeAnimation = 0.05
    }
}

public class AnimationsFactory {
    
    private let constants = Constants.self
    
    func rotationAnimation() -> CABasicAnimation {
        let rotationAnimation = CABasicAnimation(keyPath: constants.KeyPaths.rotationAnimation)
        
        rotationAnimation.toValue = 2.0 * CGFloat.pi
        rotationAnimation.duration = constants.Durations.rotationAnimation
        rotationAnimation.repeatCount = HUGE
        rotationAnimation.isRemovedOnCompletion = false
        
        return rotationAnimation
    }
    
    func shrinkAnimation() -> CABasicAnimation {
        let shrinkAnimation = CABasicAnimation(keyPath: constants.KeyPaths.scaleAnimation)
        
        shrinkAnimation.toValue = 0
        shrinkAnimation.duration = constants.Durations.shrinkAnimation
        shrinkAnimation.fillMode = .forwards
        shrinkAnimation.isRemovedOnCompletion = false
        
        return shrinkAnimation
    }
    
    func fadeAnimation() -> CABasicAnimation {
        let fadeAnimation = CABasicAnimation(keyPath: constants.KeyPaths.opacityAnimation)
        
        fadeAnimation.toValue = 0
        fadeAnimation.duration = constants.Durations.fadeAnimation
        fadeAnimation.fillMode = .forwards
        fadeAnimation.isRemovedOnCompletion = false
        
        return fadeAnimation
    }
    
    func blinkAnimation() -> CABasicAnimation {
        let blinkAnimation = CABasicAnimation(keyPath: constants.KeyPaths.opacityAnimation)
        
        blinkAnimation.toValue = 0.3
        blinkAnimation.duration = constants.Durations.rotationAnimation
        blinkAnimation.fillMode = .forwards
        blinkAnimation.repeatCount = HUGE
        blinkAnimation.autoreverses = true
        blinkAnimation.isRemovedOnCompletion = false
        
        return blinkAnimation
    }
}
