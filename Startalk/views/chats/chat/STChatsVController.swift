//
//  STChatsVController.swift
//  Startalk
//
//  Created by busylei on 2023/1/12.
//

import UIKit

class STChatsVController: UITableViewController {
    lazy var chatManager = STKit.shared.chatManager
    lazy var notificationCenter = STKit.shared.notificationCenter
    
    lazy var chatSource = chatManager.makeChatDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "chats".localized
                
        tableView.separatorInset = UIEdgeInsets(top: 0, left: STChatTableCell.SEPARATOR_INSET, bottom: 0, right: 0)
        tableView.register(STChatTableCell.self, forCellReuseIdentifier: STChatTableCell.IDENTIFIER)
        tableView.rowHeight = STChatTableCell.CELL_HEIGHT        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        notificationCenter.observeChatListChanged(self) { [self] in
           reloadData()
        }
        reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notificationCenter.unobserveChatListChanged(self)
    }
    
    func reloadData(){
        chatSource.reload()
        DispatchQueue.main.async { [self] in
            tableView.reloadData()
        }
    }
    
}
 
extension STChatsVController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: STChatTableCell.IDENTIFIER, for: indexPath)
        if let cell = cell as? STChatTableCell{
            let chat = chatSource.chat(at: indexPath.row)
            cell.setChat(chat)
        }
        return cell
    }
    
}

extension STChatsVController{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chat = chatSource.chat(at: indexPath.row)
        let messageControllr = STMessagesVController(chat)
        
        navigationController?.pushViewController(messageControllr, animated: true)
    }
}
