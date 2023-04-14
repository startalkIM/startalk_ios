//
//  STServiceEditorVController.swift
//  Startalk
//
//  Created by lei on 2023/2/25.
//

import UIKit

class STServiceEditorVController: STEditableViewController {
    private static let MAX_NAME_SIZE = 32
    private static let MAX_LOCATION_SIZE = 512
    
    var editorView: STServiceEditorView{
        view as! STServiceEditorView
    }
    var nameTextField: UITextField!
    var locationTextField: UITextField!
    
    var type: STServiceEditorType = .add
    var service: STService = .empty
    
    let serviceManager = STKit.shared.serviceManager
    
    override func loadView() {
        let view = STServiceEditorView()
        nameTextField = view.nameTextField
        locationTextField = view.locationTextField
        
        view.delegate = self
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.text = service.name
        locationTextField.text = service.location
        
        navigationController?.navigationBar.tintColor = .black
        if type == .add{
            navigationItem.title = "service_editor_add".localized
        }else{
            navigationItem.title = "service_editor_edit".localized
        }
        
        if isFirstController {
            let cancelBarItem = UIBarButtonItem(title: "cancel".localized, style: .plain, target: self, action: #selector(cancel))
            navigationItem.leftBarButtonItem = cancelBarItem
        }
        
        let saveBarItem = UIBarButtonItem(title: "save".localized, style: .plain, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = saveBarItem
        
        checkSaveBarItem()
    }
    
    var isFirstController: Bool{
        self == navigationController?.viewControllers.first
    }
    
    @objc
    func cancel(){
        dismiss(animated: true)
    }
    
    @objc
    func save(){
        guard let name = nameTextField.text, !name.isEmpty else{
            return
        }
        guard let value = locationTextField.text, !value.isEmpty else{
            return
        }
        if name.count > Self.MAX_NAME_SIZE{
            showAlert(title: "reminder".localized, message: "service_name_too_long".localized)
            return
        }
        if value.count > Self.MAX_LOCATION_SIZE{
            showAlert(title: "reminder".localized, message: "service_location_too_long".localized)
            return
        }
        
        service.name = name
        service.location = value

        Task{
            showLoadingView()
            
            let success: Bool
            switch type{
            case .add:
                success = await serviceManager.addService(service)
            case .edit:
                success = await serviceManager.updateService(service)
            }
            hideLoadingView{
                if success{
                    if self.isFirstController{
                        self.dismiss(animated: true)
                    }else{
                        self.navigationController?.popViewController(animated: true)
                    }
                }else{
                    self.showAlert(title: "reminder".localized, message: "service_invalid_location".localized)
                }
            }
        }
    }
    
    func checkSaveBarItem(){
        let nameValid = StringUtil.isNotEmpty(nameTextField.text)
        let locationValid = StringUtil.isNotEmpty(locationTextField.text)
        navigationItem.rightBarButtonItem?.isEnabled = nameValid && locationValid
    }
}

enum STServiceEditorType{
    case add
    case edit
    
}
extension STServiceEditorVController: STServiceEditorViewDelegate{
    
    func scanButtonTapped() {
        let scanViewController = STScanVController()
        scanViewController.modalPresentationStyle = .fullScreen
        
        scanViewController.completion = { [self] text in
            dismiss(animated: true)
            locationTextField.text = text
            checkSaveBarItem()
        }
        present(scanViewController, animated: true)
    }
    
    func nameChanged() {
        checkSaveBarItem()
    }
    
    func locationChanged() {
        checkSaveBarItem()
    }
}
