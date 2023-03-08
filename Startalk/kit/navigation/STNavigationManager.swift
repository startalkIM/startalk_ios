//
//  STNavigationManager.swift
//  Startalk
//
//  Created by lei on 2023/2/26.
//

import Foundation

class STNavigationManager{
    private static let LOCATIONS_KEY = "navigation_locations"
    private static let LOCATION_INDEX_KEY = "navigation_location_index"
    private static let NAVIGATION_KEY = "navigation"
    
    let defaults = UserDefaults.standard
    let encoder = PropertyListEncoder()
    let decoder = PropertyListDecoder()
    let httpClient = STHttpClient()
    
    var locations: [STNavigationLocation] = [
        STNavigationLocation(id: 0, name: "uk", value: "https://www.qtalk.app:8080/newapi/nck/qtalk_nav.qunar"),
        STNavigationLocation(id: 1, name: "cn", value: "https://i.startalk.im/newapi/nck/qtalk_nav.qunar?c=startalk.im"),
    ]
    private var locationIndex: Int = 0
    
    var navigation: STNavigation = .default
    
    var delegate: STNavigationManagerDelegate?
    
    init(){
        let locations = pickLocations()
        if let locations = locations{
            self.locations = locations
        }
        
        let index = pickCurrentIndex()
        if let index = index{
            locationIndex = index
        }
        
        let navigation = pickNavigation()
        if let navigation = navigation{
            self.navigation = navigation
        }
        
        if let index = getLocationIndex(){
            reloadNavigation(location: self.locations[index])
        }
    }
    
    func getLocationIndex() -> Int?{
        if locations.isEmpty{
            return nil
        }else{
            return locationIndex
        }
    }
    
    func reloadNavigation(location: STNavigationLocation){
        fetchNavigation(location: location.value) { [self] navigation in
            if let navigation = navigation{
               setAndStoreNavigation(navigation)
            }
        }
    }
    
    func addLocation(_ location: STNavigationLocation, completion: @escaping (Bool) -> Void){
        var index: Int? = nil
        var maxId = 0
        for i in 0..<locations.count{
            if URLUtil.equals(location.value, locations[i].value){
                index = i
            }
            if maxId < locations[i].id{
                maxId = locations[i].id
            }
        }
        
        fetchNavigation(location: location.value) { [self] navigation in
            guard let navigation = navigation else{
                completion(false)
                return
            }
            setAndStoreNavigation(navigation)
            
            if let index = index{
                locations[index].name = location.name
                locations[index].value = location.value
                locationIndex = index
            }else{
                var location = location
                location.id = maxId + 1
                locations.insert(location, at: 0)
                locationIndex = 0
            }
            storeLocations(locations)
            storeCurrentIndex(locationIndex)
                        
            delegate?.locationsChanged()
            completion(true)
        }
        
        
    }
    
    func updateLocation(_ location: STNavigationLocation, completion: @escaping (Bool) -> Void){
        for i in 0..<locations.count{
            if locations[i].id == location.id{
                fetchNavigation(location: location.value) { [self] navigation in
                    guard let navigation = navigation else{
                        completion(false)
                        return
                    }
                    locations[i].name = location.name
                    locations[i].value = location.value
                    storeLocations(locations)
                    
                    if locationIndex == i{
                       setAndStoreNavigation(navigation)
                    }
                    delegate?.locationsChanged()
                    completion(true)
                }
                break
            }
        }
    }
    
    func removeLocation(at index: Int){
        if (0..<locations.count).contains(index){
            
            locations.remove(at: index)
            storeLocations(locations)
            delegate?.locationsChanged()
            
            if index < locationIndex{
                locationIndex = locationIndex - 1
                storeCurrentIndex(locationIndex)
            }else if index == locationIndex{
                setAndStoreIndex(0)
                
                setAndStoreNavigation(.default)
                if let index = getLocationIndex(){
                    reloadNavigation(location: locations[index])
                }
            }
        }
        
    }
    
    func changeLocationIndex(to index: Int){
        if (0..<locations.count).contains(index){
            setAndStoreIndex(index)
            
            let location = locations[index]
            reloadNavigation(location: location)
        }
    }
    
    func queryLocation(_ value: String) -> STNavigationLocation?{
        for location in locations {
            if URLUtil.equals(value, location.value){
                return location
            }
        }
        return nil
    }
    
    func getLocationName() -> String{
        if let index = getLocationIndex(){
            let location = locations[index]
            return location.name
        }else{
            return navigation.domain
        }
    }
    
    private func fetchNavigation(location: String, completion: @escaping (STNavigation?) -> Void){
        let url = URL(string: location)
        guard let url = url else {
            completion(nil)
            return
        }
        httpClient.request(url) { (response: STNavigation?, error: Error?) -> Void in
            if error != nil{
                completion(nil)
                return
            }
            guard let response = response else{
                completion(nil)
                return
            }
            completion(response)
        }
    }
}

extension STNavigationManager{
    
    private func pickLocations() -> [STNavigationLocation]?{
        let data = defaults.data(forKey: Self.LOCATIONS_KEY)
        if let data = data{
            return try? decoder.decode([STNavigationLocation].self, from: data)
        }else{
            return nil
        }
    }
    
    private func pickCurrentIndex() -> Int?{
        return defaults.integer(forKey: Self.LOCATION_INDEX_KEY)
    }
    
    private func pickNavigation() -> STNavigation?{
        if let data = defaults.data(forKey: Self.NAVIGATION_KEY) {
            return try? decoder.decode(STNavigation.self, from: data)
        }else{
            return nil
        }
    }
    
    private func storeLocations(_ locations: [STNavigationLocation]){
        let data = try! encoder.encode(locations)
        defaults.set(data, forKey: Self.LOCATIONS_KEY)
    }
    
    private func storeCurrentIndex(_ index: Int){
        defaults.set(index, forKey: Self.LOCATION_INDEX_KEY)
    }
    
    private func storeNavigation(_ navigation: STNavigation){
        let data = try! encoder.encode(navigation)
        defaults.set(data, forKey: Self.NAVIGATION_KEY)
    }
    
    private func setAndStoreIndex(_ index: Int){
        self.locationIndex = index
        storeCurrentIndex(index)
    }
    
    private func setAndStoreNavigation(_ navigation: STNavigation){
        self.navigation = navigation
        storeNavigation(navigation)
    }
}

protocol STNavigationManagerDelegate{
    
    func locationsChanged()
    
}
