//
//  DownloadSqlite.swift
//  NKDownload
//
//  Created by 聂康  on 2017/5/16.
//  Copyright © 2017年 聂康. All rights reserved.
//

import FMDB

final class DownloadSqlite: NSObject {
    
    static let manager = DownloadSqlite()
    
    let queue:FMDatabaseQueue
    
    private override init() {
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                       .userDomainMask, true).first! + "/download.sqlite"
        queue = FMDatabaseQueue(path: path)
    }
}

extension DownloadSqlite{
    func createTable(){
        queue.inDatabase { (db) in
            let create = "CREATE TABLE IF NOT EXISTS T_Download (url TEXT NOT NULL, currentSize INTEGER NOT NULL, totalSize INTEGER NOT NULL, state INTEGER NOT NULL);"
            if db?.executeStatements(create) == true{
                print("建表成功")
            }else{
                print("建表失败")
            }
        }
    }
    
    func insertData(arguments:[Any]){
        queue.inDatabase { (db) in
            let insert = "INSERT INTO T_Download (url, currentSize, totalSize, state) values (?, ?, ?, ?);"
            if db?.executeUpdate(insert, withArgumentsIn:arguments) == true{
                print("插入下载任务成功")
            }else{
                print("插入下载任务失败")
            }
        }
    }
    
    func updateState(arguments:[Any]){
        queue.inDatabase { (db) in
            let updateState = "UPDATE T_Download SET state = ? WHERE url = ?;"
            if db?.executeUpdate(updateState, withArgumentsIn: arguments) == true {
                print("更新下载状态成功")
            }else{
                print("更新下载状态失败")
            }
        }
    }
    
    func updateData(arguments:[Any]){
        queue.inDatabase { (db) in
            let updateData = "UPDATE T_Download SET currentSize = ? , totalSize = ? WHERE url = ?;"
            if db?.executeUpdate(updateData, withArgumentsIn: arguments) == true {
                print("更新下载进度成功")
            }else{
                print("更新下载进度失败")
            }
        }
    }
    
    func selectData(arguments:[Any]? = nil) -> [DownloadObject]{
        
        var result = [DownloadObject]()
        
        if let arguments = arguments {
            queue.inDatabase({ [weak self] (db) in
                let selecct = "SELECT * FROM T_Download WHERE state = ?;"
                guard let set = db?.executeQuery(selecct, withArgumentsIn: arguments) else{
                    return
                }
                while set.next(){
                    result.append((self?.downloadObjectFromSet(set: set))!)
                }
            })
        }else{
            //查询所有数据
            queue.inDatabase({ [weak self] (db) in
                let selecct = "SELECT * FROM T_Download;"
                guard let set = db?.executeQuery(selecct, withArgumentsIn: []) else {
                    return
                }
                while set.next(){
                    result.append((self?.downloadObjectFromSet(set: set))!)
                }
            })
        }
        return result
    }
    
    func downloadObjectFromSet(set:FMResultSet) -> DownloadObject {
        let downloadObject = DownloadObject()
        downloadObject.urlString = set.string(forColumn: "url")
        downloadObject.state = NKDownloadState(rawValue: set.long(forColumn: "state"))!
        downloadObject.currentSize = set.longLongInt(forColumn: "currentSize")
        downloadObject.totalSize = set.longLongInt(forColumn: "totalSize")
        return downloadObject
    }
    
    
    func isInDownloadList(urlString:String) -> Bool {
        var isIn = false
        queue.inDatabase { (db) in
            let sql = "SELECT * FROM T_Download WHERE url = ?"
            guard let set = db?.executeQuery(sql, withArgumentsIn: [urlString]) else{
                return
            }
            isIn = set.next()
        }
        return isIn
    }
    
}
