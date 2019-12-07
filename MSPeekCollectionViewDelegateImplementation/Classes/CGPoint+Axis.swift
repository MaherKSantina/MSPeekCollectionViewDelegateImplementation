//
//  CGPoint+Axis.swift
//  CustomCollectionViewLayout
//
//  Created by Maher Santina on 12/8/19.
//  Copyright © 2019 Maher Santina. All rights reserved.
//

import UIKit

extension CGPoint {
    func attribute(axis: Axis, scrollDirection: UICollectionView.ScrollDirection) -> CGFloat {
        switch (axis, scrollDirection) {
        case (.main, .horizontal), (.cross, .vertical):
            return x
        case (.main, .vertical), (.cross, .horizontal):
            return y
        default:
            assertionFailure("Not implemented")
            return 0
        }
    }
}
