//
//  STMessageInputState.swift
//  Startalk
//
//  Created by lei on 2023/4/2.
//

import Foundation

enum STMessageInputState: Equatable{
    case idle
    case voice
    case text(Bool)
    case sticker
    case more
}
