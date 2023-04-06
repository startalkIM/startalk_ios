//
//  STContentVController.swift
//  Startalk
//
//  Created by busylei on 2023/1/11.
//

import UIKit

class STContentVController: UITabBarController {

    let contentDelegate = STContentVControllerDelegate()
    let appStateManager = STKit.shared.appStateManager
    let notificationCenter = STKit.shared.notificationCenter
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setControllers()
        
        delegate = contentDelegate
        notificationCenter.observeAppStateChanged(self) { _ in
            DispatchQueue.main.async {
                self.setNavigationItem()
            }
        }
        setNavigationItem()
    }
    
    func setControllers(){
        let chatsVController = STChatsVController()
        let soundImsage = UIImage(named: "tabs/chats")
        chatsVController.tabBarItem = UITabBarItem(title: "chats".localized, image: soundImsage, tag: 1)
        
        let contactVController = STContactVController()
        let contactImage = UIImage(named: "tabs/contact")
        contactVController.tabBarItem = UITabBarItem(title: "contact".localized, image: contactImage, tag: 2)
        
        let discoverVController = STDiscoverVController()
        let discoverImage = UIImage(named: "tabs/discover")
        discoverVController.tabBarItem = UITabBarItem(title: "discover".localized, image: discoverImage, tag: 3)
        
        let mineVController = STMineVController()
        let mineImage = UIImage(named: "tabs/me")
        mineVController.tabBarItem = UITabBarItem(title: "mine".localized, image: mineImage, tag: 4)
        
        viewControllers = [chatsVController, contactVController, discoverVController, mineVController]
    }
}

class STContentVControllerDelegate: NSObject, UITabBarControllerDelegate{
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let contentController = tabBarController as! STContentVController
        contentController.setNavigationItem()
    }
    
}

extension STContentVController{
    
    func setNavigationItem(){
        guard let viewController = selectedViewController else{ return }
        
        var navigationItem = viewController.navigationItem
        let state = appStateManager.state
        
        if viewController is STChatsVController && (state == .connecting || state == .loading){
            navigationItem = UINavigationItem()
            let title: String
            if state == .connecting{
                title = "state_connecting".localized
            }else{
                title = "state_loading".localized
            }
            navigationItem.titleView = makeNavigationActivityView(title)
        }
        
        self.navigationItem.copy(from: navigationItem)
    }
    
    func makeNavigationActivityView(_ title: String) -> UIView{
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.startAnimating()
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        
        let container = UIView()
        container.addSubview(indicator)
        container.addSubview(label)
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
    
        NSLayoutConstraint.activate([
            indicator.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            indicator.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            
            label.leadingAnchor.constraint(equalTo: indicator.trailingAnchor, constant: 8),
            container.heightAnchor.constraint(equalTo: label.heightAnchor),
        ])
        
        return container
    }
}
