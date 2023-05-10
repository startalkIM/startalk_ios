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
    lazy var connection = STKit.shared.databaseManager.getUserConnection()
    
    func loadGroups(){
        let entity = GroupRequest(lastupdtime: 0, userid: userState.username)
        let url = apiClient.buildUrl(path: Self.GROUP_PATH)
        Task{
            var groups: [Group] = []
            let result: STApiResult<[GroupRaw]> = await apiClient.post(url, entity: entity)
            switch result{
            case .response(let gs):
                groups = gs.map{ g in
                    Group(xmppId: g.MN, name: g.SN, photo: g.MP)
                }
            case .success:
                break
            case .failure(_):
                logger.warn("request group failes")
            }
            storeGroups(groups)
        }
    }
    
    struct GroupRequest: Codable{
        var lastupdtime: Int
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
                let name = try resultSet.getString("name") ?? "Group"
                let photo = try resultSet.getString("photo")
                group = Group(xmppId: xmppId, name: name, photo: photo)
            }
        }catch{
            logger.warn("fetch group faild", error)
        }
        return group
    }
}
