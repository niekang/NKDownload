//
//  NKDownloadManger.swift
//  NKDownload
//
//  Created by 聂康  on 2017/5/15.
//  Copyright © 2017年 聂康. All rights reserved.
//

import UIKit

class NKDownloadManger: NSObject {
    
    static let shared = NKDownloadManger()
    
    private lazy var taskArr = [NKDownloadTask]()
    
    private lazy var configuration = URLSessionConfiguration.background(withIdentifier: "com.nkdownload")
    
    lazy var session :URLSession = {
        return URLSession(configuration: self.configuration, delegate: self, delegateQueue: nil)
    }()

    private override init() {
        super.init()
        configuration.httpMaximumConnectionsPerHost = 1
        configuration.allowsCellularAccess = false
    }
    
    // MARK:添加下载任务
    func nk_addDownloadTaskWithURLString(urlString:String){
        guard let url = URL(string: urlString) else {
            print("错误的网址")
            return
        }
        let sessionDownloadTask = session.downloadTask(with: url)
        let nkDownloadTask = NKDownloadTask(sessionDownloadTask: sessionDownloadTask)
        taskArr.append(nkDownloadTask)
        sessionDownloadTask.resume()
    }
}

extension NKDownloadManger:URLSessionDownloadDelegate{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print(bytesWritten)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
    }
}
