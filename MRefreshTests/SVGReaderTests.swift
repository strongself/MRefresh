import XCTest
@testable import MRefresh

func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
    return CGPoint(x: x, y: y)
}

class SVGReaderTests: XCTestCase {
    
    private let reader = MRefresh.SVGReaderImpl()
    
    func testReadNonRelativeSVG() throws {
        // given
        let svg = "M100 100L200 200Q300 300 400 400C500 500 600 600 700 700V800H800Z"
        let expectedNodes = [
            SVGNode(instruction: .move, points: [p(100, 100)]),
            SVGNode(instruction: .line, points: [p(200, 200)]),
            SVGNode(instruction: .quadratic, points: [p(300, 300), p(400, 400)]),
            SVGNode(instruction: .cubic, points: [p(500, 500), p(600, 600), p(700, 700)]),
            SVGNode(instruction: .vertical, points: [p(0, 800)]),
            SVGNode(instruction: .horizontal, points: [p(800, 0)]),
            SVGNode(instruction: .closePath, points: [])
        ]

        // when
        let nodes = try reader.read(svg)

        // then
        XCTAssertEqual(nodes, expectedNodes)
    }

    func testReadRelativeSVG() throws {
        // given
        let svg = "m100 100l20 20q50 50 50 50c100 100 100 100 100 100v100h100z"
        let expectedNodes = [
            SVGNode(instruction: .moveRelative, points: [p(100, 100)]),
            SVGNode(instruction: .lineRelative, points: [p(20, 20)]),
            SVGNode(instruction: .quadraticRelative, points: [p(50, 50), p(50, 50)]),
            SVGNode(instruction: .cubicRelative, points: [p(100, 100), p(100, 100), p(100, 100)]),
            SVGNode(instruction: .verticalRelative, points: [p(0, 100)]),
            SVGNode(instruction: .horizontalRelative, points: [p(100, 0)]),
            SVGNode(instruction: .closePathSmall, points: [])
        ]

        // when
        let nodes = try reader.read(svg)

        // then
        XCTAssertEqual(nodes, expectedNodes)
    }

    func testShorthandSVG() throws {
        // given
        let svg = "M100 100L200 200T400 400S500 500 600 600Z"
        let expectedNodes = [
            SVGNode(instruction: .move, points: [p(100, 100)]),
            SVGNode(instruction: .line, points: [p(200, 200)]),
            SVGNode(instruction: .shorthandQuadratic, points: [p(400, 400)]),
            SVGNode(instruction: .shorthandCubic, points: [p(500, 500), p(600, 600)]),
            SVGNode(instruction: .closePath, points: [])
        ]

        // when
        let nodes = try reader.read(svg)

        // then
        XCTAssertEqual(nodes, expectedNodes)
    }

    func testShorthandRelativeSVG() throws {
        // given
        let svg = "M100 100L200 200t100 100s50 50 60 60Z"
        let expectedNodes = [
            SVGNode(instruction: .move, points: [p(100, 100)]),
            SVGNode(instruction: .line, points: [p(200, 200)]),
            SVGNode(instruction: .shorthandQuadraticRelative, points: [p(100, 100)]),
            SVGNode(instruction: .shorthandCubicRelative, points: [p(50, 50), p(60, 60)]),
            SVGNode(instruction: .closePath, points: [])
        ]

        // when
        let nodes = try reader.read(svg)

        // then
        XCTAssertEqual(nodes, expectedNodes)
    }

    func testSVGWithUnknownSymbols() {
        // given
        let svg = "M100 100S100 100 100 100R100 100Z"

        // when
        var returnedError: Error?
        do {
            _ = try reader.read(svg)
        } catch {
            returnedError = error
        }

        // then
        XCTAssertNotNil(returnedError)
    }

    func testSVGWithIncorrectPoints() {
        for instruction in SVGInstruction.allCases {
            // given
            let values: String
            // generating different number of points than expected
            switch instruction.valuesCount {
                case 0:
                    values = "100"
                case 1:
                    values = ""
                default:
                    values = (0 ... instruction.valuesCount).map { _ in "100" }.joined(separator: " ")
            }
            let testedSvg = "M100 100S100 100 100 100\(instruction.rawValue + values)Z"

            // when
            var returnedError: Error?
            do {
                _ = try reader.read(testedSvg)
            } catch {
                returnedError = error
            }

            // then
            XCTAssertNotNil(returnedError)
        }
    }
}
