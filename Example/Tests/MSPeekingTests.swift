//
//  MSPeekingTests.swift
//  MSPeekCollectionViewDelegateImplementation_Tests
//
//  Created by Maher Santina on 12/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import MSPeekCollectionViewDelegateImplementation
@testable import MSPeekCollectionViewDelegateImplementation_Example

class MSPeekingTests: XCTestCase {

    var sut: MSCollectionViewPeekingBehavior!
    var collectionView: UICollectionView!

    override func setUp() {

    }

    func setupWith(cellSpacing: CGFloat = 20, cellPeekWidth: CGFloat = 20) {
        sut = MSCollectionViewPeekingBehavior(cellSpacing: cellSpacing, cellPeekWidth: cellPeekWidth)
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 375, height: 200), collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.configureForPeekingBehavior(behavior: sut)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    private func simulateHorizontalScroll(distance: CGFloat, velocity: CGFloat) -> UnsafeMutablePointer<CGPoint> {
        collectionView.delegate?.scrollViewWillBeginDragging?(collectionView)
        let simulatedTargetContentOffset = UnsafeMutablePointer<CGPoint>.allocate(capacity: 1)
        simulatedTargetContentOffset.pointee = CGPoint(x: distance, y: 0)
        collectionView.delegate?.scrollViewWillEndDragging?(collectionView, withVelocity: CGPoint(x: velocity, y: 0), targetContentOffset: simulatedTargetContentOffset)
        return simulatedTargetContentOffset
    }

    func test_100PeekWidth_0CellSpacing() {
        setupWith(cellSpacing: 0, cellPeekWidth: 100)
        let target = simulateHorizontalScroll(distance: 10, velocity: 2)
        XCTAssertEqual(sut.layout.collectionViewContentSize.width, 900)
    }

    func test_0PeekWidth_0CellSpacing() {
        setupWith(cellSpacing: 0, cellPeekWidth: 0)
        let target = simulateHorizontalScroll(distance: 10, velocity: 2)
        print(target.pointee)
        XCTAssertEqual(sut.layout.collectionViewContentSize.width, 1500)
    }

    func test_0PeekWidth_100CellSpacing() {
        setupWith(cellSpacing: 100, cellPeekWidth: 0)
        let target = simulateHorizontalScroll(distance: 10, velocity: 2)
        print(target.pointee)
        XCTAssertEqual(sut.layout.collectionViewContentSize.width, 1500)
    }

}

extension MSPeekingTests: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let value =  (180 + CGFloat(indexPath.row)*20) / 255
        cell.contentView.backgroundColor = UIColor(red: value, green: value, blue: value, alpha: 1)
        return cell
    }
}

extension MSPeekingTests: UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        sut.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
}
