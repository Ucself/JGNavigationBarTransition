//
//  ViewController.swift
//  JGNavigationBarTransition
//
//  Created by lbj147123@163.com on 07/10/2019.
//  Copyright (c) 2019 lbj147123@163.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var button: UIButton!
    var count:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.count = self.navigationController?.viewControllers.count ?? 0
        self.title = "这是第\(count)控制器"
        button.setTitle("按钮\(count)", for: UIControl.State.normal)
//        //设置导航栏颜色
//        let red = CGFloat(arc4random()%256)/255.0
//        let green = CGFloat(arc4random()%256)/255.0
//        let blue = CGFloat(arc4random()%256)/255.0
//
//        self.jg_navBarBarTintColor = UIColor(red: red, green: green, blue: blue, alpha: 0.6)
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
          //设置状态栏
          if ((self.navigationController?.viewControllers.count ?? 0) % 3) == 0 {
             self.jg_statusBarStyle = .default
          }
          else if ((self.navigationController?.viewControllers.count ?? 0) % 3) == 1  {
              self.jg_statusBarStyle = .lightContent
          }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonClick(_ sender: Any) {
        let storyBoard:UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc:UIViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func exitButtonClick(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
}

