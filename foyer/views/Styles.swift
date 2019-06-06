import UIKit
import SnapKit

func <> <A: AnyObject>(f: @escaping (A) -> Void, g: @escaping (A) -> Void) -> (A) -> Void {
    return { a in
        f(a)
        g(a)
    }
}

// base

func aspectRatioStyle(size: CGSize) -> (UIView) -> Void {
    return {
        $0.widthAnchor
            .constraint(equalTo: $0.heightAnchor, multiplier: size.width / size.height)
            .isActive = true
    }
}

func borderStyle(color: UIColor, width: CGFloat) -> (UIView) -> Void {
    return {
        $0.layer.borderColor = color.cgColor
        $0.layer.borderWidth = width
    }
}

func implicitAspectRatioStyle(_ view: UIView) -> Void {
    aspectRatioStyle(size: view.frame.size)(view)
}

func roundedStyle(_ view: UIView) {
    view.clipsToBounds = true
    view.layer.cornerRadius = 6
}

// buttons
let baseButtonStyle: (UIButton) -> Void = {
    $0.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
}

let roundedButtonStyle =
    baseButtonStyle
        <> roundedStyle

let filledButtonStyle =
    roundedButtonStyle
        <> {
            $0.setBackgroundImage(UIImage(color: .blue), for: .normal)
            $0.setBackgroundImage(UIImage(color: .lightGray), for: .disabled)
            $0.tintColor = .white
}

let borderButtonStyle =
    roundedButtonStyle
        <> borderStyle(color: .black, width: 2)
        <> {
            $0.setTitleColor(.black, for: .normal)
}

let textButtonStyle =
    baseButtonStyle <> {
        $0.setTitleColor(.black, for: .normal)
}

let imageButtonStyle: (UIImage?) -> (UIButton) -> Void = { image in
    return {
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        $0.setImage(image, for: .normal)
    }
}

// text fields
let textFieldLabelStyle: (UILabel) -> Void = {
    $0.font = .preferredFont(forTextStyle: .caption1)
    $0.numberOfLines = 0
}
let baseTextFieldStyle: (UITextField) -> Void =
    roundedStyle
        <> borderStyle(color: UIColor(white: 0.75, alpha: 1), width: 2)
        <> { (tf: UITextField) in
            tf.borderStyle = .roundedRect
            tf.snp.makeConstraints { $0.height.equalTo(44) }
}

let emailTextFieldStyle =
    baseTextFieldStyle
        <> {
            $0.keyboardType = .emailAddress
            $0.autocorrectionType = .no
            $0.autocapitalizationType = .none
            $0.placeholder = "info@foyer.co"
}

let passwordTextFieldStyle =
    baseTextFieldStyle
        <> {
            $0.isSecureTextEntry = true
            $0.placeholder = "••••••••••••••••"
}

// labels
func fontStyle(ofSize size: CGFloat, weight: UIFont.Weight) -> (UILabel) -> Void {
    return {
        $0.font = .systemFont(ofSize: size, weight: weight)
    }
}

func textColorStyle(_ color: UIColor) -> (UILabel) -> Void {
    return {
        $0.textColor = color
    }
}

let centerStyle: (UILabel) -> Void = {
    $0.textAlignment = .center
}

// hyper-local
let orLabelStyle: (UILabel) -> Void =
    centerStyle
        <> fontStyle(ofSize: 14, weight: .medium)
        <> textColorStyle(UIColor(white: 0.625, alpha: 1))

let finePrintStyle: (UILabel) -> Void =
    centerStyle
        <> fontStyle(ofSize: 14, weight: .medium)
        <> textColorStyle(UIColor(white: 0.5, alpha: 1))
        <> {
            $0.font = .systemFont(ofSize: 11, weight: .light)
            $0.numberOfLines = 0
}

// stack views
let rootStackViewStyle: (UIStackView) -> Void = {
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 32, left: 16, bottom: 32, right: 16)
    $0.spacing = 16
}
