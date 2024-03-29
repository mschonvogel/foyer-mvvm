import UIKit
@testable import foyer

private class BundleLocator {}

extension UIImage {
    static let mock: UIImage = {
        return UIImage(named: "story.jpg", in: Bundle(for: BundleLocator.self), compatibleWith: nil)!
    }()
}
