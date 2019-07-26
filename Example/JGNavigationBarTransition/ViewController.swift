//
//  ViewController.swift
//  JGNavigationBarTransition
//
//  Created by lbj147123@163.com on 07/10/2019.
//  Copyright (c) 2019 lbj147123@163.com. All rights reserved.
//

import UIKit
import JGNavigationBarTransition

enum NavigationBarType:String {
    case barTintColor = "barTintColor"
    case titleColor = "titleColor"
    case tintColor = "tintColor"
    case backgroundAlpha = "backgroundAlpha"
    case statusBarStyle = "statusBarStyle"
    case shadowImage = "shadowImage"
}

class ViewController: UIViewController {
    
    var controllerType:Int = 0   // 0:常用类型控制器；1:自定义类型控制器
    var barType:NavigationBarType = .barTintColor
    var dataSource:[String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.initUI()
    }
    
    func initData(){
        self.dataSource = [
            "2007年1月9日苹果公司在Macworld展览会上公布，随后于同年的6月发布第一版iOS操作系统，最初的名称为“iPhone Runs OS X”。",
            "2007年10月17日，苹果公司发布了第一个本地化iPhone应用程序开发包（SDK），并且计划在2月发送到每个开发者以及开发商手中。",
            "2008年3月6日，苹果发布了第一个测试版开发包，并且将“iPhone runs OS X”改名为“iPhone OS”。",
            "2008年9月，苹果公司将iPod touch的系统也换成了”iPhone OS“。",
            "2010年2月27日，苹果公司发布iPad，iPad同样搭载了”iPhone OS”。这年，苹果公司重新设计了“iPhone OS”的系统结构和自带程序。",
            "2010年6月，苹果公司将“iPhone OS”改名为“iOS”，同时还获得了思科iOS的名称授权。",
            "2010年第四季度，苹果公司的iOS占据了全球智能手机操作系统26%的市场份额。",
            "2011年10月4日，苹果公司宣布iOS平台的应用程序已经突破50万个。",
            "2012年2月，应用总量达到552,247个，其中游戏应用最多，达到95,324个，比重为17.26%;书籍类以60,604个排在第二，比重为10.97%;娱乐应用排在第三，总量为56,998个，比重为10.32%。",
            "2012年6月，苹果公司在WWDC 2012上宣布了iOS 6，提供了超过 200 项新功能。",
            "2013年6月10日，苹果公司在WWDC 2013上发布了iOS 7，几乎重绘了所有的系统APP，去掉了所有的仿实物化，整体设计风格转为扁平化设计。将于2013年秋正式开放下载更新。",
            "2013年9月10日，苹果公司在2013秋季新品发布会上正式提供iOS 7下载更新。",
            "2014年6月3日（西八区时间2014年6月2日），苹果公司在WWDC 2014上发布了iOS 8，并提供了开发者预览版更新。",
            "2018年9月13日，2018苹果秋季新品发布会上，苹果CEO库克介绍了苹果生态的一些数据。他表示，搭载苹果iOS系统设备已达20亿部。"]
    }
    
    func initUI(){
        self.navigationItem.title = "\(self.navigationController!.viewControllers.count - 1) => " + barType.rawValue
        let backButtonItem:UIBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(backClick(sender:)))
        let exitButtonItem:UIBarButtonItem = UIBarButtonItem.init(title: "exit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(exitClick(sender:)))
        let nextButtonIteme:UIBarButtonItem = UIBarButtonItem.init(title: "next", style: UIBarButtonItem.Style.plain, target: self, action: #selector(nextClick(sender:)))
        self.navigationItem.setLeftBarButtonItems([backButtonItem,exitButtonItem], animated: true)
        self.navigationItem.setRightBarButton(nextButtonIteme, animated: true)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        
        if controllerType == 0{
            //常用方式
            self.navigationBarCommon()
        }
        else {
            //自定义方式
            self.navigationBarCustom()
        }
    }
    
    func navigationBarCommon(){
        switch barType {
        case .barTintColor:
            //设置导航栏颜色
            let red = CGFloat(arc4random()%256)/255.0
            let green = CGFloat(arc4random()%256)/255.0
            let blue = CGFloat(arc4random()%256)/255.0
            self.jg_navBarBarTintColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
        case .titleColor:
            //设置标题颜色
            let red = CGFloat(arc4random()%256)/255.0
            let green = CGFloat(arc4random()%256)/255.0
            let blue = CGFloat(arc4random()%256)/255.0
            self.jg_navBarTitleColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
        case .tintColor:
            //设置主题颜色
            let red = CGFloat(arc4random()%256)/255.0
            let green = CGFloat(arc4random()%256)/255.0
            let blue = CGFloat(arc4random()%256)/255.0
            self.jg_navBarTintColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
        case .backgroundAlpha:
            //设置透明度
            if ((self.navigationController?.viewControllers.count ?? 0) % 3) == 2 {
                self.jg_navBarBackgroundAlpha = 1
            }
            else if ((self.navigationController?.viewControllers.count ?? 0) % 3) == 0 {
                self.jg_navBarBackgroundAlpha = 0.5
            }
            else{
                self.jg_navBarBackgroundAlpha = 0
            }
        case .statusBarStyle:
            //设置状态栏
            if ((self.navigationController?.viewControllers.count ?? 0) % 2) == 0 {
                self.jg_statusBarStyle = .lightContent
                self.jg_navBarBarTintColor = .red
                self.jg_navBarTitleColor = .white
            }
            else{
                self.jg_statusBarStyle = .default
                self.jg_navBarBarTintColor = .white
                self.jg_navBarTitleColor = .black
            }
        case .shadowImage:
            //设置阴影分割线
            if ((self.navigationController?.viewControllers.count ?? 0) % 2) == 0 {
                self.jg_navBarShadowImageHidden = true
            }
            else if ((self.navigationController?.viewControllers.count ?? 0) % 2) == 1  {
                self.jg_navBarShadowImageHidden = false
            }
        }
        
    }
    func navigationBarCustom(){
        
    }
    
    @objc func backClick(sender:Any){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func exitClick(sender:Any){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func nextClick(sender:Any){
        //通用控制器
        let storyBoard:UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc:ViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        vc.controllerType = self.controllerType
        vc.barType = self.barType
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func oldFunc() {

        //          //设置状态栏
        //          if ((self.navigationController?.viewControllers.count ?? 0) % 3) == 0 {
        //             self.jg_statusBarStyle = .default
        //          }
        //          else if ((self.navigationController?.viewControllers.count ?? 0) % 3) == 1  {
        //              self.jg_statusBarStyle = .lightContent
        //          }
        //        self.jg_navBarBarTintColor = UIColor.white
        //        self.navigationController?.navigationBar.shadowImage = UIImage.init(named: "1")
        //        //设置状态栏
        //        if ((self.navigationController?.viewControllers.count ?? 0) % 2) == 0 {
        //            self.jg_navBarShadowImageHidden = true
        //        }
        //        else if ((self.navigationController?.viewControllers.count ?? 0) % 2) == 1  {
        //            self.jg_navBarShadowImageHidden = false
        //        }
    }
}

extension ViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "cellKey"
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: cellId)
        }
        if let textLabel:UILabel = cell?.viewWithTag(101) as? UILabel {
            textLabel.text = self.dataSource[indexPath.row]
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
    }
    
}
extension ViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
