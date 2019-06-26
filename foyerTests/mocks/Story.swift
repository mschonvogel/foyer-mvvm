import Foundation
@testable import foyer

extension Story {
    static let mock = Story(
        title: "Test Story",
        cover: .mock,
        author: .mock,
        createdAt: .mock,
        sections: [.mock]
    )
}

extension Story.Item {
    static let mock = Story.Item(
        objectId: "AbCdEfG",
        fileUrl: URL(string: "https://google.com/logo.gif"),
        width: 120,
        height: 120,
        fillRow: false
    )
}

extension Story.Section {
    static let mock = Story.Section(
        objectId: "1234",
        order: 1,
        title: "Test Title",
        text: "Test Text",
        type: .autolayout,
        items: [.mock]
    )
}
