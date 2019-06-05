import XCTest
@testable import MSPeekCollectionViewDelegateImplementation_Example
@testable import MSPeekCollectionViewDelegateImplementation

class VerticalScrollDirectionTests: XCTestCase {
    
    var sut: MSPeekCollectionViewDelegateImplementation!
    var collectionView: UICollectionView!
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    override func setUp() {
        super.setUp()
        sut = MSPeekCollectionViewDelegateImplementation(scrollDirection: .vertical)
        collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.dataSource = self
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private func simulateVerticalScroll(distance: CGFloat) -> UnsafeMutablePointer<CGPoint> {
        sut.scrollViewWillBeginDragging(collectionView)
        let simulatedTargetContentOffset = UnsafeMutablePointer<CGPoint>.allocate(capacity: 1)
        simulatedTargetContentOffset.pointee = CGPoint(x: 0, y: collectionView.contentOffset.y + distance)
        sut.scrollViewWillEndDragging(collectionView, withVelocity: CGPoint.zero, targetContentOffset: simulatedTargetContentOffset)
        return simulatedTargetContentOffset
    }
    
    func test_minimumLineSpacing_ShouldBeEqualToCellSpacing() {
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 20, scrollDirection: .vertical)
        let expectedLineSpacing = sut.collectionView(collectionView, layout: collectionViewFlowLayout, minimumLineSpacingForSectionAt: 0)
        XCTAssertEqual(expectedLineSpacing, 20)
    }
    
