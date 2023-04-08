//
//  STServicesVController.swift
//  Startalk
//
//  Created by lei on 2023/2/24.
//

import UIKit

class STServicesVController: UIViewController, STServicesViewDelegate {
    
    let serviceManager = STKit.shared.serviceManager
    var tableView: UITableView!
    
    override func loadView() {
        let listView = STServicesView()
        listView.delegate = self
        
        tableView = listView.tableView
        view = listView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        serviceManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSelectedRow()
    }
    
    
    func setNavigationBar(){
        navigationItem.title = "service_title".localized
        
        let cancelBarItem = UIBarButtonItem(title: "cancel".localized, style: .plain, target: self, action: #selector(cancelItemTapped))
        cancelBarItem.tintColor = .black
        navigationItem.leftBarButtonItem = cancelBarItem
        
        let addBarItem = UIBarButtonItem(title: "service_add".localized, style: .plain, target: self, action: #selector(addItemTapped))
        addBarItem.tintColor = .black
        navigationItem.rightBarButtonItem = addBarItem
    }
    
    func setSelectedRow(){
        if let index = serviceManager.getServiceIndex(){
            let indexPath = IndexPath(row: index, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        }
    }
    
    func presentEditorView(editing: Bool, index: Int = 0){
        let editorViewControlller = STServiceEditorVController()
        if editing{
            editorViewControlller.type = .edit
            let service = serviceManager.services[index]
            editorViewControlller.service = service
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

extension STServicesVController{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceManager.services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: STServieTableCell.IDENTIFIER, for: indexPath) as! STServieTableCell
        let item = serviceManager.services[indexPath.row]
        cell.setItem(item)
        cell.delegate = self
        return cell
    }
}

extension STServicesVController{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let index = indexPath.row
        if index == serviceManager.getServiceIndex(){
            presentEditorView(editing: true, index: index)
        }else{
            serviceManager.changeServiceIndex(to: index)
        }
    }
}

extension STServicesVController: STServieTableCellDelegate{
    func checkButtonTapped(sender: STServieTableCell) {
        if let indexPath = tableView.indexPath(for: sender){
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            tableView(tableView, didSelectRowAt: indexPath)
        }
    }
    
    func qrCodeButtonTapped(sender: STServieTableCell) {
        if let indexPath = tableView.indexPath(for: sender){
            let index = indexPath.row
            let service = serviceManager.services[index]
            let codeViewController = STServiceQrCodeVController()
            codeViewController.service = service
            navigationController?.pushViewController(codeViewController, animated: true)
        }
    }
    
    func editButtonTapped(sender: STServieTableCell) {
        if let indexPath = tableView.indexPath(for: sender){
            let index = indexPath.row
            presentEditorView(editing: true, index: index)
        }
    }
    
    func deleteButtonTapped(sender: STServieTableCell) {
        if let indexPath = tableView.indexPath(for: sender){
            let title = "delete".localized
            let message = "service_confirm_delete".localized
            showDestructiveConfirmation(title: title, message: message) { [self] in
                let index = indexPath.row
                serviceManager.removeService(at: index)
            }
        }
    }
    
}

extension STServicesVController: STServiceManagerDelegate{

    func servicesChanged() {
        DispatchQueue.main.async { [self] in
            tableView.reloadData()
            setSelectedRow()
        }
    }
}
