import XCTest
@testable import MSPeekCollectionViewDelegateImplementation_Example
@testable import MSPeekCollectionViewDelegateImplementation

class Tests: XCTestCase {
    
    var sut: MSPeekCollectionViewDelegateImplementation!
    var collectionView: UICollectionView!
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    override func setUp() {
        super.setUp()
        sut = MSPeekCollectionViewDelegateImplementation()
        collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewFlowLayout)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private func simulateVerticalScroll(distance: CGFloat) -> UnsafeMutablePointer<CGPoint> {
        sut.scrollViewWillBeginDragging(collectionView)
        let simulatedTargetContentOffset = UnsafeMutablePointer<CGPoint>.allocate(capacity: 1)
        simulatedTargetContentOffset.pointee = CGPoint(x: collectionView.contentOffset.x + distance, y: 0)
        sut.scrollViewWillEndDragging(collectionView, withVelocity: CGPoint.zero, targetContentOffset: simulatedTargetContentOffset)
        return simulatedTargetContentOffset
    }
    
    func test_minimumLineSpacing_ShouldBeEqualToCellSpacing() {
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 20)
        let expectedLineSpacing = sut.collectionView(collectionView, layout: collectionViewFlowLayout, minimumLineSpacingForSectionAt: 0)
        XCTAssertEqual(expectedLineSpacing, 20)
    }
    
    //Left and Right Insets should be equal to the cell spacing plus the cell peek width
    func test_LeftAndRightEdgeInsets_ShouldBeSetCorrectly() {
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 20, cellPeekWidth: 30)
        let expectedEdgeInsets = sut.collectionView(collectionView, layout: collectionViewFlowLayout, insetForSectionAt: 0)
        XCTAssertEqual(expectedEdgeInsets.left, 50)
        XCTAssertEqual(expectedEdgeInsets.right, 50)
    }
    
    func test_minimumInteritemSpacing_ShouldBe0() {
        let expectedSpacing = sut.collectionView(collectionView, layout: collectionViewFlowLayout, minimumInteritemSpacingForSectionAt: 0)
        XCTAssertEqual(expectedSpacing, 0)
    }
    //Item width should not become negative in edge case
    func test_sizeForItemAtIndexPath_collectionViewSizeLessThanArgs_ShouldReturnSizeCorrectly() {
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 20, cellPeekWidth: 30)
        let testIndexPath = IndexPath(row: 0, section: 0)
        let expectedSize = sut.collectionView(collectionView, layout: collectionViewFlowLayout, sizeForItemAt: testIndexPath)
        XCTAssertEqual(expectedSize.height, 0)
        XCTAssertEqual(expectedSize.width, 0)
    }
    
    //Item width should be collection view width minus double the cell spacing with the cell peek width because there's peeking and spacing on both sides
    func test_sizeForItemAtIndexPath_ShouldReturnSizeCorrectly() {
        collectionView.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 20, cellPeekWidth: 30)
        let testIndexPath = IndexPath(row: 0, section: 0)
        let expectedSize = sut.collectionView(collectionView, layout: collectionViewFlowLayout, sizeForItemAt: testIndexPath)
        XCTAssertEqual(expectedSize.height, 200)
        XCTAssertEqual(expectedSize.width, 220)
    }
    
    func test_ScrollViewWillEndDragging_ViewFrameIs0_ShouldNotCrash() {
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 20, cellPeekWidth: 20, scrollThreshold: 50)
        collectionView.contentOffset = CGPoint(x: 0, y: 0)
        sut.scrollViewWillBeginDragging(collectionView)
        let simulatedTargetContentOffset = UnsafeMutablePointer<CGPoint>.allocate(capacity: 1)
        simulatedTargetContentOffset.pointee = CGPoint(x: 0, y: 49)
        sut.scrollViewWillEndDragging(collectionView, withVelocity: CGPoint.zero, targetContentOffset: simulatedTargetContentOffset)
        XCTAssertEqual(simulatedTargetContentOffset.pointee.x, 0)
    }
    
    func test_ScrollViewWillEndDragging_ScrollLessThanThreshold_ShouldNotScrollToAdjacentItem() {
        let randomPosition: CGFloat = 260
        collectionView.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 20, cellPeekWidth: 20, scrollThreshold: 50)
        collectionView.contentOffset = CGPoint(x: randomPosition, y: 0)
        sut.scrollViewWillBeginDragging(collectionView)
        let simulatedTargetContentOffset = UnsafeMutablePointer<CGPoint>.allocate(capacity: 1)
        simulatedTargetContentOffset.pointee = CGPoint(x: randomPosition + 49, y: 0)
        sut.scrollViewWillEndDragging(collectionView, withVelocity: CGPoint.zero, targetContentOffset: simulatedTargetContentOffset)
        XCTAssertEqual(simulatedTargetContentOffset.pointee.x, randomPosition)
        
        simulatedTargetContentOffset.pointee = CGPoint(x: randomPosition - 49, y: 0)
        sut.scrollViewWillEndDragging(collectionView, withVelocity: CGPoint.zero, targetContentOffset: simulatedTargetContentOffset)
        XCTAssertEqual(simulatedTargetContentOffset.pointee.x, randomPosition)
    }
    
    func test_ScrollViewWillEndDragging_ScrollGreaterThanThreshold_DirectionRight_ShouldScrollToNextItem() {
        collectionView.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 20, cellPeekWidth: 20, scrollThreshold: 50)
        collectionView.contentOffset = CGPoint(x: 0, y: 0)
        sut.scrollViewWillBeginDragging(collectionView)
        let simulatedTargetContentOffset = simulateVerticalScroll(distance: 50)
        XCTAssertEqual(simulatedTargetContentOffset.pointee.x, 260)
    }
    
    func test_ScrollViewWillEndDragging_ScrollGreaterThanThreshold_DirectionLeft_ShouldScrollToPreviousItem() {
        collectionView.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 20, cellPeekWidth: 20, scrollThreshold: 50)
        collectionView.contentOffset = CGPoint(x: 260, y: 0)
        let simulatedTargetContentOffset = simulateVerticalScroll(distance: -210)
        XCTAssertEqual(simulatedTargetContentOffset.pointee.x, 0)
    }
    
    func test_ScrollDistanceIsLarge_ShouldScroll1ItemByDefault() {
        collectionView.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 20, cellPeekWidth: 20, scrollThreshold: 50)
        let simulatedTargetContentOffset = simulateVerticalScroll(distance: 500)
        XCTAssertEqual(simulatedTargetContentOffset.pointee.x, 260)
    }
    
}
