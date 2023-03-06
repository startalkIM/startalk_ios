//
//  STNavigationListVController.swift
//  Startalk
//
//  Created by lei on 2023/2/24.
//

import UIKit

class STNavigationListVController: UIViewController, STNavigationListViewDelegate {
    let items:[STNavigationLocation] = [
        STNavigationLocation(id: 0, name: "uk", location: "https://www.baidu.com"),
        STNavigationLocation(id: 1, name: "cn", location: "https://cc.com"),
    ]
    let selectedIndex = 0
    
    var tableView: UITableView!
    
    override func loadView() {
        let listView = STNavigationListView()
        listView.delegate = self
        
        view = listView
        tableView = listView.tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       setNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let indexPath = IndexPath(row: selectedIndex, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
    }
    
    
    func setNavigationBar(){
        navigationItem.title = "navigation_title".localized
        
        let cancelBarItem = UIBarButtonItem(title: "cancel".localized, style: .plain, target: self, action: #selector(cancelItemTapped))
        cancelBarItem.tintColor = .black
        navigationItem.leftBarButtonItem = cancelBarItem
        
        let addBarItem = UIBarButtonItem(title: "navigation_add".localized, style: .plain, target: self, action: #selector(addItemTapped))
        addBarItem.tintColor = .black
        navigationItem.rightBarButtonItem = addBarItem
    }
    
    func presentEditorView(_ editing: Bool){
        let editorController =  STNavigationEditorVController()
        navigationController?.pushViewController(editorController, animated: true)
    }

    @objc
    func cancelItemTapped() {
        dismiss(animated: true)
    }
    
    
    @objc
    func addItemTapped(){
        presentEditorView(false)
    }
    
    func confirmButtonTapped() {
    }
}

extension STNavigationListVController{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: STNavigationTableCell.IDENTIFIER, for: indexPath) as! STNavigationTableCell
        let item = items[indexPath.row]
        cell.setItem(item)
        return cell
    }
}


extension STNavigationListVController{

    
    
}