    //Left and Right Insets should be equal to the cell spacing plus the cell peek width
    func test_LeftAndRightEdgeInsets_ShouldBeSetCorrectly() {
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 20, cellPeekWidth: 30, scrollDirection: .vertical)
        let expectedEdgeInsets = sut.collectionView(collectionView, layout: collectionViewFlowLayout, insetForSectionAt: 0)
        XCTAssertEqual(expectedEdgeInsets.top, 50)
        XCTAssertEqual(expectedEdgeInsets.bottom, 50)
    }
    
    func test_minimumInteritemSpacing_ShouldBe0() {
        let expectedSpacing = sut.collectionView(collectionView, layout: collectionViewFlowLayout, minimumInteritemSpacingForSectionAt: 0)
        XCTAssertEqual(expectedSpacing, 0)
    }
    //Item width should not become negative in edge case
    func test_sizeForItemAtIndexPath_collectionViewSizeLessThanArgs_ShouldReturnSizeCorrectly() {
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 20, cellPeekWidth: 30, scrollDirection: .vertical)
        let testIndexPath = IndexPath(row: 0, section: 0)
        let expectedSize = sut.collectionView(collectionView, layout: collectionViewFlowLayout, sizeForItemAt: testIndexPath)
        XCTAssertEqual(expectedSize.height, 0)
        XCTAssertEqual(expectedSize.width, 0)
    }
    
    //Item width should be collection view width minus double the cell spacing with the cell peek width because there's peeking and spacing on both sides
    func test_sizeForItemAtIndexPath_ShouldReturnSizeCorrectly() {
        collectionView.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 20, cellPeekWidth: 30, scrollDirection: .vertical)
        let testIndexPath = IndexPath(row: 0, section: 0)
        let expectedSize = sut.collectionView(collectionView, layout: collectionViewFlowLayout, sizeForItemAt: testIndexPath)
        XCTAssertEqual(expectedSize.height, 100)
        XCTAssertEqual(expectedSize.width, 320)
    }
    
    func test_ScrollViewWillEndDragging_ViewFrameIs0_ShouldNotCrash() {
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 20, cellPeekWidth: 20, scrollThreshold: 50, scrollDirection: .vertical)
        collectionView.contentOffset = CGPoint(x: 0, y: 0)
        sut.scrollViewWillBeginDragging(collectionView)
        let simulatedTargetContentOffset = UnsafeMutablePointer<CGPoint>.allocate(capacity: 1)
        simulatedTargetContentOffset.pointee = CGPoint(x: 0, y: 49)
        sut.scrollViewWillEndDragging(collectionView, withVelocity: CGPoint.zero, targetContentOffset: simulatedTargetContentOffset)
        XCTAssertEqual(simulatedTargetContentOffset.pointee.x, 0)
    }
    
    func test_ScrollViewWillEndDragging_ScrollLessThanThreshold_ShouldNotScrollToAdjacentItem() {
        let initialPosition: CGFloat = 140
        collectionView.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 20, cellPeekWidth: 20, scrollThreshold: 50, scrollDirection: .vertical)
        collectionView.contentOffset = CGPoint(x: 0, y: initialPosition)
        sut.scrollViewWillBeginDragging(collectionView)
        let simulatedTargetContentOffset = UnsafeMutablePointer<CGPoint>.allocate(capacity: 1)
        simulatedTargetContentOffset.pointee = CGPoint(x: 0, y: initialPosition + 49)
        sut.scrollViewWillEndDragging(collectionView, withVelocity: CGPoint.zero, targetContentOffset: simulatedTargetContentOffset)
        XCTAssertEqual(simulatedTargetContentOffset.pointee.y, initialPosition)
        
        sut.scrollViewWillBeginDragging(collectionView)
        simulatedTargetContentOffset.pointee = CGPoint(x: 0, y: initialPosition - 49)
        sut.scrollViewWillEndDragging(collectionView, withVelocity: CGPoint.zero, targetContentOffset: simulatedTargetContentOffset)
        XCTAssertEqual(simulatedTargetContentOffset.pointee.y, initialPosition)
    }
    
    func test_ScrollViewWillEndDragging_ScrollGreaterThanThreshold_DirectionRight_ShouldScrollToNextItem() {
        collectionView.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 20, cellPeekWidth: 20, scrollThreshold: 50, scrollDirection: .vertical)
        collectionView.contentOffset = CGPoint(x: 0, y: 0)
        sut.scrollViewWillBeginDragging(collectionView)
        let simulatedTargetContentOffset = simulateVerticalScroll(distance: 50)
        XCTAssertEqual(simulatedTargetContentOffset.pointee.y, 140)
    }
    
    func test_ScrollViewWillEndDragging_ScrollGreaterThanThreshold_DirectionLeft_ShouldScrollToPreviousItem() {
        collectionView.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 20, cellPeekWidth: 20, scrollThreshold: 50, scrollDirection: .vertical)
        collectionView.contentOffset = CGPoint(x: 0, y: 140)
        let simulatedTargetContentOffset = simulateVerticalScroll(distance: -50)
        XCTAssertEqual(simulatedTargetContentOffset.pointee.y, 0)
    }
    
    func test_ScrollDistanceIsLarge_MaxIsDefault_ShouldScroll1ItemByDefault() {
        collectionView.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 20, cellPeekWidth: 20, scrollThreshold: 50, scrollDirection: .vertical)
        let simulatedTargetContentOffset = simulateVerticalScroll(distance: 500)
        XCTAssertEqual(simulatedTargetContentOffset.pointee.y, 140)
    }
    
    //The number of cells that will be scrolled depends on the distance scrolled and the max scroll items specified by the implementation
    func test_ScrollDistanceIsLarge_MaxIsSet_ShouldScrollProperly() {
        collectionView.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 20, cellPeekWidth: 20, scrollThreshold: 50, maximumItemsToScroll: 2, scrollDirection: .vertical)
        let simulatedTargetContentOffset = simulateVerticalScroll(distance: 320)
        XCTAssertEqual(simulatedTargetContentOffset.pointee.y, 280)
    }
    
    
    func test_MinimumItemsToScroll_ShouldScrollProperly() {
        collectionView.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 20, cellPeekWidth: 20, scrollThreshold: 50, minimumItemsToScroll: 2, maximumItemsToScroll: 4, scrollDirection: .vertical)
        let simulatedTargetContentOffset = simulateVerticalScroll(distance: 51)
        XCTAssertEqual(simulatedTargetContentOffset.pointee.y, 280)
    }
    
    func test_contentOffsetAtIndex_ShouldReturnCorrectOffset() {
        collectionView.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 20, cellPeekWidth: 20, scrollThreshold: 50, maximumItemsToScroll: 2, scrollDirection: .vertical)
        let offset = sut.scrollView(collectionView, contentOffsetForItemAtIndex: 0)
        XCTAssertEqual(offset, 0)
        let offset2 = sut.scrollView(collectionView, contentOffsetForItemAtIndex: 1)
        XCTAssertEqual(offset2, 140)
    }
    
    func test_indexForItemAtContentOffset_ShouldReturnCorrectIndex() {
        collectionView.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 0, cellPeekWidth: 0, scrollThreshold: 50, maximumItemsToScroll: 2, scrollDirection: .vertical)
        let offset = sut.scrollView(collectionView, indexForItemAtContentOffset: CGPoint(x: 0, y: 400))
        XCTAssertEqual(offset, 2)
        
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 20, cellPeekWidth: 20, scrollThreshold: 50, maximumItemsToScroll: 1, scrollDirection: .vertical)
        let offset2 = sut.scrollView(collectionView, indexForItemAtContentOffset: CGPoint(x: 0, y: 280))
        XCTAssertEqual(offset2, 2)
        
        sut = MSPeekCollectionViewDelegateImplementation(cellSpacing: 50, cellPeekWidth: 20, scrollThreshold: 50, maximumItemsToScroll: 1, scrollDirection: .vertical)
        let offset3 = sut.scrollView(collectionView, indexForItemAtContentOffset: CGPoint(x: 0, y: 220))
        XCTAssertEqual(offset3, 2)
    }
    
}

extension VerticalScrollDirectionTests: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        return cell
    }
}
