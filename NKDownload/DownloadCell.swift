//
//  DownloadCell.swift
//  NKDownload
//
//  Created by 聂康  on 2017/5/15.
//  Copyright © 2017年 聂康. All rights reserved.
//

import UIKit

class DownloadCell: UITableViewCell {
        
    private lazy var state = NKDownloadState.waiting
    
    @IBOutlet weak var urlLab: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var lengthLab: UILabel!
    
    @IBOutlet weak var speedLab: UILabel!
    
    @IBOutlet weak var downloadBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //FIXME:为了方便测试才这样写
        state = .suspend
    }

    @IBAction func downloadButtonClick(_ sender: Any) {
        switch state {
        case .waiting:
            state = .suspend
            downloadBtn.setTitle("暂停", for: .normal)
        case .downloading:
            state = .suspend
            downloadBtn.setTitle("暂停", for: .normal)
        case .suspend:
            state = .waiting
            downloadBtn.setTitle("等待", for: .normal)
        case .finish:
            break
        case .error:
            state = .waiting
            downloadBtn.setTitle("等待", for: .normal)
        }
    }
}
