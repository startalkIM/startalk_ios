//
//  FileCacher.swift
//  Startalk
//
//  Created by lei on 2023/3/11.
//

import Foundation

//TODO: implement cache functions
class FileCacher{
    static let shared: FileCacher = FileCacher()
    
    func get(_ url: URL) -> Data?{
        return nil
    }
    
    func set(_ url: URL, data: Data){
        
    }
}
