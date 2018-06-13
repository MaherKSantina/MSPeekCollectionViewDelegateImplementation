//Copyright (c) 2018 maher.santina90@gmail.com <maher.santina90@gmail.com>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.


import UIKit

extension UICollectionView {
    public func configureForPeekingDelegate() {
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        let layout = self.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
    }
}

public class MSPeekCollectionViewDelegateImplementation: NSObject, UICollectionViewDelegateFlowLayout {
    
    private let itemsCount: Int
    private let cellPeekWidth: CGFloat
    private let cellSpacing: CGFloat
    private let scrollThreshold: CGFloat
    
    private var indexOfCellBeforeDragging: Int = 0
    private var currentScrollOffset: CGFloat = 0
    
    private lazy var finalWidthMap: (UICollectionView) -> CGFloat = {
        collectionView in
        return (collectionView.frame.size.width - self.itemWidth(collectionView))/2
    }
    
    private lazy var itemWidth: (UICollectionView) -> CGFloat = {
        collectionView in
        return collectionView.frame.size.width - 2 * (self.cellSpacing + self.cellPeekWidth)
    }
    
    private lazy var currentScrollIndex: (UICollectionView) -> Int = {
        collectionView in
        return Int(round(self.currentScrollOffset/self.itemWidth(collectionView)))
    }
    
    public init(itemsCount: Int, cellSpacing: CGFloat = 20, cellPeekWidth: CGFloat = 20, scrollThreshold: CGFloat = 150) {
        self.itemsCount = itemsCount
        self.cellSpacing = cellSpacing
        self.cellPeekWidth = cellPeekWidth
        self.scrollThreshold = scrollThreshold
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let collectionView = scrollView as? UICollectionView else {
            fatalError("Scroll View is not a Collection View")
        }
        let isLastItemAndScrollingForward = currentScrollIndex(collectionView) == itemsCount - 1 && velocity.x > 0.0
        let isFirstItemAndScrollingBackward = currentScrollIndex(collectionView) == 0 && velocity.x < 0.0
        
        if isLastItemAndScrollingForward || isFirstItemAndScrollingBackward {
            return
        }
        
        var indexOfNewPosition: Int = currentScrollIndex(collectionView)
        
        let isDisplacementGreaterThanThreshold = abs(targetContentOffset.pointee.x - currentScrollOffset) > scrollThreshold
        
        if isDisplacementGreaterThanThreshold {
            let displacementIsPositive = targetContentOffset.pointee.x - currentScrollOffset > 0
            let indexCoefficient = (displacementIsPositive ? 1 : -1)
            indexOfNewPosition = currentScrollIndex(collectionView) + (1 * indexCoefficient)
        }
        
        let indexOfNewPositionFloat = CGFloat(indexOfNewPosition)
        
        let destinationScrollOffsetX = indexOfNewPositionFloat * (itemWidth(collectionView) + cellSpacing)
        
        targetContentOffset.pointee = CGPoint(x: destinationScrollOffsetX, y: 0)
        self.currentScrollOffset = destinationScrollOffsetX
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth(collectionView), height: collectionView.frame.size.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let leftAndRightInsets = finalWidthMap(collectionView)
        return UIEdgeInsets(top: 0, left: leftAndRightInsets, bottom: 0, right: leftAndRightInsets)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
}
