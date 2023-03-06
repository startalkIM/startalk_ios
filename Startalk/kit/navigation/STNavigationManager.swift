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
    lazy var apiClient = STApiClient.shared
    
    var locations: [STNavigationLocation] = [
        STNavigationLocation(id: 0, name: "uk", value: "https://www.qtalk.app:8080/newapi/nck/qtalk_nav.qunar"),
        STNavigationLocation(id: 1, name: "cn", value: "https://i.startalk.im/newapi/nck/qtalk_nav.qunar?c=startalk.im"),
    ]
    var currentLocationIndex: Int?
    
    var navigation: STNavigation = .default
    
    var delegate: STNavigationManagerDelegate?
    
    init(){
        let locations = getLocations()
        if let locations = locations{
            self.locations = locations
        }
        
        if self.locations.isEmpty{
            currentLocationIndex = nil
        }else{
            currentLocationIndex = getCurrentIndex()
            if currentLocationIndex == nil{
                currentLocationIndex = 0
                setCurrentIndex(0)
            }
        }
        
        let navigation = getNavigation()
        if let navigation = navigation{
            self.navigation = navigation
        }
        
        fetchCurrentNavigation()
    }
    
    func getLocations() -> [STNavigationLocation]?{
        let array = defaults.array(forKey: Self.LOCATIONS_KEY)
        if let array = array{
            var locations: [STNavigationLocation] = []
            for object in array{
                if let data = object as? Data{
                    let location = try? decoder.decode(STNavigationLocation.self, from: data)
                    if let location = location{
                        locations.append(location)
                    }
                }
            }
            return locations
        }else{
            return nil
        }
    }
    
    func getCurrentIndex() -> Int?{
        return defaults.integer(forKey: Self.LOCATION_INDEX_KEY)
    }
    
    func getNavigation() -> STNavigation?{
        if let data = defaults.data(forKey: Self.NAVIGATION_KEY) {
            return try? decoder.decode(STNavigation.self, from: data)
        }
        return nil
    }
    
    func setLocations(_ locations: [STNavigationLocation]){
        self.locations = locations
        var array: [Data] = []
        for location in locations {
            let data = try! encoder.encode(location)
            array.append(data)
        }
        defaults.set(array, forKey: Self.LOCATIONS_KEY)
    }
    
    func setCurrentIndex(_ index: Int?){
        defaults.set(index, forKey: Self.LOCATION_INDEX_KEY)
    }
    
    func setNavigation(_ navigation: STNavigation){
        self.navigation = navigation
        let data = try! encoder.encode(navigation)
        defaults.set(data, forKey: Self.NAVIGATION_KEY)
    }
    
    func fetchCurrentNavigation(){
        if let index = currentLocationIndex{
            let location = locations[index]
            fetchNavigation(location: location.value) { [self] navigation in
                if let navigation = navigation{
                   setNavigation(navigation)
                }
            }
        }
    }
    
    func addLocation(_ location: STNavigationLocation, completion: @escaping (Bool) -> Void){
        var contains = false
        var maxId = 0
        for l in locations{
            if isEqual(location.value, l.value){
                contains = true
            }
            if maxId < l.id{
                maxId = l.id
            }
        }
        
        fetchNavigation(location: location.value) { [self] navigation in
            guard let navigation = navigation else{
                completion(false)
                return
            }
            if !contains{
                var location = location
                location.id = maxId + 1
                locations.insert(location, at: 0)
                currentLocationIndex = 0
            }else{
                for i in 0..<locations.count{
                    if isEqual(locations[i].value, location.value){
                        locations[i].name = location.name
                        locations[i].value = location.value
                        currentLocationIndex = i
                        break
                    }
                }
            }
            self.navigation = navigation
            
            setLocations(locations)
            setCurrentIndex(currentLocationIndex)
            setNavigation(navigation)
            
            apiClient.baseUrl = navigation.apiUrl
            delegate?.locationsChanged()
            completion(true)
        }
        
        
    }
    
    func updateLocation(_ location: STNavigationLocation, completion: @escaping (Bool) -> Void){
        for i in 0..<locations.count{
            if locations[i].id == location.id{
                fetchNavigation(location: location.value) { [self] navigation in
                    if let navigation = navigation{
                        locations[i].name = location.name
                        locations[i].value = location.value
                        setLocations(locations)
                        
                        if currentLocationIndex == i{
                            self.navigation = navigation
                            setNavigation(navigation)
                            apiClient.baseUrl = navigation.apiUrl
                        }
                        delegate?.locationsChanged()
                        completion(true)
                    }else{
                        completion(false)
                    }
                }
                break
            }
        }
    }
    
    func removeLocation(at index: Int){
        if 0 <= index && index < locations.count{
            if currentLocationIndex!  > index{
                currentLocationIndex = currentLocationIndex! - 1
            }else if currentLocationIndex! == index{
                currentLocationIndex = nil
            }
            locations.remove(at: index)
            
            if currentLocationIndex == nil{
                if locations.isEmpty{
                    navigation = .default
                    apiClient.baseUrl = navigation.apiUrl
                    setNavigation(navigation)
                }else{
                    currentLocationIndex = 0
                    let location = locations[0]
                    fetchNavigation(location: location.value) { navigation in
                        if let navigation = navigation{
                            self.navigation = navigation
                        }else{
                            self.navigation = .default
                        }
                        self.apiClient.baseUrl = self.navigation.apiUrl
                        self.setNavigation(self.navigation)
                    }
                }
                setCurrentIndex(currentLocationIndex)
            }
            
            setLocations(locations)
            delegate?.locationsChanged()
        }
        
    }
    
    func setLocationIndex(_ index: Int){
        if 0 <= index && index < locations.count{
            currentLocationIndex = index
            setCurrentIndex(currentLocationIndex)
            
            let location = locations[index]
            fetchNavigation(location: location.value) { navigation in
                if let navigation = navigation{
                    self.navigation = navigation
                    self.apiClient.baseUrl = navigation.apiUrl
                }
            }
        }
    }
    
    func queryLocation(_ value: String) -> STNavigationLocation?{
        for location in locations {
            if isEqual(value, location.value){
                return location
            }
        }
        return nil
    }
    
    func getLocationName() -> String{
        if let index = currentLocationIndex{
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
    
    private func isEqual(_ value1: String, _ value2: String) -> Bool{
        let url1 = URL(string: value1)
        let url2 = URL(string: value2)
        guard let url1 = url1, let url2 = url2 else{
            return false
        }
        if url1.scheme != url2.scheme{
            return false
        }
        if url1.host != url2.host{
            return false
        }
        let port1 = url1.port ?? 80
        let port2 = url2.port ?? 80
        if port1 != port2{
            return false
        }
        if url1.path != url2.path{
            return false
        }
        return true
    }
}

protocol STNavigationManagerDelegate{
    
    func locationsChanged()
    
}
