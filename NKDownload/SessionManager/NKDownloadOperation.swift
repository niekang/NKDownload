//
//  NKDownloadOperation.swift
//  NKDownload
//
//  Created by niekang on 2022/12/24.
//  Copyright © 2022 聂康. All rights reserved.
//

import Foundation

class NKDownloadOperation: Operation {
    
    var url: URL!
    
    private var _executing: Bool = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    private var _canceled: Bool = false {
        willSet {
            willChangeValue(forKey: "isCancelled")
        }
        didSet {
            didChangeValue(forKey: "isCancelled")
        }
    }
    
    private var _finished: Bool = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    
    override var isCancelled: Bool {
        return _canceled
    }
    
    override var isFinished: Bool {
        return _finished
    }
    
    override var isConcurrent: Bool {
        return true
    }
    
    convenience init(_ url: URL) {
        self.init()
        self.url = url
    }
    
    override func start() {
        NKDownloadManager.shared.startDownload(with: url)
    }
}
