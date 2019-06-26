import Foundation
import UIKit

struct Story: Codable, Equatable {
    let title: String
    let cover: Item?
    let author: User
    let createdAt: Date
    var sections: [Section]

    struct Section: Codable, Equatable {
        let internId = UUID().uuidString
        let objectId: String?
        let order: Int
        let title: String?
        let text: String?
        var type: SectionType
        var items: [Item]

        enum SectionType: String, Codable {
            case fullscreen
            case autolayout
        }
    }

    struct Item: Codable, Equatable {
        let objectId: String
        let fileUrl: URL?
        let width: CGFloat
        let height: CGFloat
        let fillRow: Bool?
    }
}
