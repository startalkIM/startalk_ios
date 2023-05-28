//
//  MessgeCellLayout.swift
//  Startalk
//
//  Created by lei on 2023/5/16.
//

import UIKit

protocol MessgeCellLayout{
    
    func layout(photoImageView: UIView, nameLabel: UIView, contentsView: UIView, contentView: UIView, stateView: MessageStateView)
}
