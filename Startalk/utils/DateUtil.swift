//
//  DateUtil.swift
//  Startalk
//
//  Created by lei on 2023/3/9.
//

import Foundation

class DateUtil{
    
    static private let formatter = {
       let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    class func readable(_ date: Date) -> String{
        return formatter.string(from: date)
    }
}
