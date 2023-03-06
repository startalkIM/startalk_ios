//
//  STNavigationManager.swift
//  Startalk
//
//  Created by lei on 2023/2/26.
//

import Foundation

class STNavigationManager{
    
    var locations: [STNavigationLocation] = [
        STNavigationLocation(id: 0, name: "uk", location: "https://www.baidu.com"),
        STNavigationLocation(id: 1, name: "cn", location: "https://cc.com"),
    ]
    var currentLocationIndex: Int? = 0
    
    var navigation: STNavigation = .default
    
    func addLocation(_ location: STNavigationLocation, completion: (Bool) -> Void){
        completion(true)
    }
    
    func updateLocation(_ location: STNavigationLocation, completion: (Bool) -> Void){
        completion(true)
    }
    
    func removeLocation(at index: Int){
        print("removed", index)
        
    }
    
    func setLocationIndex(_ index: Int){
        if 0 <= index && index < locations.count{
            currentLocationIndex = index
        }
    }
}

protocol STNavigationManagerDelegate{
    
    func locationsChanged(manager: STNavigationManager)
    
    func navigationChanged()
}

extension STNavigationManagerDelegate{
    
    func locationsChanged(manager: STNavigationManager){}
    
    func navigationChanged(){}
}
