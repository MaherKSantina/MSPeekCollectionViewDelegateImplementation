import XCTest
@testable import MSPeekCollectionViewDelegateImplementation_Example
@testable import MSPeekCollectionViewDelegateImplementation

class Tests: XCTestCase {
    
    var sut: MSPeekCollectionViewDelegateImplementation!
    var collectionView: UICollectionView!
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    override func setUp() {
        super.setUp()
        sut = MSPeekCollectionViewDelegateImplementation(itemsCount: 4)
        collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewFlowLayout)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_minimumLineSpacing_ShouldBeEqualToCellSpacing() {
        sut = MSPeekCollectionViewDelegateImplementation(itemsCount: 4, cellSpacing: 20)
        let expectedLineSpacing = sut.collectionView(collectionView, layout: collectionViewFlowLayout, minimumLineSpacingForSectionAt: 0)
        XCTAssertEqual(expectedLineSpacing, 20)
    }
    
    //Left and Right Insets should be equal to the cell spacing plus the cell peek width
    func test_LeftAndRightEdgeInsets_ShouldBeSetCorrectly() {
        sut = MSPeekCollectionViewDelegateImplementation(itemsCount: 4, cellSpacing: 20, cellPeekWidth: 30)
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
        sut = MSPeekCollectionViewDelegateImplementation(itemsCount: 4, cellSpacing: 20, cellPeekWidth: 30)
        let testIndexPath = IndexPath(row: 0, section: 0)
        let expectedSize = sut.collectionView(collectionView, layout: collectionViewFlowLayout, sizeForItemAt: testIndexPath)
        XCTAssertEqual(expectedSize.height, 0)
        XCTAssertEqual(expectedSize.width, 0)
    }
    
    //Item width should be collection view width minus double the cell spacing with the cell peek width because there's peeking and spacing on both sides
    func test_sizeForItemAtIndexPath_collectionViewSizeGreaterThanArgs_ShouldReturnSizeCorrectly() {
        collectionView.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        sut = MSPeekCollectionViewDelegateImplementation(itemsCount: 4, cellSpacing: 20, cellPeekWidth: 30)
        let testIndexPath = IndexPath(row: 0, section: 0)
        let expectedSize = sut.collectionView(collectionView, layout: collectionViewFlowLayout, sizeForItemAt: testIndexPath)
        XCTAssertEqual(expectedSize.height, 200)
        XCTAssertEqual(expectedSize.width, 220)
    }
    
}
