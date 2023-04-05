//
//  UITableView+.swift
//  Startalk
//
//  Created by lei on 2023/3/31.
//

import UIKit

extension UITableView{
    
    func scrollsToBottom(animated: Bool){
        if numberOfSections > 0{
            let lastSection = numberOfSections - 1
            let rows = numberOfRows(inSection: lastSection)
            let lastRow: Int
            if rows > 0 {
                lastRow = rows - 1
            }else{
                lastRow = NSNotFound
            }
            let indexPath = IndexPath(row: lastRow, section: lastSection)
            scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
}
