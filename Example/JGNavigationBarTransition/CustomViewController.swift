//
//  CommonViewController.swift
//  JGNavigationBarTransition_Example
//
//  Created by 李保君 on 2019/7/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import JGNavigationBarTransition

class CustomViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    
    func initUI() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //默认设置
        self.jg_navBarBarTintColor = UIColor.red
        self.jg_navBarTitleColor = UIColor.black
        self.jg_navBarTintColor = .blue
        //self.jg_navBarBackgroundAlpha = 1
        self.jg_statusBarStyle = .default
        self.jg_navBarShadowImageHidden = false
    }
}

extension CustomViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "cellId"
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: cellId)
            cell!.accessoryType = .disclosureIndicator
        }
        cell?.textLabel?.text = "渐变导航栏：\(indexPath.row)_JGNavigationBarTransition"
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if offsetY <= -88 {
            self.jg_navBarBackgroundAlpha = 1
        }
        else {
            self.jg_navBarBackgroundAlpha = CGFloat((300.0 - (offsetY + 88.0))/300.0)
        }
    }
    
}
