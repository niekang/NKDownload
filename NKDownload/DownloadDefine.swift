//
//  DownloadDefine.swift
//  NKDownload
//
//  Created by 聂康  on 2017/5/15.
//  Copyright © 2017年 聂康. All rights reserved.
//

import UIKit


let kDownloadDirectory                = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/NKDownload"
let kResumeDataDirectory              = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/NKResumeData"

//let kTmpFileDirectory                 = NSTemporaryDirectory()
//
//let kAppleTmpFileDownloadPath         = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/com.apple.nsurlsessiond/Downloads/--.NKDownload"

//let kURLSessionResumeCurrentRequest   = "NSURLSessionResumeCurrentRequest"
//let kURLSessionResumeOriginalRequest  = "NSURLSessionResumeOriginalRequest"
//let kURLSessionResumeBytesReceived    = "NSURLSessionResumeBytesReceived"
//let kURLSessionDownloadURL            = "NSURLSessionDownloadURL"
let kURLSessionResumeInfoTempFileName = "NSURLSessionResumeInfoTempFileName"
let kURLSessionResumeInfoLocalPath    = "NSURLSessionResumeInfoLocalPath"

enum NKDownloadState:Int {
    case waiting
    case downloading
    case suspend
    case success
    case fail
}

enum NKDownloadError:Int {
    case cancelByUser
    case networkError
}
