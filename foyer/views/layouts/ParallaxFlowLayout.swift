import UIKit

class ParallaxFlowLayout: UICollectionViewFlowLayout {
    var maxParallaxOffset: CGFloat = 30.0

    var headerHeight: CGFloat = 0 {
        didSet {
            self.invalidateLayout()
        }
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override class var layoutAttributesClass: AnyClass {
        return ParallaxLayoutAttributes.self
    }

    override var collectionViewContentSize: CGSize {
        var size = super.collectionViewContentSize
        size.height += headerHeight
        return size
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var rect = rect
        rect.origin.y -= headerHeight

        return super.layoutAttributesForElements(in: rect)?.map {
            let attr = $0.copy() as! ParallaxLayoutAttributes
            attr.frame.origin.y += headerHeight

            if attr.representedElementCategory == .cell {
                attr.parallaxOffset = parallaxOffsetForLayoutAttributes(layoutAttributes: attr)
            }

            return attr
        }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let la = super.layoutAttributesForItem(at: indexPath)?.copy() as? ParallaxLayoutAttributes else {
            return nil
        }

        la.parallaxOffset = parallaxOffsetForLayoutAttributes(layoutAttributes: la)
        la.frame.origin.y += headerHeight

        return la
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let la = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)?.copy() as? ParallaxLayoutAttributes else {
            return nil
        }
        la.frame.origin.y += headerHeight

        return la
    }

    func parallaxOffsetForLayoutAttributes(layoutAttributes: ParallaxLayoutAttributes?) -> CGPoint {
        guard let la = layoutAttributes else { return .zero }

        let bounds = collectionView?.bounds ?? .zero
        let boundsCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        let offsetFromCenter = CGPoint(x: boundsCenter.x - la.center.x, y: boundsCenter.y - la.center.y)
        let maxVerticalOffsetWhereCellIsStillVisible: CGFloat = (bounds.size.height / 2) + (la.size.height / 2)
        let scaleFactor: CGFloat = self.maxParallaxOffset / maxVerticalOffsetWhereCellIsStillVisible

        return CGPoint(x: 0, y: offsetFromCenter.y * scaleFactor)
    }
}

class ParallaxLayoutAttributes: UICollectionViewLayoutAttributes {
    var parallaxOffset: CGPoint = .zero

    override init() {
        super.init()
    }

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy: ParallaxLayoutAttributes = super.copy(with: zone) as! ParallaxLayoutAttributes
        copy.parallaxOffset = self.parallaxOffset

        return copy
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard
            let object = object as? ParallaxLayoutAttributes,
            object.parallaxOffset.equalTo(self.parallaxOffset) else { return false }

        return super.isEqual(object)
    }
}
