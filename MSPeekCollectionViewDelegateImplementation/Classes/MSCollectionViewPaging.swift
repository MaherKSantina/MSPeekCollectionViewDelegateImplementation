//
//  MSCollectionViewPaging.swift
//  CustomCollectionViewLayout
//
//  Created by Maher Santina on 12/7/19.
//  Copyright © 2019 Maher Santina. All rights reserved.
//

import UIKit

/// Defines a way to pass data to the paging logic
public protocol MSCollectionViewPagingDataSource: AnyObject {

    /// Will be called whenever the pager needs the offset of a specific index
    func collectionViewPaging(_ collectionViewPaging: MSCollectionViewPaging, offsetForItemAtIndex index: Int) -> CGFloat

    /// Will be called whenever the pager needs an index at a specific offset
    func collectionViewPaging(_ collectionViewPaging: MSCollectionViewPaging, indexForItemAtOffset offset: CGFloat) -> Int

    /// The minimum velocity required to jump to the adjacent item
    func collectionViewPagingScrollThreshold(_ collectionViewPaging: MSCollectionViewPaging) -> CGFloat

    /// The minimum number of items to scroll
    func collectionViewPagingMinimumItemsToScroll(_ collectionViewPaging: MSCollectionViewPaging) -> Int?

    /// The maximum number of items to scroll
    func collectionViewPagingMaximumItemsToScroll(_ collectionViewPaging: MSCollectionViewPaging) -> Int?

    /// Returns whether a specific index exists in the collection items or not
    func collectionViewNumberOfItems(_ collectionViewPaging: MSCollectionViewPaging) -> Int
}

// Default arguments
extension MSCollectionViewPagingDataSource {
    public func collectionViewPagingScrollThreshold(_ collectionViewPaging: MSCollectionViewPaging) -> CGFloat {
        return 0.2
    }

    public func collectionViewPagingMinimumItemsToScroll(_ collectionViewPaging: MSCollectionViewPaging) -> Int? {
        return nil
    }

    public func collectionViewPagingMaximumItemsToScroll(_ collectionViewPaging: MSCollectionViewPaging) -> Int? {
        return nil
    }
}

public class MSCollectionViewPaging: NSObject {

    weak var dataSource: MSCollectionViewPagingDataSource?

    var currentContentOffset: CGFloat = 0

    var scrollThreshold: CGFloat {
        return dataSource?.collectionViewPagingScrollThreshold(self) ?? 0
    }

    var numberOfItems: Int {
        return dataSource?.collectionViewNumberOfItems(self) ?? 0
    }

    func setIndex(_ index: Int) {
        currentContentOffset = dataSource?.collectionViewPaging(self, offsetForItemAtIndex: index) ?? 0
    }

    func getNewTargetOffset(startingOffset: CGFloat, velocity: CGFloat, targetOffset: CGFloat) -> CGFloat {

        // Get the current index and target index based on the offset
        let currentIndex = dataSource?.collectionViewPaging(self, indexForItemAtOffset: startingOffset) ?? 0
        let targetIndex = dataSource?.collectionViewPaging(self, indexForItemAtOffset: targetOffset) ?? 0

        let imAtFistItemAndScrollingBack = currentIndex == 0 && velocity < 0
        let imAtLastItemAndScrollingForward = currentIndex == numberOfItems && velocity > 0

        guard !imAtFistItemAndScrollingBack && !imAtLastItemAndScrollingForward else { return startingOffset }

        let delta = targetIndex - currentIndex

        var offset: Int
        switch (currentIndex, targetIndex, abs(velocity)) {
            // If there was no change in indices but the velocity is higher than the threshold, move to adjacent cell
        case let (x, y, v) where x == y && v > scrollThreshold:
            offset = 1

            // Otherwise, get the differece between the target and the current indices
        default:
            offset = abs(delta)
        }

        /// If we've set a minimum number of items to scroll, enforce it
        if let minimumItemsToScroll = dataSource?.collectionViewPagingMinimumItemsToScroll(self), offset != 0 {
            offset = max(offset, minimumItemsToScroll)
        }

        /// If we've set a maximum number of items to scroll, enforce it
        if let maximumItemsToScroll = dataSource?.collectionViewPagingMaximumItemsToScroll(self) {
            offset = min(offset, maximumItemsToScroll)
        }

        // The final index is the current index ofsetted by the value and in the velocity direction
        var finalIndex = currentIndex + (offset * Sign(value: delta).multiplier)

        let indexExists = finalIndex < numberOfItems
        // Move to index only if it exists. This will solve issues when there are multiple items in the same page
        if !indexExists {
            finalIndex = currentIndex
        }

        return dataSource?.collectionViewPaging(self, offsetForItemAtIndex: finalIndex) ?? 0
    }

    public func collectionViewWillEndDragging(scrollDirection: UICollectionView.ScrollDirection, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        switch scrollDirection {
        case .horizontal:
            targetContentOffset.pointee = CGPoint(x: getNewTargetOffset(startingOffset: currentContentOffset, velocity: velocity.x, targetOffset: targetContentOffset.pointee.x), y: targetContentOffset.pointee.y)
            currentContentOffset = targetContentOffset.pointee.x
        case .vertical:
            targetContentOffset.pointee = CGPoint(x: targetContentOffset.pointee.x, y: getNewTargetOffset(startingOffset: currentContentOffset, velocity: velocity.y, targetOffset: targetContentOffset.pointee.y))
            currentContentOffset = targetContentOffset.pointee.y
        default:
            assertionFailure("Not Implemented")
        }
    }
}
