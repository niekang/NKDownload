//
//  NKDownlaodTask.swift
//  NKDownload
//
//  Created by 聂康  on 2017/5/15.
//  Copyright © 2017年 聂康. All rights reserved.
//

import UIKit

class NKDownloadTask: NSObject{
    
    var task:URLSessionDownloadTask?
    
    var urlString:String{
        return url.absoluteString
    }
    
    var url:URL
    
    var resumeData:Data? {
        
        return try? Data(contentsOf: resumeDataURL)
    }
    
    var fileURL:URL{
        return URL(fileURLWithPath: kDownloadDirectory + "/" + url.lastPathComponent)
    }
    
    var resumeDataURL:URL{
        return URL(fileURLWithPath: kResumeDataDirectory + "/" + url.lastPathComponent.components(separatedBy: ".").first!)
    }
    
    init(downloadURL:URL) {
        url = downloadURL
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
