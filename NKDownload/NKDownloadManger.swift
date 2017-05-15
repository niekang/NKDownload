//
//  NKDownloadManger.swift
//  NKDownload
//
//  Created by 聂康  on 2017/5/15.
//  Copyright © 2017年 聂康. All rights reserved.
//

import UIKit

protocol NKDownloadMangerDelegate:NSObjectProtocol{
    func nk_downloadTaskDidWriteData(urlString:String, currenLength:Int64,totalLength:Int64)
}

class NKDownloadManger: NSObject {
    
    static let shared = NKDownloadManger()
    
    weak var delegate:NKDownloadMangerDelegate?
    
    private lazy var waitingTaskArr = [NKDownloadTask]() //下载中任务数组
    
    private lazy var downloadTaskArr = [NKDownloadTask]() //下载中任务数组
    
    private lazy var suspendTaskArr = [NKDownloadTask]() //暂停任务数组
    
    private lazy var finishTaskArr = [NKDownloadTask]() //完成任务数组

    private lazy var failTaskArr = [NKDownloadTask]() //失败任务数组

    private lazy var configuration = URLSessionConfiguration.background(withIdentifier: "com.nkdownload")
    
    lazy var session :URLSession = {
        return URLSession(configuration: self.configuration, delegate: self, delegateQueue: nil)
    }()

    private override init() {
        super.init()
        configuration.httpMaximumConnectionsPerHost = 1
        configuration.allowsCellularAccess = false
    }
    
    
    /// 添加下载任务
    ///
    /// - Parameter urlString: 添加下载任务
    func nk_addDownloadTaskWithURLString(urlString:String){
        guard let url = URL(string: urlString) else {
            print("错误的网址")
            return
        }
        let sessionDownloadTask = session.downloadTask(with: url)
        let nkDownloadTask = NKDownloadTask(sessionDownloadTask: sessionDownloadTask)
        waitingTaskArr.append(nkDownloadTask)
        nk_autoStartDownloadTaskWithURLString()
    }
    
    /// 自动开始下载任务
    func nk_autoStartDownloadTaskWithURLString(){
        if downloadTaskArr.count == 0 {
            guard let nkDownloadTask = waitingTaskArr.first else{
                return
            }
            waitingTaskArr.remove(at: 0)
            downloadTaskArr.append(nkDownloadTask)
            nkDownloadTask.task.resume()
        }
    }
    
    /// 暂停下载中任务
    ///
    /// - Parameter urlString: 任务网址
    func nk_suspendDownloadTaskWithURLString(urlString:String){
        guard let (index,nkDownloadTask) = nk_getDownloadTaskWithURLString(urlString: urlString, taskArr: downloadTaskArr) else {
            return
        }
        downloadTaskArr.remove(at: index)
        suspendTaskArr.append(nkDownloadTask)
        nkDownloadTask.task.cancel()
    }
    
    /// 暂停等待任务
    ///
    /// - Parameter urlString: 任务网址
    func nk_suspendWaitingDownloadTaskWithURLString(urlString:String){
        guard let (index,nkDownloadTask) = nk_getDownloadTaskWithURLString(urlString: urlString, taskArr: waitingTaskArr) else {
            return
        }
        nkDownloadTask.task.cancel()
        waitingTaskArr.remove(at: index)
        suspendTaskArr.append(nkDownloadTask)
    }
    
    /// 恢复暂停任务 -> 下载
    ///
    /// - Parameter urlString: 任务网址
    func nk_recoverSuspendDwonloadTaskWithURLString(urlString:String){
        guard let (index,nkDownloadTask) = nk_getDownloadTaskWithURLString(urlString: urlString, taskArr: suspendTaskArr) else {
            return
        }
        suspendTaskArr.remove(at: index)
        waitingTaskArr.append(nkDownloadTask)
        nk_autoStartDownloadTaskWithURLString()
    }
    
    /// 恢复失败任务 -> 下载
    ///
    /// - Parameter urlString: 任务网址
    func nk_recoverFailureDwonloadTaskWithURLString(urlString:String){
        guard let (index,nkDownloadTask) = nk_getDownloadTaskWithURLString(urlString: urlString, taskArr: failTaskArr) else {
            return
        }
        failTaskArr.remove(at: index)
        waitingTaskArr.append(nkDownloadTask)
        nk_autoStartDownloadTaskWithURLString()
    }

    
    /// 从下载列表中获取下载任务
    ///
    /// - Parameter urlString: 任务网址
    func nk_getDownloadTaskWithURLString(urlString:String, taskArr:[NKDownloadTask]) -> (Int,NKDownloadTask)?{
        for (index,nkDownloadTask) in taskArr.enumerated() {
            guard let taskURLString = nkDownloadTask.task.currentRequest?.url?.absoluteString
                else{
                    break
            }
            if urlString == taskURLString {
                return (index,nkDownloadTask)
            }
        }
        return nil
    }
    
}

extension NKDownloadManger:URLSessionDownloadDelegate{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        print("\(OperationQueue.current) + \(bytesWritten) + \(totalBytesWritten) +\(totalBytesExpectedToWrite)")
        guard let urlString = downloadTask.currentRequest?.url?.absoluteString else {
            return
        }
        delegate?.nk_downloadTaskDidWriteData(urlString: urlString, currenLength: totalBytesWritten, totalLength: totalBytesExpectedToWrite)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("\(error) +  \(task.description)")
    }
}
