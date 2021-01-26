import UIKit

public extension PathDrawingAnimatableView {
    convenience init(path: SVGConnectedPath, frame: CGRect) {
        self.init(frame: frame)
        makePullToRefreshLayer = makePathLayerClosure(path: path)
    }
}

private func makePathLayerClosure(path: SVGConnectedPath) -> MakeLayerWithProportionClosure {
    let factory = LayerFactory()
    return { size, proportion in
        guard let path = try? UIBezierPath(path: path, proportion: proportion) else {
            return CAShapeLayer()
        }
        let configuration = LayerConfiguration(
            path: path,
            lineWidth: 1.0,
            fillColor: UIColor.clear.cgColor,
            strokeColor: UIColor.black.cgColor
        )
        let layer = factory.layer(from: configuration)
        return layer
    }
}
