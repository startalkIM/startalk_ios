//
//  NavigationTableViewCell.swift
//  Startalk
//
//  Created by lei on 2023/2/24.
//

import UIKit

class STNavigationTableCell: UITableViewCell {
    static let IDENTIFIER = "navigationCell"
    static let CELL_HEIGHT: CGFloat = 130
    
    var contentBackground: UIView!
    var titleLabel: UILabel!
    var locationLabel: UILabel!
    var checkButton: UIButton!
    var qrCodeButton: UIButton!
    var editButton: UIButton!
    var deleteButton: UIButton!
    
    var delegate: NavigationTableViewCellDelegate?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        addBackground()
        addTitleLabel()
        addLocationLabel()
        addCheckButton()
        addQrCodeButton()
        addEditButton()
        addDeleteButton()
        
        setMargins()
        layoutBackground()
        layoutTitleLabel()
        layoutLocationLabel()
        layoutCheckButton()
        layoutQrCodeButton()
        layoutEditButton()
        layoutDeleteButton()
        
        setNormalColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addBackground(){
        let view = UIView()
        contentView.addSubview(view)
        self.contentBackground = view
    }
    
    func addTitleLabel(){
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        
        contentView.addSubview(label)
        self.titleLabel = label
    }
    
    func addLocationLabel(){
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        
        contentView.addSubview(label)
        self.locationLabel = label
    }
    
    func addCheckButton(){
        let button =  UIButton()
        
        let image = UIImage(named: "navigation/check")
        button.setImage(image?.withTintColor(.make(0xE4E4E4)), for: .normal)
        button.setImage(image?.withTintColor(.make(0x00CABE)), for: .selected)
        
        button.addTarget(self, action: #selector(tapCheck), for: .touchUpInside)
        contentView.addSubview(button)
        self.checkButton = button
    }
    
    func addQrCodeButton(){
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "navigation/qrcode"), for: .normal)
        button.tintColor = .make(0x616161)
        
        button.addTarget(self, action: #selector(tapQrcode), for: .touchUpInside)
        contentView.addSubview(button)
        self.qrCodeButton = button
    }
    
    func addEditButton(){
        let button = UIButton(type: .system)
        button.setTitle("navigation_change".localized, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.layer.borderWidth = 1
        
        button.addTarget(self, action: #selector(tapEdit), for: .touchUpInside)
        contentView.addSubview(button)
        self.editButton = button
    }
    
    func addDeleteButton(){
        let button = UIButton(type: .system)
        button.setTitle("navigation_delete".localized, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.layer.borderWidth = 1
        
        button.addTarget(self, action: #selector(tapDelete), for: .touchUpInside)
        contentView.addSubview(button)
        self.deleteButton = button
    }
    
    func setMargins(){
        contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
    }
    
    func layoutBackground(){
        let background = contentBackground!
        background.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            background.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            background.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            background.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor)
        ])
    }
    
    func layoutTitleLabel(){
        let label = titleLabel!
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 12),
            label.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func layoutLocationLabel(){
        let label = locationLabel!
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 8 ),
            label.trailingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            label.heightAnchor.constraint(equalToConstant: 17)
        ])
    }
    
    func layoutCheckButton(){
        let button = checkButton!
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 12),
            button.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -12),
            button.widthAnchor.constraint(equalToConstant: 28),
            button.heightAnchor.constraint(equalToConstant: 28),
        ])
    }
    
    func layoutQrCodeButton(){
        let button = qrCodeButton!
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 13),
            button.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -10),
            button.widthAnchor.constraint(equalToConstant: 20),
            button.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    func layoutEditButton(){
        let button = editButton!
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -10),
            button.centerYAnchor.constraint(equalTo: qrCodeButton.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 60),
            button.heightAnchor.constraint(equalToConstant: 28),
        ])
    }
    
    func layoutDeleteButton(){
        let button = deleteButton!
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -16),
            button.centerYAnchor.constraint(equalTo: qrCodeButton.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 60),
            button.heightAnchor.constraint(equalToConstant: 28),
        ])
    }
    
    var layoutGuide: UILayoutGuide{
        contentView.layoutMarginsGuide
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        checkButton.isSelected = isSelected
        if selected {
            setSelectedColor()
        }else{
            setNormalColor()
        }
    }
    
    func setNormalColor(){
        contentBackground.backgroundColor = .make(0xF3F3F3)
        titleLabel.textColor = .make(0x9B9B9B)
        locationLabel.textColor = .make(0x9B9B9B)
        editButton.layer.borderColor = UIColor.make(0xD9D9D9).cgColor
        deleteButton.layer.borderColor = UIColor.make(0xD9D9D9).cgColor
    }
    
    func setSelectedColor(){
        contentBackground.backgroundColor = .make(0xDFF9F4)
        titleLabel.textColor = .make(0x333333)
        locationLabel.textColor = .make(0x333333)
        editButton.layer.borderColor = UIColor.make(0x939393).cgColor
        deleteButton.layer.borderColor = UIColor.make(0x939393).cgColor
    }

}

extension STNavigationTableCell{
    func setItem(_ item: STNavigationLocation){
        titleLabel.text = item.name
        locationLabel.text = item.value
    }
}

extension STNavigationTableCell{
    
    @objc
    func tapCheck(){
        delegate?.checkButtonTapped(sender: self)
    }
    
    @objc
    func tapQrcode(){
        delegate?.qrCodeButtonTapped(sender: self)
    }
    
    @objc
    func tapEdit(){
        delegate?.editButtonTapped(sender: self)
    }
    
    @objc
    func tapDelete(){
        delegate?.deleteButtonTapped(sender: self)
    }
}

protocol NavigationTableViewCellDelegate{
    
    func checkButtonTapped(sender: STNavigationTableCell)
    
    func qrCodeButtonTapped(sender: STNavigationTableCell)
    
    func editButtonTapped(sender: STNavigationTableCell)
    
    func deleteButtonTapped(sender: STNavigationTableCell)
    
}
