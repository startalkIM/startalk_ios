//
//  UIImageView+.swift
//  Startalk
//
//  Created by lei on 2023/3/10.
//

import UIKit

extension UIImageView{
    
    func load(_ location: String){
        guard let url = URL(string: location) else{
            return
        }
        let urlSession = URLSession.shared
        
        let task = urlSession.dataTask(with: url) { data, _, error in
            if let _ = error{
                return
            }
            guard let data = data else{
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }
        task.resume()
    }
}
