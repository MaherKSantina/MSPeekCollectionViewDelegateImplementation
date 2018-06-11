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

public class PeekCollectionViewDelegateImplementation: NSObject, UICollectionViewDelegateFlowLayout {
    
    private var itemWidth: CGFloat
    private var itemsCount: Int
    private var indexOfCellBeforeDragging: Int = 0
    private var currentScrollOffset: CGFloat = 0
    private var scrollThreshold: CGFloat
    
    private var currentScrollIndex: Int {
        return Int(round(currentScrollOffset/itemWidth))
    }
    
    init(itemWidth: CGFloat, itemsCount: Int) {
        self.itemWidth = itemWidth
        self.itemsCount = itemsCount
        self.scrollThreshold = itemWidth/4
    }
    
    convenience init(itemWidth: CGFloat, itemsCount: Int, scrollThreshold: CGFloat) {
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
}
