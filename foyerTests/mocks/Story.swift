import Foundation
@testable import foyer

extension Story {
    static let mock = Story(
        title: "Test Story",
        cover: .mock,
        author: .mock,
        createdAt: .mock
    )
}

extension Story.Item {
    static let mock = Story.Item(fileUrl: URL(string: "https://google.com/logo.gif")!)
}
