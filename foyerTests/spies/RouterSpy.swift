import Foundation
import XCTest
@testable import foyer

class RouterSpy: RouterContract {
    private (set) var startCalled: [UITabBarController] = []
    func start(rootController: UITabBarController) {
        startCalled.append(rootController)
    }

    private (set) var presentLoginCalled: [()] = []
    func presentLogin() {
        presentLoginCalled.append(())
    }

    private (set) var presentFeedCalled: [()] = []
    func presentFeed() {
        presentFeedCalled.append(())
    }

    private (set) var presentStoryCalled: [Story] = []
    func presentStory(_ story: Story) {
        presentStoryCalled.append(story)
    }

    private (set) var presentDiscoverCalled: [()] = []
    func presentDiscover() {
        presentDiscoverCalled.append(())
    }

    private (set) var presentProfileCalled: [()] = []
    func presentProfile() {
        presentProfileCalled.append(())
    }

    private (set) var presentUserCalled: [String] = []
    func presentUser(_ userName: String) {
        presentUserCalled.append(userName)
    }

    private (set) var dismissCalled: [()] = []
    func dismiss() {
        dismissCalled.append(())
    }
}

extension RouterSpy {
    func assertEquals(
        startCalled: [UITabBarController],
        presentLoginCalled: [()],
        presentFeedCalled: [()],
        presentStoryCalled: [Story],
        presentDiscoverCalled: [()],
        presentProfileCalled: [()],
        dismissCalled: [()]
        ) {
        XCTAssertEqual(self.startCalled, startCalled)
        XCTAssertEqual(self.presentLoginCalled.count, presentLoginCalled.count)
        XCTAssertEqual(self.presentFeedCalled.count, presentFeedCalled.count)
        XCTAssertEqual(self.presentStoryCalled, presentStoryCalled)
        XCTAssertEqual(self.presentDiscoverCalled.count, presentDiscoverCalled.count)
        XCTAssertEqual(self.presentProfileCalled.count, presentProfileCalled.count)
        XCTAssertEqual(self.dismissCalled.count, dismissCalled.count)
    }
}
