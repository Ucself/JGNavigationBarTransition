//
//  JGNavigationBar.swift
//  JGNavigationBarTransition
//
//  Created by ucself
//
//  Github地址：https://github.com/Ucself/JGNavigationBarTransition

import UIKit


// MARK: - Protocol
// 定义方法交换协议
public protocol MethodExchangeProtocol: class {
    static func methodExchange()
}
public protocol MethodExchangeNavProtocol: class {
    static func methodExchangeNav()
}

// MARK: - UIApplication
extension UIApplication {
    //使用静态属性以保证只调用一次(该属性是个方法)
    private static let runOnce:Void = {
        UINavigationBar.methodExchange()
        UIViewController.methodExchange()
        UINavigationController.methodExchangeNav()
    }()
    //重写next属性
    open override var next: UIResponder?{
        UIApplication.runOnce
        return super.next
    }
}
// MARK: - UINavigationBar
extension UINavigationBar : MethodExchangeProtocol{
    public static func methodExchange()
    {
        
    }
}
// MARK: - UIViewController
extension UIViewController : MethodExchangeProtocol{
    public static func methodExchange()
    {
        
    }
}
// MARK: - UINavigationController
extension UINavigationController : MethodExchangeNavProtocol{
    //方法交换只执行一次
    private static let onceToken = UUID().uuidString
    public static func methodExchangeNav()
    {
        DispatchQueue.once(token: onceToken)
        {
            let needSwizzleSelectorArr = [
                NSSelectorFromString("_updateInteractiveTransition:"),
                #selector(popToViewController),
                #selector(popToRootViewController),
                #selector(pushViewController)
            ]
            
            for selector in needSwizzleSelectorArr {
                // _updateInteractiveTransition:  =>  wr_updateInteractiveTransition:
                let str = ("jg_" + selector.description).replacingOccurrences(of: "__", with: "_")
                if let originalMethod = class_getInstanceMethod(self, selector),
                    let swizzledMethod = class_getInstanceMethod(self, Selector(str)) {
                    method_exchangeImplementations(originalMethod, swizzledMethod)
                }
            }
        }
    }
}

// MARK: - Swizzling会改变全局状态,所以用 DispatchQueue.once 来确保无论多少线程都只会被执行一次
extension DispatchQueue {
    
    private static var onceTracker = [String]()
    //Executes a block of code, associated with a unique token, only once.  The code is thread safe and will only execute the code once even in the presence of multithreaded calls.
    public class func once(token: String, block: () -> Void)
    {
        // 保证被 objc_sync_enter 和 objc_sync_exit 包裹的代码可以有序同步地执行
        objc_sync_enter(self)
        defer { // 作用域结束后执行defer中的代码
            objc_sync_exit(self)
        }
        if onceTracker.contains(token) {
            return
        }
        onceTracker.append(token)
        block()
    }
}
