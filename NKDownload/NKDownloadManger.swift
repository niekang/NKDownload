//
//  NKDownloadManger.swift
//  NKDownload
//
//  Created by 聂康  on 2017/5/15.
//  Copyright © 2017年 聂康. All rights reserved.
//

import UIKit

protocol NKDownloadMangerDelegate:NSObjectProtocol{
    
    func nk_downloadTaskStartDownload(nkDownloadTask:NKDownloadTask)//添加到downloadTaskArr中调用resume()
    
    func nk_downloadTaskDidWriteData(nkDownloadTask:NKDownloadTask, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)//下载进度更新
    
    func nk_downloadTaskDidComleteWithError(nkDownloadTask:NKDownloadTask,error:NKDownloadError?)//下载成功或失败
}

class NKDownloadManger: NSObject {
    
    static let shared = NKDownloadManger()
    
    weak var delegate:NKDownloadMangerDelegate?
    
    fileprivate lazy var waitingTaskArr = [NKDownloadTask]() //下载中任务数组
    
    fileprivate lazy var downloadTaskArr = [NKDownloadTask]() //下载中任务数组
    
    fileprivate lazy var cancelTaskArr = [NKDownloadTask]() //取消的任务数组（包括暂停和失败的任务）
    
    fileprivate lazy var finishTaskArr = [NKDownloadTask]() //完成任务数组

    fileprivate lazy var configuration = URLSessionConfiguration.background(withIdentifier: "com.nkDownload")
    
    var session = URLSession()

