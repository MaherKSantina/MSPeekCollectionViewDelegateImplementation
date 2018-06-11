//
//  ViewController.swift
//  MSPeekCollectionViewDelegateImplementation
//
//  Created by maher.santina90@gmail.com on 06/11/2018.
//  Copyright (c) 2018 maher.santina90@gmail.com. All rights reserved.
//

import UIKit
import MSPeekCollectionViewDelegateImplementation

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var delegate: MSPeekCollectionViewDelegateImplementation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = MSPeekCollectionViewDelegateImplementation(itemWidth: 375, itemsCount: 4)
        collectionView.delegate = delegate
        collectionView.dataSource = self
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
    }

}

extension ViewController: UICollectionViewDataSource {
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

