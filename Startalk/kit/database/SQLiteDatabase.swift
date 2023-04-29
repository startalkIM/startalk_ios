//
//  SQLiteDatabase.swift
//  Startalk
//
//  Created by lei on 2023/4/21.
//

import Foundation
import SQLite3

class SQLiteDatabase{
    private var dbPointer: OpaquePointer!

    init(path: String) throws {
        let status = sqlite3_open_v2(path, &dbPointer, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX, nil)
        if status != SQLITE_OK{
            let errorMessage = errorMessage
            if dbPointer != nil{
                sqlite3_close(dbPointer)
            }
            throw SQLiteError.OpenDatabase(message: errorMessage)
        }
    }
    
    private var errorMessage: String{
        let defaultMessage = "No error message provided from sqlite."
        guard let dbPointer = dbPointer else{
            return defaultMessage
        }
        let errorPointer = sqlite3_errmsg(dbPointer)
        guard let errorPointer = errorPointer else{
            return defaultMessage
        }
        return String(cString: errorPointer)
    }
    
    private var changes: Int{
        let changes = sqlite3_changes(dbPointer)
        return Int(changes)
    }
    
    private func prepareStatement(sql: String) throws -> OpaquePointer?{
        var statement: OpaquePointer?
        let status = sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil)
        
        if status == SQLITE_OK{
            return statement
        }else{
            throw SQLiteError.Prepare(message: errorMessage)
        }
    }
    
    private func bind(statement: OpaquePointer?, values: [SQLiteBindable?]) throws {
        for i in values.indices{
            let value = values[i]
            
            let index = i + 1
            let status: Int32
            if let value = value{
                status = value.bind(statement: statement, index: Int32(index))
            }else{
                status = sqlite3_bind_null(statement, Int32(index))
            }
            if status != SQLITE_OK{
                throw SQLiteError.Bind(message: errorMessage)
            }
        }
    }
    
    func createTable(sql: String) throws{
        let statement = try prepareStatement(sql: sql)
        defer{
            sqlite3_finalize(statement)
        }
        let status = sqlite3_step(statement)
        if status != SQLITE_DONE{
            throw SQLiteError.Step(message: errorMessage)
        }
    }
    
    func insert(sql: String, values: [SQLiteBindable?]) throws{
        let statement = try prepareStatement(sql: sql)
        defer{
            sqlite3_finalize(statement)
        }
        try bind(statement: statement, values: values)
        let status = sqlite3_step(statement)
        if status != SQLITE_DONE{
            throw SQLiteError.Step(message: errorMessage)
        }
    }
    
    func batchInsert(sql: String, values: [[SQLiteBindable?]]) throws -> Int{
        let statement = try prepareStatement(sql: sql)
        defer{
            sqlite3_finalize(statement)
        }
        var count = 0
        for rowValues in values{
            try bind(statement: statement, values: rowValues)
            let status = sqlite3_step(statement)
            if status == SQLITE_DONE{
                count = count + 1
            }
            sqlite3_reset(statement)
        }
        return count
    }
    
    func update(sql: String, values: [SQLiteBindable?]) throws -> Int{
        let statement = try prepareStatement(sql: sql)
        defer{
            sqlite3_finalize(statement)
        }
        try bind(statement: statement, values: values)
        let status = sqlite3_step(statement)
        if status != SQLITE_DONE{
            throw SQLiteError.Step(message: errorMessage)
        }
        return changes
    }
    
    func query(sql: String, values: [SQLiteBindable?]) throws -> SQLiteResultSet{
        let statement = try prepareStatement(sql: sql)
        try bind(statement: statement, values: values)
        return SQLiteResultSet(statement: statement)
    }
}

enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Bind(message: String)
    case Step(message: String)
    case Query(message: String)
}

protocol SQLiteBindable{
    func bind(statement: OpaquePointer?, index: Int32) -> Int32
}

extension Int32: SQLiteBindable{
    
    func bind(statement: OpaquePointer?, index: Int32) -> Int32 {
        return sqlite3_bind_int(statement, index, self)
    }
}

extension Int64: SQLiteBindable{
    
    func bind(statement: OpaquePointer?, index: Int32) -> Int32 {
        return sqlite3_bind_int64(statement, index, self)
    }
}

extension Double: SQLiteBindable{
    
    func bind(statement: OpaquePointer?, index: Int32) -> Int32 {
        return sqlite3_bind_double(statement, index, self)
    }
}

extension String: SQLiteBindable{
    
    func bind(statement: OpaquePointer?, index: Int32) -> Int32 {
        let value = (self as NSString).utf8String
        return sqlite3_bind_text(statement, index, value, -1, nil)
    }
    
}

extension Bool: SQLiteBindable{
    func bind(statement: OpaquePointer?, index: Int32) -> Int32 {
        let value: Int32 = self ? 1 : 0
        return value.bind(statement: statement, index: index)
    }
}


class SQLiteResultSet{
    var statement: OpaquePointer?
    var columnCount: Int32
    var nameIndexDict: [String: Int32]
    
    init(statement: OpaquePointer?) {
        self.statement = statement
        
        columnCount = sqlite3_column_count(statement)
        nameIndexDict = [: ]
        for index in 0..<columnCount{
            let nameValue = sqlite3_column_name(statement, index)!
            let name = String(cString: nameValue)
            nameIndexDict[name] = index
        }
    }
    
    deinit{
        sqlite3_finalize(statement)
    }
    
    @discardableResult
    func next() -> Bool{
        let status = sqlite3_step(statement)
        return status == SQLITE_ROW
    }
    
    func getInt32(_ column: Int) throws -> Int32{
        try checkColumnIndex(column)
        return sqlite3_column_int(statement, Int32(column))
    }
    
    func getInt64(_ column: Int) throws -> Int64{
        try checkColumnIndex(column)
        return sqlite3_column_int64(statement, Int32(column))
    }
    
    func getDouble(_ column: Int) throws -> Double{
        try checkColumnIndex(column)
        return sqlite3_column_double(statement, Int32(column))
    }
    
    func getString(_ column: Int) throws -> String?{
        try checkColumnIndex(column)
        let value = sqlite3_column_text(statement, Int32(column))
        if let value = value{
            return String(cString: value)
        }else{
            return nil
        }
    }
    
    func getBool(_ column: Int) throws -> Bool{
        let value = try getInt32(column)
        return value == 1
    }
    
    func getInt32(_ name: String) throws -> Int32{
        let index = try getColumnIndex(name)
        return sqlite3_column_int(statement, Int32(index))
    }
    
    func getInt64(_ name: String) throws -> Int64{
        let index = try getColumnIndex(name)
        return sqlite3_column_int64(statement, Int32(index))
    }
    
    func getDouble(_ name: String) throws -> Double{
        let index = try getColumnIndex(name)
        return sqlite3_column_double(statement, Int32(index))
    }
    
    func getString(_ name: String) throws -> String?{
        let index = try getColumnIndex(name)
        let value = sqlite3_column_text(statement, Int32(index))
        if let value = value{
            return String(cString: value)
        }else{
            return nil
        }
    }
    
    func getBool(_ name: String) throws -> Bool{
        let value = try getInt32(name)
        return value == 1
    }
    
    private func checkColumnIndex(_ value: Int) throws{
        if value < 0 || value >= columnCount{
            throw SQLiteError.Query(message: "Invalid column index")
        }
    }
    
    private func getColumnIndex(_ name: String) throws -> Int32{
        let index = nameIndexDict[name]
        guard let index = index else{
            throw SQLiteError.Query(message: "Invalid column name")
        }
        return index
    }
}

