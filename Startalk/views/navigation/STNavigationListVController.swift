//
//  STNavigationListVController.swift
//  Startalk
//
//  Created by lei on 2023/2/24.
//

import UIKit

class STNavigationListVController: UIViewController, STNavigationListViewDelegate {
    
    let navigationManager = STKit.shared.navigationManager
    var tableView: UITableView!
    
    override func loadView() {
        let listView = STNavigationListView()
        listView.delegate = self
        
        tableView = listView.tableView
        view = listView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        navigationManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSelectedRow()
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
    
    func setSelectedRow(){
        if let index = navigationManager.currentLocationIndex{
            let indexPath = IndexPath(row: index, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        }
    }
    
    func presentEditorView(editing: Bool, index: Int = 0){
        let editorViewControlller = STNavigationEditorVController()
        if editing{
            editorViewControlller.type = .edit
            let location = navigationManager.locations[index]
            editorViewControlller.location = location
        }else{
            editorViewControlller.type = .add
        }
        navigationController?.pushViewController(editorViewControlller, animated: true)
    }

    @objc
    func cancelItemTapped() {
        dismiss(animated: true)
    }
    
    
    @objc
    func addItemTapped(){
        presentEditorView(editing: false)
    }
    
    func confirmButtonTapped() {
        dismiss(animated: true)
    }
}

extension STNavigationListVController{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return navigationManager.locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: STNavigationTableCell.IDENTIFIER, for: indexPath) as! STNavigationTableCell
        let item = navigationManager.locations[indexPath.row]
        cell.setItem(item)
        cell.delegate = self
        return cell
    }
}

extension STNavigationListVController{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let index = indexPath.row
        if index == navigationManager.currentLocationIndex{
            presentEditorView(editing: true, index: index)
        }else{
            navigationManager.setLocationIndex(index)
        }
    }
}

extension STNavigationListVController: NavigationTableViewCellDelegate{
    func checkButtonTapped(sender: STNavigationTableCell) {
        if let indexPath = tableView.indexPath(for: sender){
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            tableView(tableView, didSelectRowAt: indexPath)
        }
    }
    
    func qrCodeButtonTapped(sender: STNavigationTableCell) {
        if let indexPath = tableView.indexPath(for: sender){
            let index = indexPath.row
            let location = navigationManager.locations[index]
            let codeViewController = STNavigationQrCodeVController()
            codeViewController.location = location
            navigationController?.pushViewController(codeViewController, animated: true)
        }
    }
    
    func editButtonTapped(sender: STNavigationTableCell) {
        if let indexPath = tableView.indexPath(for: sender){
            let index = indexPath.row
            presentEditorView(editing: true, index: index)
        }
    }
    
    func deleteButtonTapped(sender: STNavigationTableCell) {
        if let indexPath = tableView.indexPath(for: sender){
            let title = "delete".localized
            let message = "navigation_confirm_delete".localized
            showDestructiveConfirmation(title: title, message: message) { [self] in
                let index = indexPath.row
                navigationManager.removeLocation(at: index)
            }
        }
    }
    
}

extension STNavigationListVController: STNavigationManagerDelegate{

    func locationsChanged() {
        DispatchQueue.main.async { [self] in
            tableView.reloadData()
            setSelectedRow()
        }
    }
}
