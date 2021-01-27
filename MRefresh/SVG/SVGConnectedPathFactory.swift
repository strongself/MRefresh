import UIKit

public struct SVGConnectedPathConfiguration {
    public var elements: [(svg: String, startProportion: CGFloat, depth: Int)] = []
    public let size: CGSize
    
    public init(size: CGSize) {
        self.size = size
    }
    
    public mutating func add(svg: String, startProportion: CGFloat, depth: Int) {
        elements.append((svg, startProportion, depth))
    }
}

public struct SVGConnectedPath {
    public let proportionPaths: [(startProportion: CGFloat, path: SVGPath)]
}

/// Creates one or more connected path from the svgs
public final class SVGConnectedPathFactory {
    private let factory: SVGPathFactory
    private let resizer: SVGResizer

    public static let `default` = SVGConnectedPathFactory()
    
    init(factory: SVGPathFactory = SVGPathFactoryImpl(),
         resizer: SVGResizer = SVGResizerImpl()) {
        self.factory = factory
        self.resizer = resizer
    }
    
    public func make(pathConfiguration: SVGConnectedPathConfiguration) throws -> SVGConnectedPath {
        var proportionPaths = try pathConfiguration.elements.map {
            (startProportion: $0.startProportion,
             path: try factory.make(svg: $0.svg, smoothDepth: $0.depth))
        }
        
        let allNodes = proportionPaths.reduce(into: [], {
            $0 += $1.path.nodes
        })
        let parameters = resizer.getResizingParameters(allNodes, for: pathConfiguration.size)
        proportionPaths = proportionPaths.map { proportion, path in
            let rescaled = resizer.rescaled(path.nodes, scale: parameters.scale)
            let nodes = resizer.moved(rescaled, offset: parameters.offset)
            return (startProportion: proportion, path: SVGPath(nodes: nodes))
        }
        
        return SVGConnectedPath(
            proportionPaths: proportionPaths
        )
    }
}
