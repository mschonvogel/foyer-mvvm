import UIKit

public class BalancedLayout: UICollectionViewFlowLayout
{
    private let kDecorationViewKind: String = "SectionBackgroundView"

    private var contentSize: CGSize = .zero

    // Frames
    private (set) var headerAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private (set) var footerAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private (set) var backgroundAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private (set) var cellAttributes = [IndexPath: UICollectionViewLayoutAttributes]()

    var storyCoverHeight: CGFloat = 0 {
        didSet {
            invalidateLayout()
        }
    }
    var preferredRowSize: CGFloat = 0 {
        didSet {
            invalidateLayout()
        }
    }

    var titleReferenceSize: CGSize = .zero
    var textReferenceSize: CGSize = .zero

    private var viewPortWidth: CGFloat {
        get {
            return self.collectionView!.frame.width - self.collectionView!.contentInset.left - self.collectionView!.contentInset.right
        }
    }

    private var viewPortAvailableSize: CGFloat {
        get {
            return self.viewPortWidth - self.sectionInset.left - self.sectionInset.right
        }
    }

    private weak var layoutDelegate: BalancedLayoutDelegate? {
        get {
            return self.collectionView!.delegate as? BalancedLayoutDelegate
        }
    }

    // MARK: Setup

    override init() {
        super.init()

        // Add SectionBackgroundView
        register(SectionBackgroundView.self, forDecorationViewOfKind: kDecorationViewKind)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // Add SectionBackgroundView
        register(SectionBackgroundView.self, forDecorationViewOfKind: kDecorationViewKind)
    }


    // MARK: Layout
    override public func prepare() {
        super.prepare()
        let numberOfSections = collectionView!.numberOfSections

        guard numberOfSections > 0 else { return }

        // Reset
        headerAttributes.removeAll()
        cellAttributes.removeAll()
        footerAttributes.removeAll()
        backgroundAttributes.removeAll()
        contentSize = .zero

        // Shortcut
        let viewWidth = collectionView!.bounds.width

        // Offset for StoryCover
        contentSize.height = storyCoverHeight

        print("prepare layout")
        for section in 0..<numberOfSections {
            let indexPath = IndexPath(item: 0, section: section)
            sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            if let sectionIsOfTypeFullWidth = self.layoutDelegate?.sectionIsOfTypeFullWidth(section: section) {
                if sectionIsOfTypeFullWidth {
                    sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
                }
            }

            // HeaderSize
            let headerSize = referenceSizeForHeaderInSection(section: section)
            let hLa = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: indexPath)
            hLa.frame = CGRect(x: 0, y: contentSize.height, width: viewWidth, height: headerSize.height)
            headerAttributes[indexPath] = hLa

            // SectionSize
            let sectionOffset = CGPoint(x: 0, y: contentSize.height + headerSize.height)
            let sectionSize = setFramesForItems(inSection: section, sectionOffset: sectionOffset)

            // FooterSize
            let footerSize = referenceSizeForFooterInSection(section: section)
            let fLa = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: indexPath)
            fLa.frame = CGRect(x: 0, y: contentSize.height + headerSize.height + sectionSize.height, width: viewWidth, height: footerSize.height)
            footerAttributes[indexPath] = fLa

            // BackgroundSize
            let bLa = UICollectionViewLayoutAttributes(forDecorationViewOfKind: kDecorationViewKind, with: indexPath)
            bLa.frame = CGRect(x: 0, y: contentSize.height, width: viewWidth, height: headerSize.height + sectionSize.height + footerSize.height)
            bLa.zIndex = -1
            backgroundAttributes[indexPath] = bLa

