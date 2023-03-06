//
//  STNavigationManager.swift
//  Startalk
//
//  Created by lei on 2023/2/26.
//

import Foundation

class STNavigationManager{
    var domain: String{
        "startalk.im"
//        "qtalk"
    }
    
    func updateLocation(_ location: STNavigationLocation, type: STNavigationLocation.UpdateType, completion: (Bool) -> Void){
        completion(true)
    }
}
