import XCTest
@testable import MRefresh

class MRefreshTests: XCTestCase {
    
    private let reader = MRefresh.SVGReader()
    
    func testReadSimpleSVG() throws {
        let svg = "M100 100L200 200Z"
        let instructions = try reader.read(svg)
        
        XCTAssertFalse(instructions.isEmpty)
    }
}
