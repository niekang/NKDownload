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
    
    
}
