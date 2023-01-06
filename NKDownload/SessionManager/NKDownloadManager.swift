//
//  NKDownloadManager.swift
//  NKDownload
//
//  Created by niekang on 2022/12/24.
//  Copyright © 2022 聂康. All rights reserved.
//

import Foundation

protocol NKDownloadManagerDelegate: NSObjectProtocol {
    func downloadTaskUpdate(taskDelegate: NKDownloadTaskDelegate)
}

class NKDownloadManager: NSObject {
    
    static let shared = NKDownloadManager()
    
    weak var delegate: NKDownloadManagerDelegate?
    
    var backgroundCompletionHandler: (() -> Void)?
    
    private (set)var session: URLSession!
    
    private var delegateQueue: OperationQueue!
    
    private var downloadQueue: OperationQueue!
    
    private var taskDelegates: [Int: NKDownloadTaskDelegate] = [:]
    
    private var downloadOperations: [String: NKDownloadOperation] = [:]

    private override init() {
        super.init()
        self.initConfiguration()
    }
    
    private func initConfiguration() {
        
        self.delegateQueue = OperationQueue()
//        self.delegateQueue.maxConcurrentOperationCount = 1
        
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.nk")
        configuration.allowsCellularAccess = true
        
        self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: self.delegateQueue)
        
        self.downloadQueue = OperationQueue()
        self.downloadQueue.maxConcurrentOperationCount = 3
    }
    
    func addDownloadTask(with urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        let operation = NKDownloadOperation(url)
        downloadOperations[urlString] = operation
        downloadQueue.addOperation(operation)
    }
    
    func startDownload(with url: URL){
        let requst = URLRequest(url: url)
        let downloadTask = session.downloadTask(with: requst)
        let delegate = NKDownloadTaskDelegate(task: downloadTask)
        add(delegate: delegate, for: downloadTask)
        downloadTask.resume()
    }
    
    func add(delegate: NKDownloadTaskDelegate, for task: URLSessionTask) {
        objc_sync_enter(self)
        taskDelegates[task.taskIdentifier] = delegate
        objc_sync_exit(self)
    }
    
    func delegateForTask(task: URLSessionTask) -> NKDownloadTaskDelegate?{
        objc_sync_enter(self)
        let delegate = taskDelegates[task.taskIdentifier]
        objc_sync_exit(self)
        return delegate
    }
    
    func removeDelegateForTask(task: URLSessionTask) {
        objc_sync_enter(self)
        taskDelegates.removeValue(forKey: task.taskIdentifier)
        objc_sync_exit(self)
    }
}

extension NKDownloadManager: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let delegate = delegateForTask(task: downloadTask) {
            delegate.progress.totalUnitCount = totalBytesExpectedToWrite
            delegate.progress.completedUnitCount = totalBytesWritten
            DispatchQueue.main.async {
                self.delegate?.downloadTaskUpdate(taskDelegate: delegate)
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        if let delegate = delegateForTask(task: downloadTask) {
            delegate.progress.totalUnitCount = expectedTotalBytes
            delegate.progress.completedUnitCount = fileOffset
            DispatchQueue.main.async {
                self.delegate?.downloadTaskUpdate(taskDelegate: delegate)
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
    }
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        backgroundCompletionHandler?()
        backgroundCompletionHandler = nil
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
}
