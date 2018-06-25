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

open class MSPeekCollectionViewDelegateImplementation: NSObject, UICollectionViewDelegateFlowLayout {
    
    private let cellPeekWidth: CGFloat
    private let cellSpacing: CGFloat
    private let scrollThreshold: CGFloat
    private let maximumItemsToScroll: Int
    
    private var currentScrollOffset: CGPoint = CGPoint(x: 0, y: 0)
    
    private lazy var itemWidth: (UIView) -> CGFloat = {
        view in
        return max(0, view.frame.size.width - 2 * (self.cellSpacing + self.cellPeekWidth))
    }
    
    private lazy var currentItemIndex: (UIView) -> Int = {
        view in
        guard self.itemWidth(view) > 0 else {
            return 0
        }
        return Int(round(self.currentScrollOffset.x/self.itemWidth(view)))
    }
    
    public init(cellSpacing: CGFloat = 20, cellPeekWidth: CGFloat = 20, scrollThreshold: CGFloat = 50, maximumItemsToScroll: Int = 1) {
        self.cellSpacing = cellSpacing
        self.cellPeekWidth = cellPeekWidth
        self.scrollThreshold = scrollThreshold
        self.maximumItemsToScroll = maximumItemsToScroll
    }
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView.frame.size.width > 0 else {
            return
        }
        let target = targetContentOffset.pointee
        //Current scroll distance is the distance between where the user tapped and the destination for the scrolling (If the velocity is high, this might be of big magnitude)
        let currentScrollDistance = target.x - currentScrollOffset.x
        let coefficient = calculateCoefficient(scrollDistance: currentScrollDistance, scrollWidth: itemWidth(scrollView))
        
        let adjacentItemIndex = currentItemIndex(scrollView) + coefficient
        let adjacentItemIndexFloat = CGFloat(adjacentItemIndex)
        let adjacentItemOffsetX = adjacentItemIndexFloat * (itemWidth(scrollView) + cellSpacing)
        
        targetContentOffset.pointee = CGPoint(x: adjacentItemOffsetX, y: target.y)
    }
    
    private func calculateCoefficient(scrollDistance: CGFloat, scrollWidth: CGFloat) -> Int {
        var coefficent = 0
        if abs(scrollDistance/scrollThreshold) <= 1 {
            coefficent = Int(scrollDistance/scrollThreshold)
        }
        else if Int(abs(scrollDistance/scrollWidth)) == 0 {
            coefficent = max(-1, min(Int(scrollDistance/scrollThreshold), 1))
        }
        else {
            coefficent = Int(scrollDistance/scrollWidth)
        }
        let finalCoefficent = max((-1) * maximumItemsToScroll, min(coefficent, maximumItemsToScroll))
        return finalCoefficent
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth(collectionView), height: collectionView.frame.size.height)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let leftAndRightInsets = cellSpacing + cellPeekWidth
        return UIEdgeInsets(top: 0, left: leftAndRightInsets, bottom: 0, right: leftAndRightInsets)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        currentScrollOffset = scrollView.contentOffset
    }
}
