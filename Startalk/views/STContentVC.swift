//
//  STContentViewController.swift
//  Startalk
//
//  Created by busylei on 2023/1/11.
//

import UIKit

class STContentVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
            
        setControllers()
        
        navigationItem.title = "Chats"
    }
    
    func setControllers(){
        let chatsVC = STChatsVC()
        let soundImsage = UIImage(named: "chats")
        chatsVC.tabBarItem = UITabBarItem(title: "Chats", image: soundImsage, tag: 1)
        
        let liveViewController = STContactVC()
        let liveImage = UIImage(named: "contact")
        liveViewController.tabBarItem = UITabBarItem(title: "Contact", image: liveImage, tag: 2)
        
        let chatViewController = STDiscoverVC()
        let chatImage = UIImage(named: "discover")
        chatViewController.tabBarItem = UITabBarItem(title: "Discover", image: chatImage, tag: 3)
        
        let mineViewController = STMineVC()
        let mineImage = UIImage(named: "me")
        mineViewController.tabBarItem = UITabBarItem(title: "Me", image: mineImage, tag: 4)
        
        viewControllers = [chatsVC, liveViewController, chatViewController, mineViewController]
    }
}
