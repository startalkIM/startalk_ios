//
//  DatabaseManager.swift
//  Startalk
//
//  Created by lei on 2023/4/25.
//

import Foundation

class DatabaseManager{
    lazy var userState = STKit.shared.userState
    lazy var serviceManager = STKit.shared.serviceManager
    let logger = STLogger(DatabaseManager.self)
    
    private var userConnection: SQLiteConnection!
    private var shareConnection: SQLiteConnection!
    

    func initialize(){
        initializeUserConnection()
        initializeShareConnection()
    }
    
    func getUserConnection() -> SQLiteConnection{
        userConnection
    }
    
    func getShareConnection() -> SQLiteConnection{
        shareConnection
    }
}

extension DatabaseManager{
    func initializeUserConnection(){
        do{
            let path = try makeUserDatabasePath()
            userConnection = try SQLiteConnection(path: path)
        }catch{
            let message = "could not open user sqlite database"
            logger.info(message, error)
            fatalError(message)
        }
        
        do{
            try createUserTable()
            try createGroupTable()
            try createMessageTable()
            try createChatTable()
            try createUserProfiles()
        }catch{
            let message = "create user tables failed"
            logger.info(message, error)
            fatalError(message)
        }
    }
    
    private func makeUserDatabasePath() throws -> String{
        let username = userState.username
        let domain = serviceManager.domain
        let fullName = "\(username)@\(domain)"
        let data = fullName.data(using: .utf8)!
        let name = StringUtil.sha256(data: data)
    
        let fileName = "\(name).sqlite"
        let direcoty = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let url = direcoty.appendingPathComponent(fileName)
        return url.path
        
    }
    
    private func createUserTable() throws{
        let userTableSql = """
            create table if not exists user(
                id integer primary key,
                username text not null,
                domain text not null,
                xmpp_id text not null unique,
                name text,
                gender integer,
                photo text,
                bio text,
                unique(username, domain)
            );
            """
        try userConnection.createTable(sql: userTableSql)
    }
    
    
    private func createGroupTable() throws{
        let sql = """
            create table if not exists "group"(
                id integer primary key,
                xmpp_id text unique not null,
                name text,
                photo text
            );
            """
        try userConnection.createTable(sql: sql)
    }
    
    private func createMessageTable() throws{
        let sql = """
            create table if not exists message(
                id integer primary key,
                message_id text unique,
                chat_id text not null,
                sender text not null,
                receiver text not null,
                is_group integer not null,
                type integer,
                content text,
                client_type integer,
                state integer not null,
                timestamp integer not null
            );
            
            create index if not exists message_message_id_index on message(message_id);
            create index if not exists message_timestamp_index on message(timestamp);
            """
        try userConnection.createTable(sql: sql)
        
    }
    
    private func createChatTable() throws{
        let sql = """
            create table if not exists chat(
                id integer primary key,
                xmpp_id text,
                is_group integer,
                title text,
                photo text,
                last_message_id integer references message(id),
                draft text,
                unread integer,
                is_sticky integer,
                is_muted integer,
                timestamp integer
            );
            
            create index if not exists chat_xmpp_id on chat(xmpp_id);
            create index if not exists chat_timestamp_index on chat(timestamp);
            """
        try userConnection.createTable(sql: sql)
    }
    
    private func createUserProfiles() throws{
        let sql = """
            create table if not exists user_profiles(
                id integer primary key,
                user_id integer not null unique references user(id),
                users_version integer not null default 0,
                groups_update_time integer
            )
            """
        try userConnection.createTable(sql: sql)
    }
}

extension DatabaseManager{
    func initializeShareConnection(){
        do{
            let path = try makeShareDatabasePath()
            shareConnection = try SQLiteConnection(path: path)
        }catch{
            let message = "could not open share sqlite database"
            logger.info(message, error)
            fatalError(message)
        }
        
        do{
            try createResourceLoadingTable()
        }catch{
            let message = "create share tables failed"
            logger.info(message, error)
            fatalError(message)
        }
    }
    
    func makeShareDatabasePath() throws -> String{
        let fileName = "share.sqlite"
        let direcoty = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let url = direcoty.appendingPathComponent(fileName)
        return url.path
    }
    
    func createFileTable() throws{
        let sql = """
            create talbe if not exists file(
                id integer primary key,
                name text not null,
                extension text,
                size integer,
                digest text unique,
                "references" integer,
                description text
            );
            """
        try shareConnection.createTable(sql: sql)
    }
    
    func createResourceLoadingTable() throws{
        let sql = """
            create table if not exists resource_loading(
                id integer primary key,
                url text unique not null,
                status integer not null,
                identifier text,
                update_time integer
            )
            """
        try shareConnection.createTable(sql: sql)
    }
}
