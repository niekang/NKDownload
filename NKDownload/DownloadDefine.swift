//
//  DownloadDefine.swift
//  NKDownload
//
//  Created by 聂康  on 2017/5/15.
//  Copyright © 2017年 聂康. All rights reserved.
//

import UIKit

enum NKDownloadState:Int {
    case waiting
    case downloading
    case suspend
    case finish
    case error
}
