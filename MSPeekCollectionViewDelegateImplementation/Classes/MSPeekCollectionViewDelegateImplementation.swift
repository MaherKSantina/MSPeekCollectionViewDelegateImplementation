//
//  PeekCollectionViewDelegateImplementation.swift
//  Ubicar
//
//  Created by Maher Santina on 1/5/18.
//  Copyright © 2018 Sentia. All rights reserved.
//

import UIKit

public class MSPeekCollectionViewDelegateImplementation: NSObject, UICollectionViewDelegateFlowLayout {
    
    private var itemWidth: CGFloat
    private var itemsCount: Int
    private var indexOfCellBeforeDragging: Int = 0
    private var currentScrollOffset: CGFloat = 0
    private var scrollThreshold: CGFloat
    
    private var currentScrollIndex: Int {
        return Int(round(currentScrollOffset/itemWidth))
    }
    
    public init(itemWidth: CGFloat, itemsCount: Int) {
        self.itemWidth = itemWidth
        self.itemsCount = itemsCount
        self.scrollThreshold = itemWidth/4
    }
    
    public convenience init(itemWidth: CGFloat, itemsCount: Int, scrollThreshold: CGFloat) {
        self.init(itemWidth: itemWidth, itemsCount: itemsCount)
        self.scrollThreshold = scrollThreshold
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let isLastItemAndScrollingForward = currentScrollIndex == itemsCount - 1 && velocity.x > 0.0
        let isFirstItemAndScrollingBackward = currentScrollIndex == 0 && velocity.x < 0.0
        
        if isLastItemAndScrollingForward || isFirstItemAndScrollingBackward {
            return
        }
        
        var indexOfNewPosition: Int = currentScrollIndex
        
        let isDisplacementGreaterThanThreshold = abs(targetContentOffset.pointee.x - currentScrollOffset) > scrollThreshold
        
        if isDisplacementGreaterThanThreshold {
            let displacementIsPositive = targetContentOffset.pointee.x - currentScrollOffset > 0
            let indexCoefficient = (displacementIsPositive ? 1 : -1)
            indexOfNewPosition = currentScrollIndex + (1 * indexCoefficient)
        }
        
        let indexOfNewPositionFloat = CGFloat(indexOfNewPosition)
        
        let destinationScrollOffsetX = indexOfNewPositionFloat * itemWidth
        
        targetContentOffset.pointee = CGPoint(x: destinationScrollOffsetX, y: 0)
        self.currentScrollOffset = destinationScrollOffsetX
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: collectionView.frame.size.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        let leftAndRightInsets = collectionView.frame.size.width - itemWidth
        let leftAndRightInsets: CGFloat = 0
        return UIEdgeInsets(top: 0, left: leftAndRightInsets, bottom: 0, right: leftAndRightInsets)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView.frame.size.width - itemWidth
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
