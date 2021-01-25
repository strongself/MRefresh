import Foundation
import UIKit

public typealias MakeLayerWithProportionClosure = (CGSize, CGFloat) -> CALayer
public typealias ProcessingAnimationClosure = (CALayer) -> ()
public typealias EndAnimationClosure = (CALayer, @escaping () -> ()) -> ()

open class DefaultAnimatableView: UIView {

    fileprivate let animationsFactory = AnimationsFactory()
    fileprivate let sublayersFactory = LayersFactory()
    
    fileprivate var pathLayer: CALayer?

    public var makePullToRefreshLayer: MakeLayerWithProportionClosure = makeLayerWithProportionClosure()
    public var processingAnimation: ProcessingAnimationClosure = defaultProcessingAnimationClosure()
    public var endAnimation: EndAnimationClosure = defaultEndAnimationClosure()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func removeAllAnimations() {
        pathLayer?.removeFromSuperlayer()
        layer.removeAllAnimations()
    }
}

extension DefaultAnimatableView: AnimatableViewConforming {
    open func drawPullToRefresh(proportion: CGFloat) {
        pathLayer?.removeFromSuperlayer()
        let newPathLayer = makePullToRefreshLayer(bounds.size, proportion)
        layer.addSublayer(newPathLayer)
        
        pathLayer = newPathLayer
    }
    
    open func stopAnimation() {
        endAnimation(layer, removeAllAnimations)
    }
    
    open func startAnimation() {
        layer.removeAllAnimations()
        processingAnimation(layer)
    }
}

private func makeLayerWithProportionClosure() -> MakeLayerWithProportionClosure {
    let factory = LayersFactory()
    return { size, proportion in
        factory.circleLayer(
            radius: size.width / 2.0,
            proportion: proportion,
            borderColor: .blue,
            backgroundColor: UIColor.clear
        )
    }
}

private func defaultProcessingAnimationClosure() -> ProcessingAnimationClosure {
    let blinkAnimation = AnimationsFactory().blinkAnimation()
    return { layer in
        layer.add(blinkAnimation, forKey: "blinkAnimation")
    }
}

private func defaultEndAnimationClosure() -> EndAnimationClosure {
    let shrinkAnimation = AnimationsFactory().shrinkAnimation()
    let fadeAnimation = AnimationsFactory().fadeAnimation()
    
    return { layer, completion in
        CATransaction.begin()
        fadeAnimation.beginTime = layer.convertTime(CACurrentMediaTime(), from: nil) + shrinkAnimation.duration / 2.0
        
        CATransaction.setCompletionBlock {
            completion()
        }
        layer.add(shrinkAnimation, forKey: "shrinkAnimation")
        layer.add(fadeAnimation, forKey: "fadeAnimation")
        
        CATransaction.commit()
    }
}
