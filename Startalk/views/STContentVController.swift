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
    }
    
    func setControllers(){
        let chatsVController = STChatsVController()
        let soundImsage = UIImage(named: "tabs/chats")
        chatsVController.tabBarItem = UITabBarItem(title: "Chats", image: soundImsage, tag: 1)
        
        let liveVController = STContactVController()
        let liveImage = UIImage(named: "tabs/contact")
        liveVController.tabBarItem = UITabBarItem(title: "Contact", image: liveImage, tag: 2)
        
        let chatVController = STDiscoverVController()
        let chatImage = UIImage(named: "tabs/discover")
        chatVController.tabBarItem = UITabBarItem(title: "Discover", image: chatImage, tag: 3)
        
        let mineVController = STMineVController()
        let mineImage = UIImage(named: "tabs/me")
        mineVController.tabBarItem = UITabBarItem(title: "Me", image: mineImage, tag: 4)
        
        viewControllers = [chatsVController, liveVController, chatVController, mineVController]
    }
    
    override var navigationItem: UINavigationItem{
        selectedViewController?.navigationItem ?? super.navigationItem
    }
}
