//
//  UITableView+.swift
//  Startalk
//
//  Created by lei on 2023/3/31.
//

import UIKit

extension UIScrollView{
    
    func scrollsToBottom(animated: Bool){
        let width = contentSize.width
        let height = contentSize.height
        if height > 0{
            let rect = CGRect(x: 0, y: height - 1, width: width, height: 1)
            scrollRectToVisible(rect, animated: animated)
        }
    }
}
