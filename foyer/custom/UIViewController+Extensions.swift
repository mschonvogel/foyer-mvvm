import UIKit
import RxViewController
import SnapKit

extension UIViewController {
    func displayMessage(_ message: String) {
        let vc = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        vc.addAction(.init(title: "OK", style: .cancel, handler: nil))

        present(vc, animated: true, completion: nil)
    }
}
