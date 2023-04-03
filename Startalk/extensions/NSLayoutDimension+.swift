//
//  NSLayoutDimension+.swift
//  Startalk
//
//  Created by lei on 2023/4/3.
//

import UIKit

extension NSLayoutDimension{
    
    func constraint(equalToConstant c: CGFloat, priority: UILayoutPriority) -> NSLayoutConstraint{
        let constraint = constraint(equalToConstant: c)
        constraint.priority = priority
        return constraint
    }
    
}
