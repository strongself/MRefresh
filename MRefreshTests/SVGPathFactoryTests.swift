import XCTest
@testable import MRefresh

class SVGPathFactoryTests: XCTestCase {

    private var reader: SVGReaderMock!
    private var simplifier: SVGSimplifierMock!
    private var smoother: SVGSmootherMock!
    private var factory: SVGPathFactoryImpl!

    override func setUp() {
        reader = SVGReaderMock()
        simplifier = SVGSimplifierMock()
        smoother = SVGSmootherMock()
        factory = SVGPathFactoryImpl(reader: reader, simplifier: simplifier, smoother: smoother)
    }

    func testFactoryMakesSVGPathCorrectly() throws {
        // given
        let expectedSvg = "m100 100"
        let readNodes = [SVGNode(instruction: .move, points: [p(100, 100)])]
        let simplifiedNodes = [SVGNode(instruction: .move, points: [p(200, 200)])]
        let smoothedNodes = [SVGNode(instruction: .move, points: [p(300, 300)])]
        let expectedDepth = 2
        reader.returnValue = readNodes
        simplifier.returnValue = simplifiedNodes
        smoother.returnValue = smoothedNodes

        // when
        let path = try factory.make(svg: expectedSvg, smoothDepth: expectedDepth)

        // then
        XCTAssertEqual(path.nodes, smoothedNodes)
        XCTAssertEqual(reader.svg, expectedSvg)
        XCTAssertEqual(simplifier.nodes, readNodes)
        XCTAssertEqual(smoother.parameters?.times, expectedDepth)
        XCTAssertEqual(smoother.parameters?.nodes, simplifiedNodes)
    }

    func testFactoryFailsWithError() {
        // given
        let expectedSvg = "m100 100"
        let simplifiedNodes = [SVGNode(instruction: .move, points: [p(200, 200)])]
        let smoothedNodes = [SVGNode(instruction: .move, points: [p(300, 300)])]
        let expectedDepth = 2
        reader.returnValue = nil
        simplifier.returnValue = simplifiedNodes
        smoother.returnValue = smoothedNodes

        // when
        var returnedError: Error?
        do {
            _ = try factory.make(svg: expectedSvg, smoothDepth: expectedDepth)
        } catch {
            returnedError = error
        }

        // then
        XCTAssertEqual(reader.svg, expectedSvg)
        XCTAssertNotNil(returnedError)
        XCTAssertNil(simplifier.nodes)
        XCTAssertNil(smoother.parameters)
    }
}
