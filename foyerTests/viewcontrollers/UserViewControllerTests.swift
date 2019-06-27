import SnapshotTesting
import XCTest
@testable import foyer

class UserViewControllerTests: XCTestCase {
    override func setUp() {
        Environment.reset()
    }

    func testUserViewController() {
        let vc = UserViewController(userName: "malte")
//        record = true
        assertSnapshot(matching: vc, as: .image)
    }
}
