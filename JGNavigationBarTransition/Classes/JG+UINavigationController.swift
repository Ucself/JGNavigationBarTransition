//
//  JG+UINavigationController.swift
//  JGNavigationBarTransition_Example
//
//  Created by 李保君 on 2019/7/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

// MARK: - UINavigationController
extension UINavigationController : MethodExchangeNavProtocol{
    
    // MARK: - call swizzling methods active 主动调用交换方法
    private static let onceToken = UUID().uuidString
    @objc public static func methodExchangeNav()
    {
        DispatchQueue.once(token: onceToken)
        {
            let needSwizzleSelectorArr = [
                NSSelectorFromString("_updateInteractiveTransition:"),
                #selector(popViewController),
                #selector(popToViewController),
                #selector(popToRootViewController),
                #selector(pushViewController)
            ]
            
            for selector in needSwizzleSelectorArr {
                // _updateInteractiveTransition:  =>  jg_updateInteractiveTransition:
                let str = ("jg_" + selector.description).replacingOccurrences(of: "__", with: "_")
                if let originalMethod = class_getInstanceMethod(self, selector),
                    let swizzledMethod = class_getInstanceMethod(self, Selector(str)) {
                    method_exchangeImplementations(originalMethod, swizzledMethod)
                }
            }
            //popViewController 要特殊处理
            if let originalMethod = class_getInstanceMethod(self, #selector(UINavigationController.popViewController(animated:))),
                let swizzledMethod = class_getInstanceMethod(self,
                                                             #selector(UINavigationController.jg_popViewController(animated:))) {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
    }
    
    // swizzling system method: _updateInteractiveTransition
    @objc func jg_updateInteractiveTransition(_ percentComplete: CGFloat)
    {
        //print("\(self) => jg_updateInteractiveTransition; percentComplete => \(percentComplete)")
        guard let topViewController = topViewController,let coordinator = topViewController.transitionCoordinator else {
            jg_updateInteractiveTransition(percentComplete)
            return
        }
        
        let fromVC = coordinator.viewController(forKey: .from)
        let toVC = coordinator.viewController(forKey: .to)
        updateNavigationBar(fromVC: fromVC, toVC: toVC, progress: percentComplete)
        
        jg_updateInteractiveTransition(percentComplete)
    }
    // swizzling system method: popViewController
    @objc func jg_popViewController(animated: Bool) -> UIViewController? {
        //print("\(self) => jg_popViewController; count = \(self.viewControllers.count)")
        self.popCADisplay()
        let vc = jg_popViewController(animated: animated)
        return vc
    }
    
    // swizzling system method: popToViewController
    @objc func jg_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]?
    {
        //print("\(self) => jg_popToViewController; vc = \(viewController); count = \(self.viewControllers.count)")
        self.popCADisplay()
        let vcs = jg_popToViewController(viewController, animated: animated)
        return vcs
    }
    
    // swizzling system method: popToRootViewControllerAnimated
    @objc func jg_popToRootViewControllerAnimated(_ animated: Bool) -> [UIViewController]?
    {
        //print("\(self) => jg_popToRootViewControllerAnimated; count = \(self.viewControllers.count)")
        self.popCADisplay()
        let vcs = jg_popToRootViewControllerAnimated(animated)
        return vcs;
    }
    // swizzling system method: pushViewController
    @objc func jg_pushViewController(_ viewController: UIViewController, animated: Bool)
    {
        //print("\(self) => jg_pushViewController; vc = \(viewController); count = \(self.viewControllers.count)")
        jg_pushViewController(viewController, animated: animated)
    }
    
    // MARK: - extension methods
    struct popProperties {
        fileprivate static let popDuration = 0.13
        fileprivate static var displayCount = 0
        fileprivate static var popProgress:CGFloat {
            let all:CGFloat = CGFloat(60.0 * popDuration)
            let current = min(all, CGFloat(displayCount))
            return current / all
        }
    }
    //通过CA 对颜色进行渐变
    fileprivate func popCADisplay(){
        var displayLink:CADisplayLink? = CADisplayLink(target: self, selector: #selector(popNeedDisplay))
        displayLink?.add(to: RunLoop.main, forMode: .common)
        CATransaction.setCompletionBlock {
            displayLink?.invalidate()
            displayLink = nil
            popProperties.displayCount = 0
        }
    }
    /// barTintColor 跳转到最终 VC 颜色
    @objc fileprivate func popNeedDisplay()
    {
        guard let topViewController = topViewController,
            let coordinator       = topViewController.transitionCoordinator else {
                return
        }
        
        popProperties.displayCount += 1
        let popProgress = popProperties.popProgress
        let fromVC = coordinator.viewController(forKey: .from)
        let toVC = coordinator.viewController(forKey: .to)
        updateNavigationBar(fromVC: fromVC, toVC: toVC, progress: popProgress)
    }
    // 更新导航栏
    fileprivate func updateNavigationBar(fromVC: UIViewController?, toVC: UIViewController?, progress: CGFloat)
    {
        // 改变透明度
        if let fromBarBackgroundAlpha = fromVC?.jg_navBarBackgroundAlpha,let toBarBackgroundAlpha = toVC?.jg_navBarBackgroundAlpha {
            let newBarBackgroundAlpha = self.middleAlpha(fromAlpha: fromBarBackgroundAlpha, toAlpha: toBarBackgroundAlpha, percent: progress)
            self.navigationBar.jg_setBackgroundAlpha(alpha: newBarBackgroundAlpha)
        }
        // 改变主题色
        if let fromTintColor = fromVC?.jg_navBarTintColor,let toTintColor = toVC?.jg_navBarTintColor {
            let newTintColor = self.middleColor(fromColor: fromTintColor, toColor: toTintColor, percent: progress)
            self.navigationBar.jg_setTintColor(color: newTintColor)
        }
        // 改变背景色
        if let fromBarTintColor = fromVC?.jg_navBarBarTintColor,let toBarTintColor = toVC?.jg_navBarBarTintColor {
            let newTintColor = self.middleColor(fromColor: fromBarTintColor, toColor: toBarTintColor, percent: progress)
            self.navigationBar.jg_setBarTintColor(color: newTintColor)
        }
    }
    /// 根据转场值修改透明度值
    fileprivate func middleAlpha(fromAlpha: CGFloat, toAlpha: CGFloat, percent: CGFloat) -> CGFloat
    {
        let newAlpha = fromAlpha + (toAlpha - fromAlpha) * percent
        return newAlpha
    }
    /// 根据转场值修改a颜色值
    fileprivate func middleColor(fromColor: UIColor, toColor: UIColor, percent: CGFloat) -> UIColor
    {
        // get current color RGBA
        var fromRed: CGFloat = 0
        var fromGreen: CGFloat = 0
        var fromBlue: CGFloat = 0
        var fromAlpha: CGFloat = 0
        fromColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        
        // get to color RGBA
        var toRed: CGFloat = 0
        var toGreen: CGFloat = 0
        var toBlue: CGFloat = 0
        var toAlpha: CGFloat = 0
        toColor.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        
        // calculate middle color RGBA
        let newRed = fromRed + (toRed - fromRed) * percent
        let newGreen = fromGreen + (toGreen - fromGreen) * percent
        let newBlue = fromBlue + (toBlue - fromBlue) * percent
        let newAlpha = fromAlpha + (toAlpha - fromAlpha) * percent
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: newAlpha)
    }
    
    // MARK: - override methods
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.jg_statusBarStyle ?? .default
    }
}
