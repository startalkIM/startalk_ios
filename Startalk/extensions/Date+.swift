//
//  Date+.swift
//  Startalk
//
//  Created by lei on 2023/3/25.
//

import Foundation

extension Date{
    
    var milliseconds: Int64{
        Int64(timeIntervalSince1970 * 1000)
    }
    
    init(milliseconds: Int64){
        let timestamp = TimeInterval(milliseconds / 1000)
        self.init(timeIntervalSince1970: timestamp)
    }
}
