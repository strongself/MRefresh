import UIKit

enum SpinnerConstants {
    enum Circle {
        static let borderWidthDefault: CGFloat = 2.0
        static let arcStartAngle: CGFloat = -CGFloat.pi / 8.0
        static let arcProportionDefault: CGFloat = 0.9
    }
}

public struct LayerConfiguration {
    let path: UIBezierPath
    let lineWidth: CGFloat
    let fillColor: CGColor
    let strokeColor: CGColor
    
    public init(path: UIBezierPath, lineWidth: CGFloat, fillColor: CGColor, strokeColor: CGColor) {
        self.path = path
        self.lineWidth = lineWidth
        self.fillColor = fillColor
        self.strokeColor = strokeColor
    }
}

public final class LayerFactory {

    public init() {}

    public func circleLayer(radius: CGFloat, proportion: CGFloat, borderColor: UIColor, backgroundColor: UIColor) -> CAShapeLayer {
        let constants = SpinnerConstants.Circle.self
        let layer = CAShapeLayer()
        let startAngle = constants.arcStartAngle
        let endAngle = startAngle + 2 * CGFloat.pi * proportion * constants.arcProportionDefault
        
        let bezierPath = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius),
                                      radius: radius,
                                      startAngle: startAngle,
                                      endAngle: endAngle,
                                      clockwise: true)
        layer.path = bezierPath.cgPath
        layer.lineWidth = constants.borderWidthDefault
        layer.strokeColor = borderColor.cgColor
        layer.fillColor = backgroundColor.cgColor
        
        return layer
    }
    
    public func layer(from configuration: LayerConfiguration) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.path = configuration.path.cgPath
        layer.lineWidth = configuration.lineWidth
        layer.strokeColor = configuration.strokeColor
        layer.fillColor = configuration.fillColor
        
        return layer
    }
}
