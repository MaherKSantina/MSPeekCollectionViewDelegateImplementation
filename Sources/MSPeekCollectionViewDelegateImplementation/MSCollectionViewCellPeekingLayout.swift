//
//  PeekingCollectionViewLayout.swift
//  CustomCollectionViewLayout
//
//  Created by Maher Santina on 12/6/19.
//  Copyright © 2019 Maher Santina. All rights reserved.
//

import Foundation
import UIKit

/// Defines a way to pass data to the peeking layout
public protocol MSCollectionViewCellPeekingLayoutDataSource: AnyObject {

    /// The peek length of the adjacent cells
    func cellPeekingLayoutPeekingLength(_ layout: MSCollectionViewCellPeekingLayout) -> CGFloat

    /// The spacing between cells
    func cellPeekingLayoutSpacingLength(_ layout: MSCollectionViewCellPeekingLayout) -> CGFloat

    /// Defines how many items need to be shown in each page
    func cellPeekingLayoutNumberOfItemsToShow(_ layout: MSCollectionViewCellPeekingLayout) -> Int
}

/// An implementation of a peeking behavior where 2 cells peek on the sindes
open class MSCollectionViewCellPeekingLayout: UICollectionViewLayout {

    public weak var dataSource: MSCollectionViewCellPeekingLayoutDataSource?

    open var scrollDirection: UICollectionView.ScrollDirection

    var boundsWidth: CGFloat {
        return collectionView?.bounds.width ?? 1
    }

    var boundsHeight: CGFloat {
        return collectionView?.bounds.height ?? 1
    }

    var numberOfItemsToShow: Int {
        return dataSource?.cellPeekingLayoutNumberOfItemsToShow(self) ?? 1
    }

    var numberOfItems: Int {
        return collectionView?.numberOfItems(inSection: 0) ?? 0
    }

    var peekingLength: CGFloat {
        return dataSource?.cellPeekingLayoutPeekingLength(self) ?? 0
    }

    var spacingLength: CGFloat {
        return dataSource?.cellPeekingLayoutSpacingLength(self) ?? 0
    }

    override open var collectionViewContentSize: CGSize {
        switch scrollDirection {
        case .horizontal:
            return CGSize(width: contentLength(axis: .main, allowNegativeValues: false), height: contentLength(axis: .cross, allowNegativeValues: false))
        case .vertical:
            return CGSize(width: contentLength(axis: .cross, allowNegativeValues: false), height: contentLength(axis: .main, allowNegativeValues: false))
        default:
            return .zero
        }
    }

    public init(scrollDirection: UICollectionView.ScrollDirection) {
        self.scrollDirection = scrollDirection
        super.init()
    }

    required public init?(coder: NSCoder) {
        self.scrollDirection = .horizontal
        super.init(coder: coder)
    }

    func bounds(axis: Axis) -> CGFloat {
        switch (axis, scrollDirection) {
        case (.main, .horizontal), (.cross, .vertical):
            return boundsWidth
        case (.cross, .horizontal), (.main, .vertical):
            return boundsHeight
        default:
            assertionFailure("Not implemented")
            return 0
        }
    }

    /// Returns length of item without peeking length
    func itemLength(axis: Axis) -> CGFloat {
        let spacings = spacingLength * CGFloat(numberOfItemsToShow + 1)
        let peekings = peekingLength * 2
        switch axis {
        case .main:
            return (bounds(axis: .main) - spacings - peekings) / CGFloat(numberOfItemsToShow)
        case .cross:
            return bounds(axis: .cross)
        }
    }

    func contentLength(axis: Axis, allowNegativeValues: Bool) -> CGFloat {
        let spacing = allowNegativeValues ? spacingLength * 2 : max(0, spacingLength * 2)
        switch axis {
        case .main:
            let length = itemLength(axis: .main)
            let offsets = spacing + peekingLength * 2 // One from the start and one at the end
            return (length * CGFloat(numberOfItems)) + (CGFloat(numberOfItems) * spacingLength) + offsets
        case .cross:
            return itemLength(axis: .cross)
        }
    }

    func frameForItem(index: Int) -> CGRect {
        let mainLength = itemLength(axis: .main)
        let crossLength = itemLength(axis: .cross)

        // Offset from the beginning
        let contentOffset = peekingLength + spacingLength
        let mainMin = CGFloat(index) * (mainLength + spacingLength) + contentOffset
        let crossMin = CGFloat(0)
        switch scrollDirection {
        case .horizontal:
            return CGRect(x: mainMin, y: crossMin, width: mainLength, height: crossLength)
        case .vertical:
            return CGRect(x: crossMin, y: mainMin, width: crossLength, height: mainLength)
        default:
            assertionFailure("Not implemented")
            return .zero
        }
    }

    public func startingPointForItem(index: Int) -> CGPoint {
        let safeIndex = max(0, min(index, numberOfItems))
        switch scrollDirection {
        case .horizontal:
            let x = frameForItem(index: safeIndex).minX - spacingLength - peekingLength
            return CGPoint(x: x, y: 0)
        case .vertical:
            let y = frameForItem(index: safeIndex).minY - spacingLength - peekingLength
            return CGPoint(x: 0, y: y)
        default:
            assertionFailure("Not implemented")
            return .zero
        }
    }

    public func indexForItemAtPoint(point: CGPoint) -> Int {
        // at 375 * 200, peeking = 20, spacing = 20, item length = 137.5
        // at index = 2, point is 315
        // at index = 4, point is 630
        // at index = 6, point is 945

        let pointOffset: CGFloat
        switch scrollDirection {
        case .horizontal:
            pointOffset = point.x
        case .vertical:
            pointOffset = point.y
        default:
            assertionFailure("Not implemented")
            return 0
        }

        let coefficent = pointOffset / (itemLength(axis: .main) + spacingLength)
        let finalCoefficent = Int(round(coefficent))

        return min(max(0, finalCoefficent), numberOfItems)
    }

    func getIndexPaths(rect: CGRect) -> [IndexPath] {
        return (0..<numberOfItems).map{ IndexPath(row: $0, section: 0) }.filter{ self.frameForItem(index: $0.row).intersects(rect) }
    }

    func getCollectionViewLayoutAttributes(index: Int) -> UICollectionViewLayoutAttributes {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: index, section: 0))
        attributes.frame = frameForItem(index: index)
        return attributes
    }

    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return getIndexPaths(rect: rect).map{ self.getCollectionViewLayoutAttributes(index: $0.row) }
    }

    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return getCollectionViewLayoutAttributes(index: indexPath.row)
    }
}