    private override init() {
        super.init()
        
        createDownloadDirectory()
        DownloadSqlite.manager.createTable()
        loadDownloadDataFromLocal()
        
        configuration.httpMaximumConnectionsPerHost = 1
        configuration.allowsCellularAccess = false
        configuration.isDiscretionary = true
        configuration.timeoutIntervalForRequest = 60
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)

    }
    
    //加载本地下载任务数据
    func loadDownloadDataFromLocal(){
        let downloadObjectArr = DownloadSqlite.manager.selectData()
        for downloadObject in downloadObjectArr {
            let nkDownloadTask = NKDownloadTask(downloadURL: URL(string: downloadObject.urlString!)!)
            switch downloadObject.state {
            case .downloading:
                //MARK:上次下载任务中若有状态为正在下载的任务,说明任务还在下载时app被杀死了
                downloadTaskArr.append(nkDownloadTask)
            case .waiting:
                waitingTaskArr.append(nkDownloadTask)
            case .fail,.suspend:
                cancelTaskArr.append(nkDownloadTask)
            case .success:
                finishTaskArr.append(nkDownloadTask)
            }
        }
    }
    
    /// 创建下载文件夹、resumeData文件夹
    func createDownloadDirectory(){
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: kDownloadDirectory) {
            try? fileManager.createDirectory(atPath: kDownloadDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        if !fileManager.fileExists(atPath: kResumeDataDirectory) {
            try? fileManager.createDirectory(atPath: kResumeDataDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
}

//MARK:下载相关函数
extension NKDownloadManger{

    /// 添加下载任务
    ///
    /// - Parameter urlString: 添加下载任务
    func nk_addDownloadTaskWithURLString(urlString:String){
        guard let url = URL(string: urlString) else {
            print("错误的网址")
            return
        }
        let nkDownloadTask = NKDownloadTask(downloadURL: url)
        waitingTaskArr.append(nkDownloadTask)
        //插入数据库
        DownloadSqlite.manager.insertData(arguments: [urlString, 0, 0, NKDownloadState.waiting])
        //自动判断是否开始下载
        nk_autoStartDownloadTaskWithURLString()
    }
    
    
    /// 暂停当前任务
    ///
    /// - Parameter urlString: 任务网址
    func nk_suspendCurrentDownloadTaskWithURLString(urlString:String){
        guard let (index,nkDownloadTask) = nk_getDownloadTaskWithURLString(urlString: urlString, taskArr: downloadTaskArr) else {
            return
        }
        print("暂停下载------------")
        downloadTaskArr.remove(at: index)
        cancelTaskArr.append(nkDownloadTask)
        nkDownloadTask.task?.cancel { [weak nkDownloadTask] (data) in
            nkDownloadTask?.saveResumeData(data: data)
        }
        DownloadSqlite.manager.updateState(arguments: [NKDownloadState.suspend,urlString]);

    }
    
    /// 暂停等待任务
    ///
    /// - Parameter urlString: 任务网址
    func nk_suspendWaitingDownloadTaskWithURLString(urlString:String){
        guard let (index,nkDownloadTask) = nk_getDownloadTaskWithURLString(urlString: urlString, taskArr: waitingTaskArr) else {
            return
        }
        waitingTaskArr.remove(at: index)
        cancelTaskArr.append(nkDownloadTask)
        DownloadSqlite.manager.updateState(arguments: [NKDownloadState.suspend,urlString]);
    }
    
    /// 恢复取消任务 -> 下载
    ///
    /// - Parameter urlString: 任务网址
    func nk_recoverDwonloadTaskWithURLString(urlString:String){
        guard let (index,nkDownloadTask) = nk_getDownloadTaskWithURLString(urlString: urlString, taskArr: cancelTaskArr)
            else {
            return
        }
        cancelTaskArr.remove(at: index)
        waitingTaskArr.append(nkDownloadTask)
        DownloadSqlite.manager.updateState(arguments: [NKDownloadState.waiting.rawValue, nkDownloadTask.urlString])
        nk_autoStartDownloadTaskWithURLString()
    }
    
    
    /// 从下载列表中获取下载任务
    ///
    /// - Parameter urlString: 任务网址
    fileprivate func nk_getDownloadTaskWithURLString(urlString:String, taskArr:[NKDownloadTask] ,
                                                     fromCancel:((Bool)->())? = nil) -> (Int,NKDownloadTask)?{
        for (index,nkDownloadTask) in taskArr.enumerated() {
            if urlString == nkDownloadTask.urlString {
                return (index,nkDownloadTask)
            }
        }
        
        //MARK:有一种情况: 用户手动暂停了下载中任务，因为先将任务从downloadTaskArr中移除了，所以未在找到，需要从cancelTaskArr中找
        for (index,nkDownloadTask) in cancelTaskArr.enumerated() {
            if urlString == nkDownloadTask.urlString {
                if let fromCancel = fromCancel {
                    fromCancel(true)
                }
                return (index,nkDownloadTask)
            }
        }
    
        return nil
    }
    
    /// 是否应该立即开始下载
    fileprivate func nk_autoStartDownloadTaskWithURLString(){
        if downloadTaskArr.count == 0 {
            guard let nkDownloadTask = waitingTaskArr.first else{
                return
            }
            waitingTaskArr.remove(at: 0)
            downloadTaskArr.append(nkDownloadTask)
            startNKDownloadTask(nkDownloadTask: nkDownloadTask)
        }
    }
    
    //开始下载
    fileprivate func startNKDownloadTask(nkDownloadTask:NKDownloadTask){
        //更新状态
        DownloadSqlite.manager.updateState(arguments: [NKDownloadState.downloading.rawValue, nkDownloadTask.urlString])
        if let resumeData = nkDownloadTask.resumeData {
            nkDownloadTask.task = session.correctedDownloadTask(withResumeData: resumeData)
        }else{
            nkDownloadTask.task = session.downloadTask(with: URL(string: nkDownloadTask.urlString)!)
        }
        nkDownloadTask.task!.resume()
    }
}

extension NKDownloadManger:URLSessionDownloadDelegate{

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        print("\(downloadTask) + \(bytesWritten) + \(totalBytesWritten) +\(totalBytesExpectedToWrite)")
        
        guard let urlString = downloadTask.currentRequest?.url?.absoluteString,
            let (_, nkDownloadTask) = nk_getDownloadTaskWithURLString(urlString: urlString, taskArr: downloadTaskArr)
            else {
            return
        }
        DownloadSqlite.manager.updateData(arguments: [totalBytesWritten, totalBytesExpectedToWrite, nkDownloadTask.urlString])
        delegate?.nk_downloadTaskDidWriteData(nkDownloadTask: nkDownloadTask, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let urlString = downloadTask.currentRequest?.url?.absoluteString,
            let (_,nkDownloadTask) = nk_getDownloadTaskWithURLString(urlString: urlString, taskArr: downloadTaskArr) else {
                return
        }
        
        try? FileManager.default.moveItem(at: location, to: nkDownloadTask.fileURL)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        var isCancelTask = false // 用来判断当前任务是否是用户主动暂停，已经主动移入取消数组中
        guard let urlString = task.currentRequest?.url?.absoluteString,
            let (index, nkDownloadTask) = nk_getDownloadTaskWithURLString(urlString: urlString, taskArr: downloadTaskArr, fromCancel: { (isDownloading) in
                isCancelTask = isDownloading
            })else {
                return
        }
        
        if let nsError = (error as NSError?) {
            if !isCancelTask{
                cancelTaskArr.append(nkDownloadTask)
                downloadTaskArr.remove(at: index)
            }
            DownloadSqlite.manager.updateState(arguments: [nsError.code == -999 ? NKDownloadState.suspend.rawValue:NKDownloadState.fail.rawValue, nkDownloadTask.urlString])
            
            delegate?.nk_downloadTaskDidComleteWithError(nkDownloadTask: nkDownloadTask, error:nsError.code == -999 ? NKDownloadError.cancelByUser : NKDownloadError.networkError)
            
            //保存resumeData
            let data = nsError.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
            nkDownloadTask.saveResumeData(data: data)

        }else{
            if isCancelTask {
                cancelTaskArr.remove(at: index)
            }else{
                downloadTaskArr.remove(at: index)
            }
            finishTaskArr.append(nkDownloadTask)
            DownloadSqlite.manager.updateState(arguments: [NKDownloadState.success.rawValue, nkDownloadTask.urlString])
            
            print("下载成功")
            delegate?.nk_downloadTaskDidComleteWithError(nkDownloadTask: nkDownloadTask, error:nil)
        }
        
        session.getTasksWithCompletionHandler { (_, _, downloadTasks) in
            print(downloadTasks)
        }
        nk_autoStartDownloadTaskWithURLString()
    }
}

//MARK:兼容iOS 10 获取正确的下载任务
fileprivate extension URLSession {
    func correctedDownloadTask(withResumeData resumeData: Data) -> URLSessionDownloadTask {
        let kResumeCurrentRequest = "NSURLSessionResumeCurrentRequest"
        let kResumeOriginalRequest = "NSURLSessionResumeOriginalRequest"
        
        let cData = correctResumeData(data: resumeData) ?? resumeData
        let task = self.downloadTask(withResumeData: cData)
        
        if let resumeDic = resumeDataDictionary(data: cData) {
            if task.originalRequest == nil, let originalReqData = resumeDic[kResumeOriginalRequest] as? Data, let originalRequest = NSKeyedUnarchiver.unarchiveObject(with: originalReqData) as? NSURLRequest {
                task.setValue(originalRequest, forKey: "originalRequest")
            }
            if task.currentRequest == nil, let currentReqData = resumeDic[kResumeCurrentRequest] as? Data, let currentRequest = NSKeyedUnarchiver.unarchiveObject(with: currentReqData) as? NSURLRequest {
                task.setValue(currentRequest, forKey: "currentRequest")
            }
        }
        
        return task
    }
    
    
    func resumeDataDictionary(data:Data) -> NSMutableDictionary?{
        var iresumeDictionary: NSMutableDictionary? = nil
        if #available(iOS 10.0, *) {
            var root : AnyObject? = nil
            print(data)
            let keyedUnarchiver = NSKeyedUnarchiver(forReadingWith: data)
            do {
                root = try keyedUnarchiver.decodeTopLevelObject(forKey: "NSKeyedArchiveRootObjectKey") ?? nil
                if root == nil {
                    root = try keyedUnarchiver.decodeTopLevelObject(forKey: NSKeyedArchiveRootObjectKey)
                }
            } catch {
                print(error)
            }
            keyedUnarchiver.finishDecoding()
            iresumeDictionary = root as? NSMutableDictionary
        }
        
        if iresumeDictionary == nil {
            do {
                iresumeDictionary = try PropertyListSerialization.propertyList(from: data, options: PropertyListSerialization.ReadOptions(), format: nil) as? NSMutableDictionary;
            } catch {
                print(error)
            }
        }
        
        return iresumeDictionary
    }
    
    func correctResumeData(data:Data?) -> Data?{
        let kResumeCurrentRequest = "NSURLSessionResumeCurrentRequest"
        let kResumeOriginalRequest = "NSURLSessionResumeOriginalRequest"
        
        guard let data = data, let resumeDictionary = resumeDataDictionary(data: data) else {
            return nil
        }
        
        resumeDictionary[kResumeCurrentRequest] = correctRequestData(data: resumeDictionary[kResumeCurrentRequest] as? Data)
        resumeDictionary[kResumeOriginalRequest] = correctRequestData(data: resumeDictionary[kResumeOriginalRequest] as? Data)
        
        let result = try? PropertyListSerialization.data(fromPropertyList: resumeDictionary, format: PropertyListSerialization.PropertyListFormat.xml, options: PropertyListSerialization.WriteOptions())
        return result
    }
    
    func correctRequestData(data:Data?) -> Data?{
        //关于iOS 10之后获取正确的resumeData:http://stackoverflow.com/questions/39346231/resume-nsurlsession-on-ios10/39347461#39347461
        
        guard let data = data else {
            return nil
        }
        if NSKeyedUnarchiver.unarchiveObject(with: data) != nil {
            return data
        }
        guard let archive = (try? PropertyListSerialization.propertyList(from: data, options: [.mutableContainersAndLeaves], format: nil)) as? NSMutableDictionary else {
            return nil
        }
        var k = 0
        while ((archive["$objects"] as? NSArray)?[1] as? NSDictionary)?.object(forKey: "$\(k)") != nil {
            k += 1
        }
        var i = 0
        while ((archive["$objects"] as? NSArray)?[1] as? NSDictionary)?.object(forKey: "__nsurlrequest_proto_prop_obj_\(i)") != nil {
            let arr = archive["$objects"] as? NSMutableArray
            if let dic = arr?[1] as? NSMutableDictionary, let obj = dic["__nsurlrequest_proto_prop_obj_\(i)"] {
                dic.setObject(obj, forKey: "$\(i + k)" as NSString)
                dic.removeObject(forKey: "__nsurlrequest_proto_prop_obj_\(i)")
                arr?[1] = dic
                archive["$objects"] = arr
            }
            i += 1
        }
        if ((archive["$objects"] as? NSArray)?[1] as? NSDictionary)?.object(forKey: "__nsurlrequest_proto_props") != nil {
            let arr = archive["$objects"] as? NSMutableArray
            if let dic = arr?[1] as? NSMutableDictionary, let obj = dic["__nsurlrequest_proto_props"] {
                dic.setObject(obj, forKey: "$\(i + k)" as NSString)
                dic.removeObject(forKey: "__nsurlrequest_proto_props")
                arr?[1] = dic
                archive["$objects"] = arr
            }
        }
        if let obj = (archive["$top"] as? NSMutableDictionary)?.object(forKey: "NSKeyedArchiveRootObjectKey") as AnyObject? {
            (archive["$top"] as? NSMutableDictionary)?.setObject(obj, forKey: NSKeyedArchiveRootObjectKey as NSString)
            (archive["$top"] as? NSMutableDictionary)?.removeObject(forKey: "NSKeyedArchiveRootObjectKey")
        }
        let result = try? PropertyListSerialization.data(fromPropertyList: archive, format: PropertyListSerialization.PropertyListFormat.binary, options: PropertyListSerialization.WriteOptions())
        return result
    }

}
