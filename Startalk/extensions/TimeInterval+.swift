//
//  TimeInterval+.swift
//  Startalk
//
//  Created by lei on 2023/3/20.
//

import Foundation

extension TimeInterval{
    
    var milliseconds: Int64{
        Int64(self * 1000)
    }
}
