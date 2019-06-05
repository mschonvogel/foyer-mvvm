import Foundation

struct Validator {
    static func isEmailValid(_ email: String?) -> Bool {
        return email != nil && email!.contains("@")
    }

    static func isPasswordValid(_ password: String?) -> Bool {
        return password != nil && password!.count > 2
    }
}
