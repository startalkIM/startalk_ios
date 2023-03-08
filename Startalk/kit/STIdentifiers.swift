//
//  STIdentifiers.swift
//  Startalk
//
//  Created by lei on 2023/2/27.
//

import Foundation

class STIdentifiers{
    static private let DEVICE_UID_KEY = "device_uid"
    
    static let defaults = UserDefaults.standard
    
    let platform = "iOS"
    var deviceUid: String
    
    init() {
        let uuid = Self.pickDeviceUid()
        if let uuid = uuid{
            deviceUid = uuid
        }else{
            deviceUid = StringUtil.makeUUID()
            Self.storeDeviceUid(deviceUid)
        }
    }
}

extension STIdentifiers{
    static func pickDeviceUid() -> String?{
        defaults.string(forKey: Self.DEVICE_UID_KEY)
    }
    
    static func storeDeviceUid(_ value: String){
        defaults.set(value, forKey: Self.DEVICE_UID_KEY)
    }
}
