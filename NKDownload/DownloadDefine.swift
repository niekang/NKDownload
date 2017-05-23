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
