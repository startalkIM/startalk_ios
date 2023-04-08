//
//  STServiceManager.swift
//  Startalk
//
//  Created by lei on 2023/2/26.
//

import Foundation

class STServiceManager{
    private static let SERVICES_KEY = "services"
    private static let SERVICE_INDEX_KEY = "service_index"
    private static let NAVIGATION_KEY = "service_navigation"
    
    let defaults = UserDefaults.standard
    let encoder = PropertyListEncoder()
    let decoder = PropertyListDecoder()
    let httpClient = STHttpClient()
    
    var services: [STService] = [
        STService(id: 0, name: "uk", location: "https://www.qtalk.app:8080/newapi/nck/qtalk_nav.qunar"),
        STService(id: 1, name: "cn", location: "https://i.startalk.im/newapi/nck/qtalk_nav.qunar?c=startalk.im"),
    ]
    private var serviceIndex: Int = 0
    
    var navigation: STServiceNavigation = .default
    
    var delegate: STServiceManagerDelegate?
    
    init(){
        let services = pickServices()
        if let services = services{
            self.services = services
        }
        
        let index = pickCurrentIndex()
        if let index = index{
            serviceIndex = index
        }
        
        let navigation = pickNavigation()
        if let navigation = navigation{
            self.navigation = navigation
        }
        
        if let index = getServiceIndex(){
            reloadNavigation(service: self.services[index])
        }
    }
    
    func getServiceIndex() -> Int?{
        if services.isEmpty{
            return nil
        }else{
            return serviceIndex
        }
    }
    
    func reloadNavigation(service: STService){
        fetchNavigation(location: service.location) { [self] navigation in
            if let navigation = navigation{
               setAndStoreNavigation(navigation)
            }
        }
    }
    
    func addService(_ service: STService, completion: @escaping (Bool) -> Void){
        var index: Int? = nil
        var maxId = 0
        for i in 0..<services.count{
            if URLUtil.equals(service.location, services[i].location){
                index = i
            }
            if maxId < services[i].id{
                maxId = services[i].id
            }
        }
        
        fetchNavigation(location: service.location) { [self] navigation in
            guard let navigation = navigation else{
                completion(false)
                return
            }
            setAndStoreNavigation(navigation)
            
            if let index = index{
                services[index].name = service.name
                services[index].location = service.location
                serviceIndex = index
            }else{
                var service = service
                service.id = maxId + 1
                services.insert(service, at: 0)
                serviceIndex = 0
            }
            storeServices(services)
            storeCurrentIndex(serviceIndex)
                        
            delegate?.servicesChanged()
            completion(true)
        }
        
        
    }
    
    func updateService(_ service: STService, completion: @escaping (Bool) -> Void){
        for i in 0..<services.count{
            if services[i].id == service.id{
                fetchNavigation(location: service.location) { [self] navigation in
                    guard let navigation = navigation else{
                        completion(false)
                        return
                    }
                    services[i].name = service.name
                    services[i].location = service.location
                    storeServices(services)
                    
                    if serviceIndex == i{
                       setAndStoreNavigation(navigation)
                    }
                    delegate?.servicesChanged()
                    completion(true)
                }
                break
            }
        }
    }
    
    func removeService(at index: Int){
        if (0..<services.count).contains(index){
            
            services.remove(at: index)
            storeServices(services)
            delegate?.servicesChanged()
            
            if index < serviceIndex{
                serviceIndex = serviceIndex - 1
                storeCurrentIndex(serviceIndex)
            }else if index == serviceIndex{
                setAndStoreIndex(0)
                
                setAndStoreNavigation(.default)
                if let index = getServiceIndex(){
                    reloadNavigation(service: services[index])
                }
            }
        }
        
    }
    
    func changeServiceIndex(to index: Int){
        if (0..<services.count).contains(index){
            setAndStoreIndex(index)
            
            let location = services[index]
            reloadNavigation(service: location)
        }
    }
    
    func queryService(_ location: String) -> STService?{
        for service in services {
            if URLUtil.equals(location, service.location){
                return service
            }
        }
        return nil
    }
    
    func getServiceName() -> String{
        if let index = getServiceIndex(){
            let servcie = services[index]
            return servcie.name
        }else{
            return navigation.domain
        }
    }
    
    private func fetchNavigation(location: String, completion: @escaping (STServiceNavigation?) -> Void){
        let url = URL(string: location)
        guard let url = url else {
            completion(nil)
            return
        }
        httpClient.request(url) { (response: STServiceNavigation?, error: Error?) -> Void in
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

extension STServiceManager{
    
    private func pickServices() -> [STService]?{
        let data = defaults.data(forKey: Self.SERVICES_KEY)
        if let data = data{
            return try? decoder.decode([STService].self, from: data)
        }else{
            return nil
        }
    }
    
    private func pickCurrentIndex() -> Int?{
        return defaults.integer(forKey: Self.SERVICE_INDEX_KEY)
    }
    
    private func pickNavigation() -> STServiceNavigation?{
        if let data = defaults.data(forKey: Self.NAVIGATION_KEY) {
            return try? decoder.decode(STServiceNavigation.self, from: data)
        }else{
            return nil
        }
    }
    
    private func storeServices(_ services: [STService]){
        let data = try! encoder.encode(services)
        defaults.set(data, forKey: Self.SERVICES_KEY)
    }
    
    private func storeCurrentIndex(_ index: Int){
        defaults.set(index, forKey: Self.SERVICE_INDEX_KEY)
    }
    
    private func storeNavigation(_ navigation: STServiceNavigation){
        let data = try! encoder.encode(navigation)
        defaults.set(data, forKey: Self.NAVIGATION_KEY)
    }
    
    private func setAndStoreIndex(_ index: Int){
        self.serviceIndex = index
        storeCurrentIndex(index)
    }
    
    private func setAndStoreNavigation(_ navigation: STServiceNavigation){
        self.navigation = navigation
        storeNavigation(navigation)
    }
}

protocol STServiceManagerDelegate{
    
    func servicesChanged()
    
}

extension STServiceManager{
    var domain: String{
        navigation.domain
    }
    var host: String{
        navigation.host
    }
    var port: Int{
        navigation.port
    }
    var apiUrl: String{
        navigation.apiUrl
    }
    var pushUrl: String{
        navigation.pushUrl
    }
}
