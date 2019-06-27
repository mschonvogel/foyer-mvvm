import Foundation
@testable import foyer

extension User {
    static let mock = User(
        userName: "Test-User-Name",
        firstName: "Test-First-Name",
        lastName: "Test-Last-Name",
        biography: "Test-Biography",
        avatarUrl: URL(string: "https://google.com/avatar.gif"),
        followersCount: 111,
        followingCount: 222,
        currentUserFollows: false,
        currentUserBlocks: false,
        stories: [.mock]
    )
    static let mockWithoutStories = User(
        userName: "Test-User-Name",
        firstName: "Test-First-Name",
        lastName: "Test-Last-Name",
        biography: "Test-Biography",
        avatarUrl: URL(string: "https://google.com/avatar.gif"),
        followersCount: 111,
        followingCount: 222,
        currentUserFollows: false,
        currentUserBlocks: false,
        stories: nil
    )
}

extension AppUser {
    static let mock = AppUser(
        userName: "Test-User-Name",
        firstName: "Test-First-Name",
        lastName: "Test-Last-Name",
        biography: "Test-Biography",
        avatarUrl: URL(string: "https://google.com/avatar.gif"),
        followersCount: 111,
        followingCount: 222,
        currentUserFollows: false,
        currentUserBlocks: false,
        stories: nil,
        avatarUploadUrl: nil,
        email: "test-user@test.com",
        token: "Secure-Token",
        tokenLifetime: 123123123,
        notificationSettings: [:]
    )
}
