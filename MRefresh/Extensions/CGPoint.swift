import Foundation
import UIKit

extension CGPoint {
    func offset(_ p: CGPoint) -> CGPoint {
        return CGPoint(x: x + p.x, y: y + p.y)
    }
}
