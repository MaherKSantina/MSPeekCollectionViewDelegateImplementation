//
//  MSCollectionViewPeekingBehavior.swift
//  CustomCollectionViewLayout
//
//  Created by Maher Santina on 12/7/19.
//  Copyright © 2019 Maher Santina. All rights reserved.
//

import UIKit

extension UICollectionView {
    public func configureForPeekingBehavior(behavior: MSCollectionViewPeekingBehavior) {
        collectionViewLayout = behavior.layout
        decelerationRate = .fast
    }
}

/// Defines a peeking behavior for the collection view. This class will hold all logic and dependencies to make the paging work
public class MSCollectionViewPeekingBehavior {

    /// The collection view layout that allows cells to peek
    public var layout: MSCollectionViewCellPeekingLayout

    /// The scrolling paging behavior
    public var paging = MSCollectionViewPaging()

    /// The space between cells
    public var cellSpacing: CGFloat

    /// The peeking of the cells
    public var cellPeekWidth: CGFloat

    /// The minimum number of items that can be scrolled. Setting this value to nil will not add any constraints.
    ///
    /// This field is useful in cases where you have multiple items showing at the same time. Setting this value to the number of items to show will ensure that scrolling will always show a page with new items.
    public var minimumItemsToScroll: Int?

    /// The maximum number of items that can be scrolled. Setting this value to nil will not add any constraint
    ///
    /// The default implementation is to allow scrolling depending on the target page and the velocity.
    public var maximumItemsToScroll: Int?

    /// The number of items to be shown in each page
    public var numberOfItemsToShow: Int

    /// The direction of scrolling of the collection view
    public var scrollDirection: UICollectionView.ScrollDirection

    public var velocityThreshold: CGFloat

    /// Total number of items to be shown
    private var numberOfItems: Int {
        return layout.collectionView?.numberOfItems(inSection: 0) ?? 0
    }

    /// Returns the current index of the left most item
    public var currentIndex: Int {
        return paging.currentIndex
    }

    public init(cellSpacing: CGFloat = 20, cellPeekWidth: CGFloat = 20, minimumItemsToScroll: Int? = nil, maximumItemsToScroll: Int? = nil, numberOfItemsToShow: Int = 1, scrollDirection: UICollectionView.ScrollDirection = .horizontal, velocityThreshold: CGFloat = 0.2) {
        self.cellSpacing = cellSpacing
        self.cellPeekWidth = cellPeekWidth
        self.minimumItemsToScroll = minimumItemsToScroll
        self.maximumItemsToScroll = maximumItemsToScroll
        self.numberOfItemsToShow = numberOfItemsToShow
        self.scrollDirection = scrollDirection
        layout = MSCollectionViewCellPeekingLayout(scrollDirection: scrollDirection)
        self.velocityThreshold = velocityThreshold
        layout.dataSource = self
        paging.dataSource = self
    }

    /// Scrolls to an item at a specific index with or without animation
    public func scrollToItem(at index: Int, animated: Bool) {
        layout.collectionView?.setContentOffset(layout.startingPointForItem(index: index), animated: animated)
        paging.setIndex(index)
    }

    /// Required function to be called when the `scrollViewWillEndDragging` `UICollectionViewDelegate` function is called
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        paging.collectionViewWillEndDragging(scrollDirection: scrollDirection, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
}

extension MSCollectionViewPeekingBehavior: MSCollectionViewCellPeekingLayoutDataSource {
    public func cellPeekingLayoutPeekingLength(_ layout: MSCollectionViewCellPeekingLayout) -> CGFloat {
        return cellPeekWidth
    }

    public func cellPeekingLayoutSpacingLength(_ layout: MSCollectionViewCellPeekingLayout) -> CGFloat {
        return cellSpacing
    }

    public func cellPeekingLayoutNumberOfItemsToShow(_ layout: MSCollectionViewCellPeekingLayout) -> Int {
        return numberOfItemsToShow
    }
}

extension MSCollectionViewPeekingBehavior: MSCollectionViewPagingDataSource {
    public func collectionViewPagingVelocityThreshold(_ collectionViewPaging: MSCollectionViewPaging) -> CGFloat {
        return velocityThreshold
    }

    public func collectionViewNumberOfItems(_ collectionViewPaging: MSCollectionViewPaging) -> Int {
        return numberOfItems
    }

    public func collectionViewPaging(_ collectionViewPaging: MSCollectionViewPaging, offsetForItemAtIndex index: Int) -> CGFloat {
        return layout.startingPointForItem(index: index).attribute(axis: .main, scrollDirection: scrollDirection)
    }

    public func collectionViewPaging(_ collectionViewPaging: MSCollectionViewPaging, indexForItemAtOffset offset: CGFloat) -> Int {
        let safeOffset = min(max(0, offset), layout.contentLength(axis: .main, allowNegativeValues: true))
        let point: CGPoint
        switch (scrollDirection) {
        case .horizontal:
            point = CGPoint(x: safeOffset, y: 0)
        case .vertical:
            point = CGPoint(x: 0, y: safeOffset)
        default:
            assertionFailure("Not implemented")
            return .zero
        }
        return layout.indexForItemAtPoint(point: point)
    }

    public func collectionViewPagingMinimumItemsToScroll(_ collectionViewPaging: MSCollectionViewPaging) -> Int? {
        return minimumItemsToScroll
    }

    public func collectionViewPagingMaximumItemsToScroll(_ collectionViewPaging: MSCollectionViewPaging) -> Int? {
        return maximumItemsToScroll
    }
}
