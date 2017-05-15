//
//  ViewController.swift
//  NKDownload
//
//  Created by 聂康  on 2017/5/15.
//  Copyright © 2017年 聂康. All rights reserved.
//

import UIKit

class DownloadingViewController: UIViewController {

    lazy var dataArr:[String] = {
        return ["http://source.nongguanjia.com/Z1A0013.mp4",
                "http://source.nongguanjia.com/Z1A0014.mp4",
                "http://source.nongguanjia.com/Z1A0015.mp4",
                "http://source.nongguanjia.com/Z1A0016.mp4",
                "http://source.nongguanjia.com/Z1A0017.mp4"]
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        NKDownloadManger.shared.delegate = self
    }
}

extension DownloadingViewController{
    
    /// 根据url获取对应的cell
    ///
    /// - Parameter urlString: 下载url
    /// - Returns: url对应的cell
    func getCellWithURLString(urlString:String) -> DownloadCell?{
        for (index,taskUrlStrng) in dataArr.enumerated(){
            if taskUrlStrng == urlString {
                let indexPath = IndexPath(row: index, section: 0)
                let cell = tableView.cellForRow(at: indexPath) as? DownloadCell
                return cell
            }
        }
        return nil
    }
    
}

extension DownloadingViewController:UITableViewDelegate,UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadCell") as! DownloadCell
        cell.urlLab.text = dataArr[indexPath.row]
        
        return cell
    }

}

extension DownloadingViewController:NKDownloadMangerDelegate{
    
    /// 更新下载进度
    ///
    /// - Parameter urlString: 下载网址
    func nk_downloadTaskDidWriteData(urlString: String, currenLength: Int64, totalLength: Int64) {
        guard let cell = getCellWithURLString(urlString: urlString) else {
            return
        }
        
        let progress = Float(currenLength)/Float(totalLength)
        let currentSize = Float(currenLength)/1024
        var currentSizeString = ""
        if currentSize > 1024 {
            currentSizeString = String(format: "%.2fMB", currentSize/1024)
        }else{
            currentSizeString = String(format: "%.2fKB", currentSize)
        }
        currentSizeString = currentSizeString + "/" + String(format:"%.2fMB", Float(totalLength)/1024/1024)
        //回到主线程刷新UI
        DispatchQueue.main.async {
            cell.progressView.progress = progress
            cell.lengthLab.text = currentSizeString
            cell.state = .downloading
        }
    }
}
