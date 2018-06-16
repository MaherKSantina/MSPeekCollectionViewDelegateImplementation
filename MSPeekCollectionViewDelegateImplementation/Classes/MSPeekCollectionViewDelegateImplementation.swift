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
    
    private let cellPeekWidth: CGFloat
    private let cellSpacing: CGFloat
    private let scrollThreshold: CGFloat
    
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
    
    public init(cellSpacing: CGFloat = 20, cellPeekWidth: CGFloat = 20, scrollThreshold: CGFloat = 50) {
        self.cellSpacing = cellSpacing
        self.cellPeekWidth = cellPeekWidth
        self.scrollThreshold = scrollThreshold
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let target = targetContentOffset.pointee
        //Current scroll distance is the distance between where the user tapped and the destination for the scrolling (If the velocity is high, this might be of big magnitude)
        let currentScrollDistance = target.x - currentScrollOffset.x
        //Make the value an integer between -1 and 1 (Because we don't want to scroll more than one item at a time)
        let coefficent = Int(max(-1, min(currentScrollDistance/scrollThreshold, 1)))
        
        let adjacentItemIndex = currentItemIndex(scrollView) + coefficent
        let adjacentItemIndexFloat = CGFloat(adjacentItemIndex)
        let adjacentItemOffsetX = adjacentItemIndexFloat * (itemWidth(scrollView) + cellSpacing)
        
        targetContentOffset.pointee = CGPoint(x: adjacentItemOffsetX, y: target.y)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth(collectionView), height: collectionView.frame.size.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let leftAndRightInsets = cellSpacing + cellPeekWidth
        return UIEdgeInsets(top: 0, left: leftAndRightInsets, bottom: 0, right: leftAndRightInsets)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        currentScrollOffset = scrollView.contentOffset
    }
}
