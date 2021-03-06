//
//  FinishViewController.swift
//  NKDownload
//
//  Created by 聂康  on 2017/5/15.
//  Copyright © 2017年 聂康. All rights reserved.
//

import UIKit

class VideoListViewController: UITableViewController {
    fileprivate let reuse = "VideoCell"
    lazy var dataArr:[String] = {
        return ["http://source.nongguanjia.com/Z1A0013.mp4",
                "http://source.nongguanjia.com/Z1A0014.mp4",
                "http://source.nongguanjia.com/Z1A0015.mp4",
                "http://source.nongguanjia.com/Z1A0016.mp4",
                "http://source.nongguanjia.com/Z1A0017.mp4"]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100;
        tableView.rowHeight = UITableViewAutomaticDimension
    }

}

extension VideoListViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuse) as! VideoCell
        cell.urlLab.text = dataArr[indexPath.row];
        if DownloadSqlite.manager.isInDownloadList(urlString: cell.urlLab.text!){
            cell.stateLab.text = "已添加"
        }else{
            cell.stateLab.text = "添加任务"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! VideoCell
        let stateString = cell.stateLab.text!
        switch stateString{
        case "添加任务":
            NKDownloadManger.shared.nk_addDownloadTaskWithURLString(urlString: cell.urlLab.text!)
            cell.stateLab.text = "已添加"
        case "已添加":
            break
        default:
            break
        }
    }
}
