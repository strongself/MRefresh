import Foundation
import UIKit

public struct SVGNode {
    public var instruction: SVGInstruction
    public var points: [CGPoint]
}

extension CGPoint {
    static func isEqual(
        _ lhs: CGPoint,
        _ rhs: CGPoint
    ) -> Bool {
        let isEqual: (CGFloat, CGFloat) -> Bool = {
            return abs($0 - $1) < CGFloat.ulpOfOne
        }
        return isEqual(lhs.x, rhs.x) && isEqual(lhs.y, rhs.y)
    }
}

extension SVGNode: Equatable {
    public static func ==(
        lhs: SVGNode,
        rhs: SVGNode
    ) -> Bool {
        if lhs.instruction != rhs.instruction {
            return false
        }
        if lhs.points.count != rhs.points.count {
            return false
        }
        for (first, second) in zip(lhs.points, rhs.points) {
            // default CGPoint comparison doesn't work good because of how float comparison works
            if !CGPoint.isEqual(first, second) {
                return false
            }
        }
        return true
    }
}
