//
//  GroupManager.swift
//  Startalk
//
//  Created by lei on 2023/5/8.
//

import Foundation

class GroupManager{
    static let GROUP_PATH  = "/muc/get_user_increment_muc_vcard.qunar"
    private let logger = STLogger(GroupManager.self)
    
    lazy var userState = STKit.shared.userState
    lazy var apiClient = STKit.shared.apiClient
    lazy var userManager = STKit.shared.userManager
    lazy var chatManager = STKit.shared.chatManager
    lazy var connection = STKit.shared.databaseManager.getUserConnection()
    
    func loadGroups(){
        let profiles = userManager.fetchProfiles()
        let groupsUpdateTime = profiles?.groupsUpdateTime ?? 0
        let entity = GroupRequest(lastupdtime: groupsUpdateTime, userid: userState.username)
        let url = apiClient.buildUrl(path: Self.GROUP_PATH)
        let now = Date()
        Task{
            let result: ApiFetchResult<[GroupRaw]> = await apiClient.fetch(url, entity: entity)
            switch result{
            case .success(let gs):
                let groups = gs.map{ g in
                    Group(xmppId: g.MN, name: g.SN, photo: g.MP)
                }
                storeGroups(groups)
                userManager.updateGroupUpdateTime(time: now.milliseconds)
                
                chatManager.groupsUpdated(groups: groups)
            case .failure(_):
                logger.warn("request group failes")
            }
        }
    }
    
    
    struct GroupRequest: Codable{
        var lastupdtime: Int64
        var userid: String
    }
    
    struct GroupRaw: Codable{
        var MN: String
        var SN: String
        var MP: String
    }
    

    func storeGroups(_ groups: [Group]){
    let sql = """
            insert into "group"(xmpp_id, name, photo) values(?, ?, ?)
            on conflict(xmpp_id) do update set name = ?, photo = ?
            """
        let values = groups.map { group in
            [group.xmppId, group.name, group.photo, group.name, group.photo]
        }
        do{
            try connection.batchUpdate(sql: sql, values: values)
        }catch{
            logger.warn("store groups failed", error)
        }
    }
    
    func fetchGroup(xmppId: String) -> Group?{
        var group: Group?
        let sql = #"select * from "group" where xmpp_id = ?"#
        do{
           let resultSet = try connection.query(sql: sql, values: xmppId)
            if resultSet.next(){
              group = try Group(resultSet: resultSet)
            }
        }catch{
            logger.warn("fetch group faild", error)
        }
        return group
    }
    
    func fetchGroups(xmppIds: [String]) -> [Group]{
        let xmppIddPhrase = xmppIds.map{ "'\($0)'"}.joined(separator: ", ")
        let sql = #"select * from "group" where xmpp_id in (\#(xmppIddPhrase))"#
        var groups: [Group] = []
        do{
            let resultSet = try connection.query(sql: sql)
            while resultSet.next(){
                let group = try Group(resultSet: resultSet)
                groups.append(group)
            }
        }catch{
            logger.warn("fetch groups failed", error)
        }
        return groups
    }
    
}
