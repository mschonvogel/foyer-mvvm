import Foundation
@testable import foyer

extension Activity {
    static let mock = Activity(
        createdAt: .mock,
        type: .new,
        author: .mockWithoutStories,
        story: .mock
    )
}
