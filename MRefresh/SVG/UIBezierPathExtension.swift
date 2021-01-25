import UIKit

public enum ConvertErrors: Error {
    case invalidArgs
    case noStartingPoint
}

extension UIBezierPath {
    convenience init(path: SVGConnectedPath, proportion: CGFloat? = nil) throws {
        self.init()
        let currentProportion = proportion ?? 1.0
        let currentPaths = path.proportionPaths.filter { $0.startProportion < currentProportion }
        
        guard !currentPaths.isEmpty else {
            return
        }
        
        try currentPaths.map { proportionPath in
            let proportion = calculateRelativeProportion(currentProportion: currentProportion, startProportion: proportionPath.startProportion)
            return try UIBezierPath(path: proportionPath.path, proportion: proportion)
        }.forEach { append($0) }
    }
    
    private convenience init(path: SVGPath, proportion: CGFloat? = nil) throws {
        self.init()
        let count = Int(CGFloat(path.nodes.count) * (proportion ?? 1.0))
        
        guard count >= 2 else {
            return
        }
        
        try convert(path.nodes, count: count)
    }
    
    private func convert(_ nodes: [SVGNode], count: Int) throws {
        guard nodes.count > 1 else {
            throw ConvertErrors.invalidArgs
        }
        
        var subpathPointsStack = Stack<CGPoint>()
        
        if nodes[0].instruction != .move {
            throw ConvertErrors.noStartingPoint
        }
        
        move(to: nodes[0].points[0])
        
        for index in 1 ..< count {
            addNode(nodes[index], stack: &subpathPointsStack)
        }
    }
    
    private func addNode(_ currentNode: SVGNode, stack: inout Stack<CGPoint>) {
        switch currentNode.instruction {
        case .line:
            addLine(to: currentNode.points[0])
            
        case .cubic:
            addCurve(to: currentNode.points[2], controlPoint1: currentNode.points[0], controlPoint2: currentNode.points[1])
            
        case .quadratic:
            addQuadCurve(to: currentNode.points[1], controlPoint: currentNode.points[0])
            
        case .horizontal:
            addLine(to: currentNode.points[0])
            
        case .vertical:
            addLine(to: currentNode.points[0])
            
        case .move:
            move(to: currentNode.points[0])
            stack.push(currentNode.points[0])
            
        case .closePathSmall, .closePath:
            if let point = stack.pop() {
                move(to: point)
            }
            
        default:
            break
        }
    }
    
    private func calculateRelativeProportion(currentProportion: CGFloat, startProportion: CGFloat) -> CGFloat {
        return max((currentProportion - startProportion) / (1.0 - startProportion), 0)
    }
}
