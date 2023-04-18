//
//  Array+.swift
//  Startalk
//
//  Created by lei on 2023/4/18.
//

import Foundation

extension Array{
    
    func dict<ID>(_ transform: (Element) -> ID) -> Dictionary<ID, Element> where ID: Hashable{
        var dict: [ID: Element] = [: ]
        for element in self{
            let id = transform(element)
            dict[id] = element
        }
        return dict
    }
}
