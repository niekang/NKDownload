//
//  DownloadCell.swift
//  NKDownload
//
//  Created by 聂康  on 2017/5/15.
//  Copyright © 2017年 聂康. All rights reserved.
//

import UIKit

class DownloadObject: NSObject {
    var urlString:String?
    var currentSize:Int64 = 0
    var totalSize:Int64 = 0
    var state:NKDownloadState = .waiting
}

class DownloadCell: UITableViewCell {
        
    lazy var downloadObject = DownloadObject()
    
    @IBOutlet weak var urlLab: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var lengthLab: UILabel!
    
    @IBOutlet weak var speedLab: UILabel!
    
    @IBOutlet weak var downloadBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        speedLab.isHidden = true
    }
    
    func disPlayCell(object:DownloadObject){
        downloadObject = object
        let progress = (downloadObject.totalSize == 0) ? 0 : (Float(downloadObject.currentSize)/Float(downloadObject.totalSize))
        let currentSize = Float(downloadObject.currentSize)/1024
        var currentSizeString = ""
        if currentSize > 1024 {
            currentSizeString = String(format: "%.2fMB", currentSize/1024) + "/" + String(format:"%.2fMB", Float(downloadObject.totalSize)/1024/1024)
        }else{
            currentSizeString = String(format: "%.2fKB", currentSize) + "/" + String(format:"%.2fMB", Float(downloadObject.totalSize)/1024/1024)
        }
        
        urlLab.text = object.urlString
        progressView.progress = progress
        lengthLab.text = currentSizeString

        switch downloadObject.state {
        case .waiting:
            downloadBtn.setTitle("等待", for: .normal)
        case .downloading:
            downloadBtn.setTitle("下载中", for: .normal)
        case .suspend:
            downloadBtn.setTitle("暂停", for: .normal)
        case .success:
            downloadBtn.setTitle("完成", for: .normal)
        case .fail:
            downloadBtn.setTitle("下载失败", for: .normal)
        }
    }

    @IBAction func downloadButtonClick(_ sender: Any) {
        
        switch downloadObject.state {
            
        case .waiting:
            downloadObject.state = .suspend
            downloadBtn.setTitle("暂停", for: .normal)
            NKDownloadManger.shared.nk_suspendWaitingDownloadTaskWithURLString(urlString: urlLab.text!)
            
        case .downloading:
            downloadObject.state = .suspend
            downloadBtn.setTitle("暂停", for: .normal)
            NKDownloadManger.shared.nk_suspendCurrentDownloadTaskWithURLString(urlString: urlLab.text!)
            
        case .suspend:
            downloadObject.state = .waiting
            downloadBtn.setTitle("等待", for: .normal)
            NKDownloadManger.shared.nk_recoverDwonloadTaskWithURLString(urlString: urlLab.text!)
            
        case .success:
            break
            
        case .fail:
            downloadObject.state = .waiting
            NKDownloadManger.shared.nk_recoverDwonloadTaskWithURLString(urlString: urlLab.text!)
            downloadBtn.setTitle("等待", for: .normal)
        }
    }
    
}
