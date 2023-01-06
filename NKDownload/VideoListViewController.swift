//
//  FinishViewController.swift
//  NKDownload
//
//  Created by 聂康  on 2017/5/15.
//  Copyright © 2017年 聂康. All rights reserved.
//

import UIKit
import AVFoundation

struct Video {
    var url: String
    var id: Int
}

class VideoListViewController: UITableViewController {
    fileprivate let reuse = "VideoCell"
    lazy var dataArr:[Video] = {
        return [
            Video(url: "https://mvvideo5.meitudata.com/56ea0e90d6cb2653.mp4", id: 0),
//            Video(url: "https://mvvideo5.meitudata.com/56ea0e90d6cb2653.mp4", id: 1)
        ]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 100
        NKDownloadManager.shared.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let asset = AVAsset(url: URL(string: "https://mvvideo5.meitudata.com/56ea0e90d6cb2653.mp4")!)
        asset.loadValuesAsynchronously(forKeys: <#T##[String]#>)
    }

}

extension VideoListViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuse) as! VideoCell
        cell.urlLab.text = dataArr[indexPath.row].url
        cell.delegate = self
        return cell
    }
}

extension VideoListViewController: VideoCellDelegate {
    
    func download(cell: VideoCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        let video = dataArr[indexPath.row]
        NKDownloadManager.shared.addDownloadTask(with: video.url)
    }
}

extension VideoListViewController: NKDownloadManagerDelegate {
    
    func downloadTaskUpdate(taskDelegate: NKDownloadTaskDelegate) {
        guard let cells = tableView.visibleCells as? [VideoCell] else {
            return
        }
        for cell in cells {
            if let indexPath = tableView.indexPath(for: cell)  {
                let urlString = dataArr[indexPath.row].url
                if urlString == taskDelegate.task.originalRequest?.url?.absoluteString {
                    cell.progressView.progress = Float(taskDelegate.progress.fractionCompleted)
                }
            }
        }
    }
}
