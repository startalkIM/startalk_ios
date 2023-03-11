//
//  STChatsVController.swift
//  Startalk
//
//  Created by busylei on 2023/1/12.
//

import UIKit

class STChatsVController: UITableViewController {

    static let formmater: DateFormatter = {
       let formmater = DateFormatter()
        formmater.dateFormat = "yy-MM-dd HH:mm"
        return formmater
    }()
    var chats = [
        STChat(id: 1, isGroup: false, title: "张三", photo: "https://img2.doubanio.com/icon/up1218141-3.jpg", brief: "想我了没", status: .sent, unreadCount: 5, isSticky: false, isMuted: false, timestamp: formmater.date(from: "23-03-11 17:03")!),
        STChat(id: 2, isGroup: true, title: "聚会", photo: "https://img1.doubanio.com/icon/up125141205-10.jpg", brief: "吃完饭去哪", status: .sending, unreadCount: 200, isSticky: false, isMuted: true, timestamp: formmater.date(from: "23-03-08 10:03")!),
        STChat(id: 3, isGroup: false, title: "小红", photo: "https://img2.doubanio.com/icon/up4202018-221.jpg", brief: "早上好呀", status: .failed, unreadCount: 10, isSticky: false, isMuted: false, timestamp: formmater.date(from: "23-01-08 12:45")!),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "chats"
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: STChatTableCell.SEPARATOR_INSET, bottom: 0, right: 0)
        tableView.register(STChatTableCell.self, forCellReuseIdentifier: STChatTableCell.IDENTIFIER)
        tableView.rowHeight = STChatTableCell.CELL_HEIGHT
        
        tableView.tableHeaderView = UIView()
    }
    
}
 
extension STChatsVController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: STChatTableCell.IDENTIFIER, for: indexPath)
        if let cell = cell as? STChatTableCell{
            let chat = chats[indexPath.row]
            cell.setChat(chat)
        }
        return cell
    }
    
    
}
