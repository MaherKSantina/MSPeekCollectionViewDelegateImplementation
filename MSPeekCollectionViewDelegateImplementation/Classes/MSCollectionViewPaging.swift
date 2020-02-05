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
    func collectionViewPagingVelocityThreshold(_ collectionViewPaging: MSCollectionViewPaging) -> CGFloat

    /// The minimum number of items to scroll
    func collectionViewPagingMinimumItemsToScroll(_ collectionViewPaging: MSCollectionViewPaging) -> Int?

    /// The maximum number of items to scroll
    func collectionViewPagingMaximumItemsToScroll(_ collectionViewPaging: MSCollectionViewPaging) -> Int?

    /// Returns whether a specific index exists in the collection items or not
    func collectionViewNumberOfItems(_ collectionViewPaging: MSCollectionViewPaging) -> Int
}

public class MSCollectionViewPaging: NSObject {

    weak var dataSource: MSCollectionViewPagingDataSource?

    var currentContentOffset: CGFloat = 0 {
        didSet {
            print("Current Content Offset: ", currentContentOffset)
        }
    }

    var velocityThreshold: CGFloat {
        return dataSource?.collectionViewPagingVelocityThreshold(self) ?? 0
    }

    var numberOfItems: Int {
        return dataSource?.collectionViewNumberOfItems(self) ?? 0
    }

    func setIndex(_ index: Int) {
        currentContentOffset = dataSource?.collectionViewPaging(self, offsetForItemAtIndex: index) ?? 0
    }

    func getNewTargetOffset(startingOffset: CGFloat, velocity: CGFloat, targetOffset: CGFloat) -> CGFloat {
//        print("Offsets: ", startingOffset, targetOffset, velocity)
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
        case let (x, y, v) where x == y && v > velocityThreshold:
            offset = 1

            // Otherwise, get the differece between the target and the current indices
        default:
            offset = abs(delta)
        }

//        print("Indices: ", currentIndex, targetIndex, offset)

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
        var newOffset: CGFloat
        switch scrollDirection {
        case .horizontal:
            newOffset = getNewTargetOffset(startingOffset: currentContentOffset, velocity: velocity.x, targetOffset: targetContentOffset.pointee.x)
            targetContentOffset.pointee = CGPoint(x: newOffset, y: targetContentOffset.pointee.y)
        case .vertical:
            newOffset = getNewTargetOffset(startingOffset: currentContentOffset, velocity: velocity.y, targetOffset: targetContentOffset.pointee.y)
            targetContentOffset.pointee = CGPoint(x: targetContentOffset.pointee.x, y: newOffset)
        default:
            assertionFailure("Not Implemented")
            newOffset = 0
        }
        currentContentOffset = newOffset
    }

    public func scrollViewWillBeginDragging(scrollDirection: UICollectionView.ScrollDirection, contentOffset: CGPoint) {
//        switch scrollDirection {
//        case .vertical:
//            currentContentOffset = contentOffset.y
//        case .horizontal:
//            currentContentOffset = contentOffset.x
//        }
    }
}
