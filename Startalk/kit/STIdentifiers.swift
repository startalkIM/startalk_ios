//
//  STIdentifiers.swift
//  Startalk
//
//  Created by lei on 2023/2/27.
//

import UIKit

class STIdentifiers{
    static let APP_DEFAULT_ID = "com.im.startalk"
    static let APP_VERSION_KEY = "CFBundleShortVersionString"
    static let APP_DEFAULT_VERSION = "1.0.0"
    
    static private let DEVICE_UID_KEY = "device_uid"
    
    static let defaults = UserDefaults.standard
    
    let deviceUid: String       //e.g. 7338419CCB5242039DB36FF8A0560246
    let deviceName: String      //e.g. iPhone 14 Pro
    let systemName: String      //e.g. iOS
    let systemVersion: String   //e.g. 16.1
    
    let appId: String           //e.g. com.im.startalk
    let appVersion: String      //e.g. 2.0.0
    
    init() {
        let device = UIDevice.current

        let uuid = Self.pickDeviceUid()
        if let uuid = uuid{
            deviceUid = uuid
        }else{
            deviceUid = StringUtil.makeUUID()
            Self.storeDeviceUid(deviceUid)
        }
        
        var deviceName = device.name
        deviceName.removeAll { $0 == " "}
        deviceName.removeAll { $0 == "(" || $0 == ")"}
        self.deviceName = deviceName
        
        systemName = device.systemName
        systemVersion = device.systemVersion
        
        appId = Bundle.main.bundleIdentifier ?? Self.APP_DEFAULT_ID
        appVersion = Bundle.main.object(forInfoDictionaryKey: Self.APP_VERSION_KEY) as? String ??  Self.APP_DEFAULT_VERSION
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
