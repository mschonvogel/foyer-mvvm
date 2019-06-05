import Foundation

struct Story: Codable, Equatable {
    let title: String
    let cover: Item?
    let author: User
    let createdAt: Date

    struct Item: Codable, Equatable {
        let fileUrl: URL?
    }
}
