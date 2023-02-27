//
//  RSAUtil.swift
//  Startalk
//
//  Created by lei on 2023/2/26.
//

import Foundation

class RSAUtil{
    static let DEFAULT_PUBLIC_KEY = "rsa_public_key"
    static let PUBLIC_KEY_EXTENSION = "pem"
    static let PEM_START_PART = "-----BEGIN PUBLIC KEY-----\n"
    static let PEM_END_PART = "\n-----END PUBLIC KEY-----"
    static let NEW_LINE = "\n"
    
    static func loadPublicKey(_ name: String) -> Data?{
    
        let url = Bundle.main.url(forResource: name, withExtension: PUBLIC_KEY_EXTENSION)
        guard let url = url else{
            return nil
        }
        var content: String
        do{
            content = try String(contentsOf: url)
        }catch{
            return nil
        }
        content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        content = content.replacingOccurrences(of: PEM_START_PART, with: "").replacingOccurrences(of: PEM_END_PART, with: "")
        content = content.replacingOccurrences(of: NEW_LINE, with: "")
        return Data(base64Encoded: content)
    }
    
    static func makeSecKey(_ data: Data) -> SecKey?{
        let attributes = [kSecAttrKeyType         : kSecAttrKeyTypeRSA,
                          kSecAttrKeyClass        : kSecAttrKeyClassPublic,
                          kSecAttrKeySizeInBits   : 2048,
                          kSecReturnPersistentRef : kCFBooleanTrue as Any] as CFDictionary
        return SecKeyCreateWithData(data as CFData, attributes, nil)
    }
    
    static func encrypt(_ data: Data, pubKey: SecKey) -> Data?{
        var source = Array<UInt8>(repeating: 0, count: data.count)
        data.copyBytes(to: &source, count: data.count)
        
        var outSize = SecKeyGetBlockSize(pubKey)
        var outBuffer = Array<UInt8>(repeating: 0, count: outSize)
        let status = SecKeyEncrypt(pubKey, SecPadding.PKCS1, source, source.count, &outBuffer, &outSize)
        guard status == errSecSuccess else{
            return nil
        }
        return Data(bytes: outBuffer, count: outSize)
    }
    
    static func encrpyt(_ text: String) -> String?{
        let keyData = loadPublicKey(DEFAULT_PUBLIC_KEY)
        guard let keyData = keyData else{
            return nil
        }
        let key = makeSecKey(keyData)
        guard let key = key else{
            return nil
        }
        let input = text.data(using: .utf8)
        guard let input = input else{
            return nil
        }
        let output = encrypt(input, pubKey: key)
        guard let output = output else{
            return nil
        }
        return output.base64EncodedString()
    }
}
