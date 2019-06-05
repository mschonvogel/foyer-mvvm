import Foundation

protocol UserContract: Codable {
    var userName: String { get }
    var firstName: String { get }
    var lastName: String { get }
    var biography: String? { get }
    var avatarUrl: URL? { get }
    var followersCount: Int { get }
    var followingCount: Int { get }
    var currentUserFollows: Bool? { get }
    var currentUserBlocks: Bool? { get }
    var stories: [Story]? { get }
}

struct User: UserContract, Codable, Equatable {
    let userName: String
    let firstName: String
    let lastName: String
    let biography: String?
    let avatarUrl: URL?
    let followersCount: Int
    let followingCount: Int
    let currentUserFollows: Bool?
    let currentUserBlocks: Bool?
    let stories: [Story]?
}

struct AppUser: UserContract, Codable, Equatable {
    let userName: String
    let firstName: String
    let lastName: String
    let biography: String?
    let avatarUrl: URL?
    let followersCount: Int
    let followingCount: Int
    let currentUserFollows: Bool?
    let currentUserBlocks: Bool?
    let stories: [Story]?

    let avatarUploadUrl: URL?
    let email: String
    let token: String
    let tokenLifetime: Int
    let notificationSettings: [String:Bool]?
}