            // ContentSize
            contentSize = CGSize(width: sectionSize.width, height: contentSize.height + headerSize.height + sectionSize.height + footerSize.height)
        }
    }

    public override var collectionViewContentSize: CGSize {
        return contentSize
    }

    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var lA = [UICollectionViewLayoutAttributes]()

        guard let collectionView = collectionView else {
            assertionFailure("collectionView may not be nil!")
            return lA
        }

        for section in 0..<collectionView.numberOfSections {
            let sectionIndexPath = IndexPath(item: 0, section: section)

            // HeaderAttributes
            if let hA = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: sectionIndexPath), hA.frame.size != .zero && hA.frame.intersects(rect) {
                lA.append(hA)
            }

            // ItemAttributes
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                if let la = layoutAttributesForItem(at: IndexPath(item: item, section: section)), rect.intersects(la.frame) {
                    lA.append(la)
                }
            }

            // FooterAttributes
            if let fA = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: sectionIndexPath), fA.frame.size != .zero && fA.frame.intersects(rect) {
                lA.append(fA)
            }

            // BackgroundAttributes
            if let bA = layoutAttributesForDecorationView(ofKind: kDecorationViewKind, at: sectionIndexPath), bA.frame.size != .zero && bA.frame.intersects(rect) {
                lA.append(bA)
            }
        }

        return lA
    }

    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cellAttributes[indexPath]
    }

    override public func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            return headerAttributes[indexPath]
        case UICollectionView.elementKindSectionFooter:
            return footerAttributes[indexPath]
        default:
            return nil
        }
    }

    // Section Background
    override public func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return backgroundAttributes[indexPath]
    }

    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let oldBounds = collectionView!.bounds
        if newBounds.width != oldBounds.width || newBounds.height != oldBounds.height {
            return true
        }
        return false
    }

    public override func prepareForTransition(to newLayout: UICollectionViewLayout) {
        super.prepareForTransition(to: newLayout)
        prepare()
    }

    public override func prepareForTransition(from oldLayout: UICollectionViewLayout) {
        super.prepareForTransition(from: oldLayout)
        prepare()
    }

    private func numberOfRowsInPartOfSection(part: [Int]) -> Int {
        var totalItemSize: CGFloat = 0
        for n in part as [Int] {
            totalItemSize += CGFloat(n)/100*preferredRowSize
        }

        return max(lroundf(Float(totalItemSize / viewPortAvailableSize)), 1)
    }

    private func setFramesForItems(inSection section: Int, sectionOffset: CGPoint) -> CGSize {
        let weights = weightsForItemsInSection(section: section)
        var partition = [[Int]]()

        for item in weights {
            if item.count == 1 {
                partition.append(item)
            } else {
                partition += LinearPartition.linearPartitionForSequence(sequence: item, numberOfPartitions: numberOfRowsInPartOfSection(part: item))
            }
        }

        var i = 0
        var offset = CGPoint(x: sectionOffset.x + sectionInset.left, y: sectionOffset.y + sectionInset.top)
        var previousItemSize: CGFloat = 0
        var contentMaxValueInScrollDirection: CGFloat = 0

        for row in partition {
            var summedRatios: CGFloat = 0
            let rowSize: CGFloat = viewPortAvailableSize - (CGFloat(row.count - 1) * minimumInteritemSpacing)

            // Items in row
            for j in i..<(i + row.count) {
                let preferredSize = layoutDelegate!.collectionView(collectionView: collectionView!, layout: self, preferredSizeForItemAtIndexPath: IndexPath(item: j, section: section))
                summedRatios += preferredSize.width / preferredSize.height
            }

            for j in i..<(i + row.count) {
                let indexPath = IndexPath(item: j, section: section)
                let preferredSize = layoutDelegate!.collectionView(collectionView: collectionView!, layout: self, preferredSizeForItemAtIndexPath: indexPath)
                let actualSize = CGSize(
                    width: CGFloat(roundf(Float(rowSize/summedRatios)*Float(preferredSize.width/preferredSize.height))),
                    height: CGFloat(roundf(Float(rowSize / summedRatios)))
                )

                let frame = CGRect(x: offset.x, y: offset.y, width: actualSize.width, height: actualSize.height)
                let la = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                la.frame = frame
                cellAttributes[indexPath] = la

                offset.x += actualSize.width + minimumInteritemSpacing
                previousItemSize = actualSize.height
                contentMaxValueInScrollDirection = frame.maxY
            }


            // Check if row actually contains any items before changing offset,
            // because linear partitioning algorithm might return a row with no items.
            if row.count > 0 {
                offset = CGPoint(x: sectionInset.left, y: offset.y + previousItemSize + minimumLineSpacing);
            }

            i += row.count
        }

        var size = CGSize(width: viewPortWidth, height: sectionInset.bottom)
        if contentMaxValueInScrollDirection > 0 {
            size.height += contentMaxValueInScrollDirection - sectionOffset.y
        }

        return size
    }

    private func weightsForItemsInSection(section:Int) -> [[Int]] {
        var weights = [[Int]]()

        guard let collectionView = collectionView else {
            assertionFailure("collectionView may not be nil!")
            return weights
        }

        var previousFillRow = false
        for item in 0..<collectionView.numberOfItems(inSection: section) {
            let indexPath = IndexPath(item: item, section: section)

            let preferredSize = layoutDelegate!.collectionView(collectionView: collectionView, layout: self, preferredSizeForItemAtIndexPath: indexPath)
            let fillRow = layoutDelegate!.collectionView(collectionView: collectionView, layout: self, itemShouldFillRowAtIndexPath: indexPath)
            let aspectRatio: Int = lroundf(Float(preferredSize.width / preferredSize.height)*100)

            if item == 0 || fillRow || previousFillRow {
                weights.append([aspectRatio])
                previousFillRow = fillRow
            } else if weights.endIndex > 0 {
                weights[weights.endIndex-1].append(aspectRatio)
                previousFillRow = false
            }
        }

        return weights
    }

    // MARK: Delegate Helpers

    private func referenceSizeForHeaderInSection(section: Int) -> CGSize {
        if let headerSize = self.layoutDelegate?.collectionView?(collectionView!, layout: self, referenceSizeForHeaderInSection: section){
            return headerSize
        }
        return headerReferenceSize
    }

    private func referenceSizeForFooterInSection(section: Int) -> CGSize {
        if let footerSize = self.layoutDelegate?.collectionView?(collectionView!, layout: self, referenceSizeForFooterInSection: section){
            return footerSize
        }
        return footerReferenceSize
    }
}

