//
//  CommonViewController.swift
//  JGNavigationBarTransition_Example
//
//  Created by 李保君 on 2019/7/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import JGNavigationBarTransition

class CommonViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    
    func initUI() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //默认设置
        self.jg_navBarBarTintColor = UIColor.white
        self.jg_navBarTitleColor = UIColor.black
        self.jg_navBarTintColor = .blue
        self.jg_navBarBackgroundAlpha = 1
        self.jg_statusBarStyle = .default
        self.jg_navBarShadowImageHidden = false
    }
}

extension CommonViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "cellId"
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: cellId)
            cell!.accessoryType = .disclosureIndicator
        }
        
        switch indexPath.row {
        case 0:
            cell?.textLabel?.text = "导航栏颜色 -> BarTintColor"
        case 1:
            cell?.textLabel?.text = "标题颜色 -> TitleColor"
        case 2:
            cell?.textLabel?.text = "导航栏主题颜色 -> TintColor"
        case 3:
            cell?.textLabel?.text = "导航栏透明度 -> BackgroundAlpha"
        case 4:
            cell?.textLabel?.text = "导航栏状态栏 -> StatusBarStyle"
        case 5:
            cell?.textLabel?.text = "导航栏底部阴影 -> ShadowImage"
        default:
            break
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //通用控制器
        let storyBoard:UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc:ViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        vc.controllerType = 0
        switch indexPath.row {
        case 0:
            vc.barType = .barTintColor
        case 1:
            vc.barType = .titleColor
        case 2:
            vc.barType = .tintColor
        case 3:
            vc.barType = .backgroundAlpha
        case 4:
            vc.barType = .statusBarStyle
        case 5:
            vc.barType = .shadowImage
        default:
            break
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
