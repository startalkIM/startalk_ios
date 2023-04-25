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
    
    private var sqliteDatabase: SQLiteDatabase!
    
    func initialize(){
        let path = makeDatabasePath()
        do{
            sqliteDatabase = try SQLiteDatabase(path: path)
        }catch{
            let message = "could not init sqlite database"
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
    
    private func makeDatabasePath() -> String{
        let username = userState.username
        let domain = serviceManager.domain
        let fullName = "\(username)@\(domain)"
        let data = fullName.data(using: .utf8)!
        let name = StringUtil.sha256(data: data)
    
        let fileName = "\(name).sqlite"
        let direcoty = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let url = direcoty.appendingPathComponent(fileName)
        return url.path
        
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
        try sqliteDatabase.createTable(sql: userTableSql)
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
        try sqliteDatabase.createTable(sql: sql)
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
        try sqliteDatabase.createTable(sql: sql)
        
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
        try sqliteDatabase.createTable(sql: sql)
    }
}

extension DatabaseManager{
    func insert(sql: String, values: SQLiteBindable?...) throws{
        try sqliteDatabase.insert(sql: sql, values: values)
    }
    
    @discardableResult
    func batchInsert(sql: String, values: [[SQLiteBindable?]]) throws -> Int{
        return try sqliteDatabase.batchInsert(sql: sql, values: values)
    }
    
    @discardableResult
    func update(sql: String, values: SQLiteBindable?...) throws -> Int{
        return try sqliteDatabase.update(sql: sql, values: values)
    }
    
    func query(sql: String, values: SQLiteBindable?...) throws -> SQLiteResultSet{
        return try sqliteDatabase.query(sql: sql, values: values)
    }
}
