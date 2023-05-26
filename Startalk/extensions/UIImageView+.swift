//
//  UIImageView+.swift
//  Startalk
//
//  Created by lei on 2023/3/10.
//

import UIKit

extension UIImageView{
    
    func setSource(_ source: String?, placeholder: UIImage? = nil){
        image = placeholder
        guard let source = source else{ return }
        let loader = STKit.shared.filesManager.loader
        let path = loader.path(of: source)
        if let path = path{
            image = UIImage(contentsOfFile: path)
        }else{
            loader.load(source, object: self) { [self] data in
                if let data = data{
                    DispatchQueue.main.async { [self] in
                        image = UIImage(data: data)
                    }
                }
            }
        }
    }
}
