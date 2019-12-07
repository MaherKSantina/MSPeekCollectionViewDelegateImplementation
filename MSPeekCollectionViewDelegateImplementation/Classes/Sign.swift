//
//  Sign.swift
//  CustomCollectionViewLayout
//
//  Created by Maher Santina on 12/8/19.
//  Copyright © 2019 Maher Santina. All rights reserved.
//

import UIKit

enum Sign {
    case positive
    case negative

    var multiplier: Int {
        switch self {
        case .positive:
            return 1
        case .negative:
            return -1
        }
    }
}

extension CGFloat {
    var sign: Sign {
        switch self {
        case let x where x < 0:
            return .negative
        default:
            return .positive
        }
    }
}
