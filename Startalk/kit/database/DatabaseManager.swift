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
    
    private var connection: SQLiteConnection!
    
    func initialize(){
        
        do{
            let path = try makeDatabasePath()
            connection = try SQLiteConnection(path: path)
        }catch{
            let message = "could not open sqlite database"
            logger.info(message, error)
            fatalError(message)
        }
        
        do{
            try createUserTable()
            try createGroupTable()
            try createMessageTable()
            try createChatTable()
        }catch{
            let message = "create tables failed"
            logger.info(message, error)
            fatalError(message)
        }
    }
    
    private func makeDatabasePath() throws -> String{
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
    
    func getConnection() -> SQLiteConnection{
        connection
    }
}

extension DatabaseManager{
    private func createUserTable() throws{
        let userTableSql = """
            create table if not exists user(
                id integer primary key,
                username text not null,
                domain text not null,
                name text,
                gender integer,
                photo text,
                bio text,
                unique(username, domain)
            );
            """
        try connection.createTable(sql: userTableSql)
    }
    
    
    private func createGroupTable() throws{
        let sql = """
            create table if not exists "group"(
                id integer primary key,
                xmpp_id text,
                name text,
                photo text
            );
            """
        try connection.createTable(sql: sql)
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
        try connection.createTable(sql: sql)
        
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
        try connection.createTable(sql: sql)
    }
}
