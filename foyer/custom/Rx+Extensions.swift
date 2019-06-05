import Foundation
import RxSwift
import RxCocoa

extension Observable {
    func mapConst<U>(_ value: U) -> Observable<U> {
        return self.map { _ in value }
    }
}

extension Reactive where Base: UICollectionView {
    var contentOffsetAndViewSize: Observable<(contentOffset: CGPoint, viewSize: CGSize)> {
        return self.contentOffset.map {
            (
                contentOffset: CGPoint(x: $0.x, y: $0.y + self.base.safeAreaInsets.top),
                viewSize: self.base.frame.size
            )
        }
    }
}
