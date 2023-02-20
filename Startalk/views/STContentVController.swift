//
//  STContentVController.swift
//  Startalk
//
//  Created by busylei on 2023/1/11.
//

import UIKit

class STContentVController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
            
        setControllers()
        
        navigationItem.title = "Chats"
    }
    
    func setControllers(){
        let chatsVController = STChatsVController()
        let soundImsage = UIImage(named: "chats")
        chatsVController.tabBarItem = UITabBarItem(title: "Chats", image: soundImsage, tag: 1)
        
        let liveVController = STContactVController()
        let liveImage = UIImage(named: "contact")
        liveVController.tabBarItem = UITabBarItem(title: "Contact", image: liveImage, tag: 2)
        
        let chatVController = STDiscoverVController()
        let chatImage = UIImage(named: "discover")
        chatVController.tabBarItem = UITabBarItem(title: "Discover", image: chatImage, tag: 3)
        
        let mineVController = STMineVController()
        let mineImage = UIImage(named: "me")
        mineVController.tabBarItem = UITabBarItem(title: "Me", image: mineImage, tag: 4)
        
        viewControllers = [chatsVController, liveVController, chatVController, mineVController]
    }
}
