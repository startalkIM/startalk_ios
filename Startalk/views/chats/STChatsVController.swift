//
//  STChatsVController.swift
//  Startalk
//
//  Created by busylei on 2023/1/12.
//

import UIKit

class STChatsVController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "chats".localized
        
        let label = UILabel()
        label.text = "Chats"
        label.sizeToFit()
        label.center = view.center
        view.addSubview(label)
        
        view.backgroundColor = .systemBackground
    }
    
}
