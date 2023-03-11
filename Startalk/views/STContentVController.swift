//
//  STContentVController.swift
//  Startalk
//
//  Created by busylei on 2023/1/11.
//

import UIKit

class STContentVController: UITabBarController {

    let contentDelegate = STContentVControllerDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setControllers()
        
        setNavigationItem()
        delegate = contentDelegate
    }
    
    func setControllers(){
        let chatsVController = STChatsVController()
        let soundImsage = UIImage(named: "tabs/chats")
        chatsVController.tabBarItem = UITabBarItem(title: "Chats", image: soundImsage, tag: 1)
        
        let contactVController = STContactVController()
        let contactImage = UIImage(named: "tabs/contact")
        contactVController.tabBarItem = UITabBarItem(title: "Contact", image: contactImage, tag: 2)
        
        let discoverVController = STDiscoverVController()
        let discoverImage = UIImage(named: "tabs/discover")
        discoverVController.tabBarItem = UITabBarItem(title: "Discover", image: discoverImage, tag: 3)
        
        let mineVController = STMineVController()
        let mineImage = UIImage(named: "tabs/me")
        mineVController.tabBarItem = UITabBarItem(title: "Me", image: mineImage, tag: 4)
        
        viewControllers = [chatsVController, contactVController, discoverVController, mineVController]
    }
    
    
    func setNavigationItem(){
        if let viewController = selectedViewController{
            navigationItem.copy(from: viewController.navigationItem)
        }
    }
}

class STContentVControllerDelegate: NSObject, UITabBarControllerDelegate{
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        tabBarController.navigationItem.copy(from: viewController.navigationItem)
    }
    
}
