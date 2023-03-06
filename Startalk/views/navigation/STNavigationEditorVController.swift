//
//  STNavigationEditorVController.swift
//  Startalk
//
//  Created by lei on 2023/2/25.
//

import UIKit

class STNavigationEditorVController: STEditableViewController {
    private static let MAX_NAME_SIZE = 32
    private static let MAX_LOCATION_SIZE = 512
    
    var editorView: STNavigationEditorView{
        view as! STNavigationEditorView
    }
    var nameTextField: UITextField!
    var locationTextField: UITextField!
    
    var type: STNavigationEditorType = .add
    var location: STNavigationLocation = .empty
    
    let navigationManager = STKit.shared.navigationManager
    
    override func loadView() {
        let view = STNavigationEditorView()
        nameTextField = view.nameTextField
        locationTextField = view.locationTextField
        
        view.delegate = self
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.text = location.name
        locationTextField.text = location.location
        
        navigationController?.navigationBar.tintColor = .black
        if type == .add{
            navigationItem.title = "navigation_editor_add".localized
        }else{
            navigationItem.title = "navigation_editor_edit".localized
        }
        
        if self == navigationController?.viewControllers.first {
            let cancelBarItem = UIBarButtonItem(title: "cancel".localized, style: .plain, target: self, action: #selector(cancel))
            navigationItem.leftBarButtonItem = cancelBarItem
        }
        
        let saveBarItem = UIBarButtonItem(title: "save".localized, style: .plain, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = saveBarItem
        
        checkSaveBarItem()
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
            showAlert(title: "reminder".localized, message: "navigation_name_too_long".localized)
            return
        }
        if value.count > Self.MAX_LOCATION_SIZE{
            showAlert(title: "reminder".localized, message: "navigation_location_too_long".localized)
            return
        }
        
        location.name = name
        location.location = value

        let competion: (Bool) -> Void = { [self] success in
            if success{
                dismiss(animated: true)
            }else{
                showAlert(title: "reminder".localized, message: "navigation_invalid_location".localized)
            }
        }
        switch type{
        case .add:
            navigationManager.addLocation(location, completion: competion)
        case .edit:
            navigationManager.updateLocation(location, completion: competion)
        }
    }
    
    func checkSaveBarItem(){
        let nameValid = StringUtil.isNotEmpty(nameTextField.text)
        let locationValid = StringUtil.isNotEmpty(locationTextField.text)
        navigationItem.rightBarButtonItem?.isEnabled = nameValid && locationValid
    }
}

enum STNavigationEditorType{
    case add
    case edit
    
}
extension STNavigationEditorVController: STNavigationEditorViewDelegate{
    
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
