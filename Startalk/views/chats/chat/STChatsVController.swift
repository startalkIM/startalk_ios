//
//  STChatsVController.swift
//  Startalk
//
//  Created by busylei on 2023/1/12.
//

import UIKit

class STChatsVController: UITableViewController {
    let messageManager = STKit.shared.messageManager
    let notificaitonCenter = STKit.shared.notificationCenter
    
    lazy var messagesSource = messageManager.makeChatDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "chats"
                
        tableView.separatorInset = UIEdgeInsets(top: 0, left: STChatTableCell.SEPARATOR_INSET, bottom: 0, right: 0)
        tableView.register(STChatTableCell.self, forCellReuseIdentifier: STChatTableCell.IDENTIFIER)
        tableView.rowHeight = STChatTableCell.CELL_HEIGHT
        
        tableView.tableHeaderView = UIView()
        
        notificaitonCenter.observeChatListChanged(self) { [self] in
           reloadData()
        }
    }
    
    func reloadData(){
        messagesSource.reload()
        DispatchQueue.main.async { [self] in
            tableView.reloadData()
        }
    }
    
}
 
extension STChatsVController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: STChatTableCell.IDENTIFIER, for: indexPath)
        if let cell = cell as? STChatTableCell{
            let chat = messagesSource.chat(at: indexPath.row)
            cell.setChat(chat)
        }
        return cell
    }
    
}

extension STChatsVController{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chat = messagesSource.chat(at: indexPath.row)
        let messageControllr = STMessagesVController(chat)
        
        navigationController?.pushViewController(messageControllr, animated: true)
    }
}
