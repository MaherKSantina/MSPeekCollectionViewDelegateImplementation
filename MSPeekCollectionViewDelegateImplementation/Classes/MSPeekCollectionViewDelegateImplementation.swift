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

@objc public protocol MSPeekImplementationDelegate: AnyObject {
    ///Will be called when the current active index has changed
    @objc optional func peekImplementation(_ peekImplementation: MSPeekCollectionViewDelegateImplementation, didChangeActiveIndexTo activeIndex: Int)
    ///Will be called when the user taps on a cell at a specific index path
    @objc optional func peekImplementation(_ peekImplementation: MSPeekCollectionViewDelegateImplementation, didSelectItemAt indexPath: IndexPath)
}

open class MSPeekCollectionViewDelegateImplementation: NSObject {
    
    public let cellPeekWidth: CGFloat
    public let cellSpacing: CGFloat
    public let scrollThreshold: CGFloat
    public let minimumItemsToScroll: Int
    public let maximumItemsToScroll: Int
    public let numberOfItemsToShow: Int
    public let scrollDirection: UICollectionView.ScrollDirection
    
    public weak var delegate: MSPeekImplementationDelegate?
    
    fileprivate var currentScrollOffset: CGPoint = CGPoint.zero
    
    fileprivate lazy var itemLength: (UIView) -> CGFloat = {
        view in
        var frameWidth: CGFloat = self.scrollDirection.length(for: view)
        //Get the total remaining width for the
        let allItemsWidth = (frameWidth
                //If we have 2 items, there will be 3 spacing and so on
                - (CGFloat(self.numberOfItemsToShow + 1) * (self.cellSpacing))
                //There's always 2 peeking cells even if there are multiple cells showing
                - 2 * (self.cellPeekWidth))
        //Divide the remaining space by the number of items to get each item's width
        let finalWidth = allItemsWidth / CGFloat(self.numberOfItemsToShow)
        return max(0, finalWidth)
    }
    
    public init(cellSpacing: CGFloat = 20, cellPeekWidth: CGFloat = 20, scrollThreshold: CGFloat = 50, minimumItemsToScroll: Int = 1, maximumItemsToScroll: Int = 1, numberOfItemsToShow: Int = 1, scrollDirection: UICollectionView.ScrollDirection = .horizontal) {
        self.cellSpacing = cellSpacing
        self.cellPeekWidth = cellPeekWidth
        self.scrollThreshold = scrollThreshold
        self.minimumItemsToScroll = minimumItemsToScroll
        self.maximumItemsToScroll = maximumItemsToScroll
        self.numberOfItemsToShow = numberOfItemsToShow
        self.scrollDirection = scrollDirection
    }
    
    open func scrollView(_ scrollView: UIScrollView, indexForItemAtContentOffset contentOffset: CGPoint) -> Int {
        let width = itemLength(scrollView) + cellSpacing
        guard width > 0 else {
            return 0
        }
        let offset = self.scrollDirection.value(for: contentOffset)
        let index = Int(round(offset/width))
        return index
    }
    
    open func scrollView(_ scrollView: UIScrollView, contentOffsetForItemAtIndex index: Int) -> CGFloat{
        return CGFloat(index) * (itemLength(scrollView) + cellSpacing)
    }
    
    fileprivate func getNumberOfItemsToScroll(scrollDistance: CGFloat, scrollWidth: CGFloat) -> Int {
        var coefficent = 0
        let safeScrollThreshold = max(scrollThreshold, 0.1)
        
        switch scrollDistance {
        case let x where abs(x/safeScrollThreshold) <= 1:
            coefficent = Int(scrollDistance/safeScrollThreshold)
        case let x where Int(abs(x/scrollWidth)) == 0:
            coefficent = max(-1, min(Int(scrollDistance/safeScrollThreshold), 1))
        default:
            coefficent = Int(scrollDistance/scrollWidth)
        }
        
        if coefficent > 0 {
            coefficent = max(minimumItemsToScroll, coefficent)
        } else if coefficent < 0 {
            coefficent = min(-minimumItemsToScroll, coefficent)
        }
        
        let finalCoefficent = max((-1) * maximumItemsToScroll, min(coefficent, maximumItemsToScroll))
        return finalCoefficent
    }
}

extension MSPeekCollectionViewDelegateImplementation: UICollectionViewDelegateFlowLayout {
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        //Unexpected behavior happens if the scrollview's length is 0
        guard scrollDirection.length(for: scrollView) > 0 else {
            return
        }
        //Save the initial content offset that the collection view was going to scroll to
        let defaultTargetContentOffset = targetContentOffset.pointee
        //Get the scroll distance by subtracting the default target content offset from the current position that the user scrolled from
        let currentScrollDistance = scrollDirection.value(for: defaultTargetContentOffset) -
            scrollDirection.value(for: currentScrollOffset)
        //Get the number of items to scroll
        let numberOfItemsToScroll = getNumberOfItemsToScroll(scrollDistance: currentScrollDistance, scrollWidth: itemLength(scrollView))
        
        //Get the destination index. numberOfItemsToScroll can be a negative number so the destination would be a previous cell
        let destinationItemIndex = self.scrollView(scrollView, indexForItemAtContentOffset: currentScrollOffset) + numberOfItemsToScroll
        //Get the contentOffset from the destination index
        let destinationItemOffset = self.scrollView(scrollView, contentOffsetForItemAtIndex: destinationItemIndex)
        
        let newTargetContentOffset = scrollDirection.point(for: destinationItemOffset, defaultPoint: defaultTargetContentOffset)
        
        //Set the target content offset. After doing this, the collection view will automatically animate to the target content offset
        targetContentOffset.pointee = newTargetContentOffset
        //Pass the active index to the delegate
        delegate?.peekImplementation?(self, didChangeActiveIndexTo: destinationItemIndex)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        currentScrollOffset = scrollView.contentOffset
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return scrollDirection.size(for: itemLength(collectionView), defaultSize: collectionView.frame.size)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = cellSpacing + cellPeekWidth
        return scrollDirection.edgeInsets(for: insets)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.peekImplementation?(self, didSelectItemAt: indexPath)
    }
    
    
}
