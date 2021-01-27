import Foundation

public enum SVGInstruction: String, Equatable, CaseIterable {
    case arc = "A"
    case arcRelative = "a"
    case move = "M"
    case moveRelative = "m"
    case line = "L"
    case lineRelative = "l"
    case horizontal = "H"
    case horizontalRelative = "h"
    case vertical = "V"
    case verticalRelative = "v"
    case closePath = "Z"
    case closePathSmall = "z"
    case cubic = "C"
    case cubicRelative = "c"
    case shorthandCubic = "S"
    case shorthandCubicRelative = "s"
    case quadratic = "Q"
    case quadraticRelative = "q"
    case shorthandQuadratic = "T"
    case shorthandQuadraticRelative = "t"
    
    var nonRelative: SVGInstruction {
        switch self {
        case .horizontalRelative:
            return .horizontal
        case .verticalRelative:
            return .vertical
        case .lineRelative:
            return .line
        case .cubicRelative:
            return .cubic
        case .shorthandCubicRelative:
            return .shorthandCubic
        case .moveRelative:
            return .move
        case .quadraticRelative:
            return .quadratic
        case .shorthandQuadraticRelative:
            return .shorthandQuadratic
        case .arcRelative:
            return .arc
            
        default:
            return .line
        }
    }
    
    var nonShorthand: SVGInstruction {
        switch self {
        case .shorthandCubic:
            return .cubic
        case .shorthandQuadratic:
            return .quadratic
        default:
            return .line
        }
    }
    
    var isRelative: Bool {
        switch self {
        case .horizontalRelative:
            return true
        case .verticalRelative:
            return true
        case .lineRelative:
            return true
        case .cubicRelative:
            return true
        case .shorthandCubicRelative:
            return true
        case .moveRelative:
            return true
        case .quadraticRelative:
            return true
        case .shorthandQuadraticRelative:
            return true
        case .arcRelative:
            return true
            
        default:
            return false
        }
    }
    
    var valuesCount: Int {
        switch self {
        case .cubic, .cubicRelative:
            return 6
        case .quadratic, .quadraticRelative, .shorthandCubic, .shorthandCubicRelative:
            return 4
        case .line, .lineRelative, .shorthandQuadratic, .shorthandQuadraticRelative, .move, .moveRelative:
            return 2
        case .vertical, .verticalRelative, .horizontal, .horizontalRelative:
            return 1
        default:
            return 0
        }
    }
    
    var isShorthand: Bool {
        switch self {
        case .shorthandCubicRelative:
            return true
        case .shorthandCubic:
            return true
        case .shorthandQuadratic:
            return true
        case .shorthandQuadraticRelative:
            return true
            
        default:
            return false
        }
    }
}
