import Foundation

struct Activity: Codable, Equatable {

    let createdAt: Date
    let type: Activity.`Type`
    let author: User
    let story: Story

    enum `Type`: String, Codable {
        case shared
        case new
    }
}
