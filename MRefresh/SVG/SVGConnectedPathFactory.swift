import UIKit

struct SVGConnectedPathConfiguration {
    var elements: [(svg: String, startProportion: CGFloat, depth: Int)] = []
    let size: CGSize
    
    init(size: CGSize) {
        self.size = size
    }
    
    mutating func add(svg: String, startProportion: CGFloat, depth: Int) {
        elements.append((svg, startProportion, depth))
    }
}

public struct SVGConnectedPath {
    public let proportionPaths: [(startProportion: CGFloat, path: SVGPath)]
}

final class SVGConnectedPathFactory {
    private let factory: SVGPathFactory
    private let resizer: SVGResizer
    
    init(factory: SVGPathFactory = .init(),
         resizer: SVGResizer = .init()) {
        self.factory = factory
        self.resizer = resizer
    }
    
    func make(pathConfiguration: SVGConnectedPathConfiguration) throws -> SVGConnectedPath {
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
