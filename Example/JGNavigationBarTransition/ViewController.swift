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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    
    func initUI(){
        self.navigationItem.title = "\(self.navigationController!.viewControllers.count - 1) => " + barType.rawValue
        let backButtonItem:UIBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(exitClick(sender:)))
        let exitButtonItem:UIBarButtonItem = UIBarButtonItem.init(title: "exit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(backClick(sender:)))
        let nextButtonIteme:UIBarButtonItem = UIBarButtonItem.init(title: "next", style: UIBarButtonItem.Style.plain, target: self, action: #selector(nextClick(sender:)))
        self.navigationItem.setLeftBarButtonItems([backButtonItem,exitButtonItem], animated: true)
        self.navigationItem.setRightBarButton(nextButtonIteme, animated: true)
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
        //设置导航栏颜色
        let red = CGFloat(arc4random()%256)/255.0
        let green = CGFloat(arc4random()%256)/255.0
        let blue = CGFloat(arc4random()%256)/255.0
        
        self.jg_navBarBarTintColor = UIColor(red: red, green: green, blue: blue, alpha: 0.6)
        //        //设置标题颜色
        //        if ((self.navigationController?.viewControllers.count ?? 0) % 2) == 0 {
        //            self.jg_navBarTitleColor = UIColor.white
        //        }
        //        else {
        //            self.jg_navBarTitleColor = UIColor.black
        //        }
        //        //设置主题颜色
        //        if ((self.navigationController?.viewControllers.count ?? 0) % 2) == 0 {
        //            self.jg_navBarTintColor = UIColor.black
        //        }
        //        else {
        //            self.jg_navBarTintColor = UIColor.white
        //        }
        //        //设置透明度
        //        if ((self.navigationController?.viewControllers.count ?? 0) % 2) == 0 {
        //            self.jg_navBarBackgroundAlpha = 1
        //        }
        //        else {
        //            self.jg_navBarBackgroundAlpha = 0
        //        }
        //设置背景图片
        //        if ((self.navigationController?.viewControllers.count ?? 0) % 2) == 0 {
        //            self.jg_navBarBackgroundImage = UIImage.init(named: "1")
        //        }
        //        else {
        //            self.jg_navBarBackgroundImage = UIImage.init(named: "1024")
        //        }
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

