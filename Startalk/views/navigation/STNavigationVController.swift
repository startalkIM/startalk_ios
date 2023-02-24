//
//  STNavigationVController.swift
//  Startalk
//
//  Created by lei on 2023/2/24.
//

import UIKit

class STNavigationVController: UITableViewController {
    let items:[STNavigationItem] = [
        STNavigationItem(name: "uk", location: "https://www.baidu.com"),
        STNavigationItem(name: "cn", location: "https://cc.com"),
    ]
    let selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(STNavigationTableCell.self, forCellReuseIdentifier: STNavigationTableCell.IDENTIFIER)
        tableView.rowHeight = STNavigationTableCell.CELL_HEIGHT
        tableView.separatorStyle = .none
        
    }
  
}

extension STNavigationVController{
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: STNavigationTableCell.IDENTIFIER, for: indexPath) as! STNavigationTableCell
        let item = items[indexPath.row]
        cell.setItem(item)
        return cell
    }
}


extension STNavigationVController{

    
    override func viewDidAppear(_ animated: Bool) {
        let indexPath = IndexPath(row: selectedIndex, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
    }
}
