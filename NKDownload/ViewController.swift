//
//  ViewController.swift
//  NKDownload
//
//  Created by 聂康  on 2017/5/15.
//  Copyright © 2017年 聂康. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

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
    }
}

extension ViewController:UITableViewDelegate,UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadCell") as! DownloadCell
        cell.urlLab.text = dataArr[indexPath.row]
        
        return cell
    }

}
