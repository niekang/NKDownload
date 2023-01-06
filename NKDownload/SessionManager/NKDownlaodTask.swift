//
//  NKDownlaodTask.swift
//  NKDownload
//
//  Created by 聂康  on 2017/5/15.
//  Copyright © 2017年 聂康. All rights reserved.
//

import UIKit

class NKDownloadTaskDelegate{
    
    var task:URLSessionTask
        
    private(set) var progress = Progress()
    
    init(task: URLSessionTask) {
        self.task = task
    }
}