@objc public protocol BalancedLayoutDelegate: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, preferredSizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, itemShouldFillRowAtIndexPath indexPath: IndexPath) -> Bool
    func sectionIsOfTypeFullWidth(section: Int) -> Bool
}

class SectionBackgroundView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct Matrix {
    let rows: Int
    let columns: Int
    var grid:[Int]

    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns

        grid = .init(repeating: 0, count: rows * columns)
    }

    func indexIsValidForRow(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }

    subscript(row: Int, column: Int) -> Int {
        get {
            assert(indexIsValidForRow(row: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValidForRow(row: row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
}

struct LinearPartition {
    static func linearPartitionForSequence(sequence: [Int], numberOfPartitions: Int) -> [[Int]] {
        var n = sequence.count
        var k = numberOfPartitions

        assert(k > 0, "number of partitions must be larger than 0")

        if k > n {
            return sequence.map({
                (number: Int) -> [Int] in
                return [number]
            })
        }

        if n == 1 { return [sequence] }

        var solution = linearPartitionTableForSequence(sequence: sequence, numberOfPartitions: numberOfPartitions)

        k = k - 2;
        n = n - 1;

        var answer = [[Int]]()

        while k >= 0 {
            if (n < 1) {
                answer.insert([], at: 0)
            }
            else {
                var currentAnswer = [Int]()
                for i in (solution[n - 1, k] + 1)...n {
                    currentAnswer.append(sequence[i])
                }
                answer.insert(currentAnswer, at: 0)

                n = solution[n - 1 , k]
            }

            k -= 1
        }

        var currentAnswer = [Int]()
        for i in 0...n {
            currentAnswer.append(sequence[i])
        }

        answer.insert(currentAnswer, at: 0)

        return answer
    }

    private static func linearPartitionTableForSequence(sequence: [Int], numberOfPartitions: Int) -> Matrix {
        // TODO: should not recalculate n
        let n = sequence.count
        let k = numberOfPartitions

        var tempTable = Matrix(rows: n, columns: k)
        var solutionTable = Matrix(rows: n - 1, columns: k - 1)

        // fill table with initial values
        for i in 0..<n {
            let offset = i > 0 ? tempTable[i - 1, 0] : 0
            tempTable[i, 0] = sequence[i] + offset
        }

        for i in 0..<k {
            tempTable[0, i] = sequence[0]
        }

        // calculate the costs and fill the solution buffer
        for i in 1..<n {
            for j in 1..<k {
                var currentMin = 0
                var minX = Int.max

                for x in 0..<i {
                    let c1 = tempTable[x, j - 1]
                    let c2 = tempTable[i, 0] - tempTable[x, 0]
                    let cost = max(c1, c2)

                    if (x == 0 || cost < currentMin) {
                        currentMin = cost
                        minX = x
                    }
                }

                tempTable[i, j] = currentMin
                solutionTable[i - 1, j - 1] = minX
            }
        }

        return solutionTable
    }
}
