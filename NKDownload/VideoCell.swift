//
//  VideoCell.swift
//  NKDownload
//
//  Created by 聂康  on 2017/5/15.
//  Copyright © 2017年 聂康. All rights reserved.
//

import UIKit

protocol VideoCellDelegate: NSObjectProtocol {
    func download(cell: VideoCell)
}

class VideoCell: UITableViewCell {

    @IBOutlet weak var titleLab: UILabel!
    
    @IBOutlet weak var urlLab: UILabel!
    
    @IBOutlet weak var downloadBtn: UIButton!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    weak var delegate: VideoCellDelegate?

    @IBAction func download(_ sender: UIButton) {
        delegate?.download(cell: self)
    }
}
