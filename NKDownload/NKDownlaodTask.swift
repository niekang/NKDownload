//
//  NKDownlaodTask.swift
//  NKDownload
//
//  Created by 聂康  on 2017/5/15.
//  Copyright © 2017年 聂康. All rights reserved.
//

import UIKit

class NKDownloadTask: NSObject{
    
    var task:URLSessionDownloadTask
    
    init(sessionDownloadTask:URLSessionDownloadTask) {
        task = sessionDownloadTask
        super.init()
    }
}
