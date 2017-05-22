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
    var urlString:String
    
    var resumeData:Data? {
        
        return try? Data(contentsOf: resumeDataURL)
    }
    
    var fileURL:URL{
        return URL(fileURLWithPath: kDownloadDirectory + "/" + task.currentRequest!.url!.lastPathComponent)
    }
    
    var resumeDataURL:URL{
        return URL(fileURLWithPath: kResumeDataDirectory + "/" + task.currentRequest!.url!.lastPathComponent.components(separatedBy: ".").first!)
    }
    
    init(sessionDownloadTask:URLSessionDownloadTask) {
        task = sessionDownloadTask
        urlString = sessionDownloadTask.currentRequest!.url!.absoluteString
        super.init()
    }
    
    
}

extension NKDownloadTask{
    
    func saveResumeData(data:Data?){
        guard let data = data else {
            return
        }
        try? data.write(to:resumeDataURL)
    }
    
}
