//
//  ViewController.swift
//  NKDownload
//
//  Created by 聂康  on 2017/5/15.
//  Copyright © 2017年 聂康. All rights reserved.
//

import UIKit

class DownloadingViewController: UIViewController {

    fileprivate let reuse = "DownloadCell"

    fileprivate lazy var dataArr = [DownloadObject]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        NKDownloadManger.shared.delegate = self
        dataArr = DownloadSqlite.manager.selectData()
    }
}

extension DownloadingViewController{
    
    /// 根据url获取对应的cell
    ///
    /// - Parameter urlString: 下载url
    /// - Returns: url对应的cell
    func getCellWithURLString(urlString:String) -> DownloadCell?{
        for (index,downloadObject) in dataArr.enumerated(){
            if downloadObject.urlString == urlString {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: reuse) as! DownloadCell
        let downloadObject = dataArr[indexPath.row]
        cell.disPlayCell(object: downloadObject)
        return cell
    }

}

extension DownloadingViewController:NKDownloadMangerDelegate{
    func nk_downloadTaskStartDownload(nkDownloadTask: NKDownloadTask) {
        guard let cell = getCellWithURLString(urlString: nkDownloadTask.urlString) else {
            return
        }
        //回到主线程刷新UI
        DispatchQueue.main.async {
            cell.downloadObject.state = .downloading
            cell.downloadBtn.setTitle("下载中", for: .normal)
        }
    }
    
    /// 更新下载进度
    ///
    /// - Parameter urlString: 下载网址
    func nk_downloadTaskDidWriteData(nkDownloadTask: NKDownloadTask, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let cell = getCellWithURLString(urlString: nkDownloadTask.urlString) else {
            return
        }
        
        //回到主线程刷新UI
        DispatchQueue.main.async {
            cell.downloadObject.currentSize = totalBytesWritten
            cell.downloadObject.totalSize = totalBytesExpectedToWrite
            cell.downloadObject.state = .downloading
            cell.disPlayCell(object: cell.downloadObject)
        }
    }
    
    func nk_downloadTaskDidComleteWithError(nkDownloadTask: NKDownloadTask, error: NKDownloadError?) {
        guard let cell = getCellWithURLString(urlString: nkDownloadTask.urlString) else {
            return
        }
        //回到主线程刷新UI
        DispatchQueue.main.async {
            if let _ = error{
                if error == NKDownloadError.cancelByUser{
                    cell.downloadObject.state = .suspend
                }else if error == NKDownloadError.networkError{
                    cell.downloadObject.state = .fail
                }
            }else {
                cell.downloadObject.state = .success
            }
            cell.disPlayCell(object: cell.downloadObject)
        }

    }
}
