//
//  FileUploadClient.swift
//  Startalk
//
//  Created by lei on 2023/5/18.
//

import Foundation
import Alamofire

class FileUploadClient: STHttpClient{
    static let IMAGE_UPLOAD_PATH = "/file/v2/upload/img"
    
    static let IMAGE_MULTIPART_NAME = "file"
    
    lazy var serviceManager = STKit.shared.serviceManager
    
    var baseUrl: String{
        serviceManager.fileUrl
    }
    
    func uploadImage(data: Data, name: String, type: String, completion: @escaping (FileUploadResult) -> Void){
        let params = ["key": name, "name": "\(name).\(type)"]
        let url = buildUrl(baseUrl: baseUrl, path: Self.IMAGE_UPLOAD_PATH, params: params)
        
         AF.upload(multipartFormData: { formData in
            formData.append(data, withName: Self.IMAGE_MULTIPART_NAME)
         }, to: url).responseDecodable(of: ImageUploadResponse.self){ response in
             
             var result: FileUploadResult = .failed
             
             if let uploadResponse = response.value{
                 if uploadResponse.ret{
                     result = .success(uploadResponse.data)
                 }
             }
             completion(result)
        }
        
    }
    
    private struct ImageUploadResponse: Codable{
        var ret: Bool
        var data: String
    }
}

enum FileUploadResult{
    case success(String)
    case failed
}


