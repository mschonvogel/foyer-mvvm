import Foundation

struct LoginRequestPayload: Codable, Equatable {
    let email: String
    let password: String
}
