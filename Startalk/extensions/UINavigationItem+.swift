//
//  UINavigationItem.swift
//  Startalk
//
//  Created by lei on 2023/3/11.
//

import UIKit

extension UINavigationItem{
    
    func copy(from source: UINavigationItem){
        //Configuring the title
        title = source.title
        largeTitleDisplayMode = source.largeTitleDisplayMode
        
        //Configuring the Back button
        backBarButtonItem = source.backBarButtonItem
        backButtonTitle = source.backButtonTitle
        if #available(iOS 14.0, *) {
            backButtonDisplayMode = source.backButtonDisplayMode
        }
        hidesBackButton = source.hidesBackButton
        if #available(iOS 16.0, *) {
            backAction = source.backAction
        }
        
        //Specifying the navigation style
        if #available(iOS 16.0, *) {
            style = source.style
        }
        
        //Specifying custom views
        if #available(iOS 16.0, *) {
            centerItemGroups = source.centerItemGroups
            leadingItemGroups = source.leadingItemGroups
            trailingItemGroups = source.trailingItemGroups
            pinnedTrailingGroup = source.pinnedTrailingGroup
        }
        titleView = source.titleView
        leftBarButtonItems = source.leftBarButtonItems
        leftBarButtonItem = source.leftBarButtonItem
        rightBarButtonItems = source.rightBarButtonItems
        rightBarButtonItem = source.rightBarButtonItem
        
        //Getting and setting properties
        prompt = source.prompt
        leftItemsSupplementBackButton = source.leftItemsSupplementBackButton
        
        //Overriding the navigation bar's appearance settings
        standardAppearance = source.standardAppearance
        compactAppearance = source.compactAppearance
        scrollEdgeAppearance = source.scrollEdgeAppearance
        if #available(iOS 15.0, *) {
            compactScrollEdgeAppearance = source.compactScrollEdgeAppearance
        }
        
        //Integrating search into your interface
        searchController = source.searchController
        hidesBackButton = source.hidesBackButton
        if #available(iOS 16.0, *) {
            preferredSearchBarPlacement = source.preferredSearchBarPlacement
        }
        
        //Supporting navigation bar customization
        if #available(iOS 16.0, *) {
            customizationIdentifier = source.customizationIdentifier
        }
        
        //Working with the overflow menu
        if #available(iOS 16.0, *) {
            additionalOverflowItems = source.additionalOverflowItems
        }
        
        //Customizing the title menu
        if #available(iOS 16.0, *) {
            titleMenuProvider = source.titleMenuProvider
            documentProperties = source.documentProperties
        }
        
        //Renaming documents
        if #available(iOS 16.0, *) {
            renameDelegate = source.renameDelegate
        }
        
    }
    
}
