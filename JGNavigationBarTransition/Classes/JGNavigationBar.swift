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
    //执行一次方法交换
    public static func runOnce() {
        UINavigationBar.methodExchange()
        UIViewController.methodExchange()
        UINavigationController.methodExchangeNav()
    }
    //    //使用静态属性以保证只调用一次(该属性是个方法)
    //    public static let runOnce:Void = {
    //        UINavigationBar.methodExchange()
    //        UIViewController.methodExchange()
    //        UINavigationController.methodExchangeNav()
    //    }()
    //    //重写next属性
    //    open override var next: UIResponder?{
    //        UIApplication.runOnce
    //        return super.next
    //    }
}
// MARK: - UINavigationBar
extension UINavigationBar : MethodExchangeProtocol{
    // call swizzling methods active 主动调用交换方法
    private static let onceToken = UUID().uuidString
    public static func methodExchange()
    {
        DispatchQueue.once(token: onceToken)
        {
            let needSwizzleSelectorArr = [
                #selector(setter: titleTextAttributes)
            ]

            for selector in needSwizzleSelectorArr {
                let str = ("jg_" + selector.description)
                if let originalMethod = class_getInstanceMethod(self, selector),
                    let swizzledMethod = class_getInstanceMethod(self, Selector(str)) {
                    method_exchangeImplementations(originalMethod, swizzledMethod)
                }
            }
        }
    }
    @objc func jg_setTitleTextAttributes(_ newTitleTextAttributes:[String : Any]?)
    {
        print("\(self) => jg_setTitleTextAttributes ")
        jg_setTitleTextAttributes(newTitleTextAttributes)
    }
}
// MARK: - UIViewController
extension UIViewController : MethodExchangeProtocol{
    // call swizzling methods active 主动调用交换方法
    private static let onceToken = UUID().uuidString
    @objc public static func methodExchange()
    {
        DispatchQueue.once(token: onceToken)
        {
            let needSwizzleSelectors = [
                #selector(viewWillAppear(_:)),
                #selector(viewWillDisappear(_:)),
                #selector(viewDidAppear(_:))
            ]

            for selector in needSwizzleSelectors
            {
                let newSelectorStr = "jg_" + selector.description
                if let originalMethod = class_getInstanceMethod(self, selector),
                    let swizzledMethod = class_getInstanceMethod(self, Selector(newSelectorStr)) {
                    method_exchangeImplementations(originalMethod, swizzledMethod)
                }
            }
        }
    }
    @objc func jg_viewWillAppear(_ animated: Bool)
    {
        print("\(self) => wr_viewWillAppear; count = \(self.navigationController?.viewControllers.count ?? 0)")
        jg_viewWillAppear(animated)
    }
    
    @objc func jg_viewWillDisappear(_ animated: Bool)
    {
        print("\(self) => jg_viewWillDisappear; count = \(self.navigationController?.viewControllers.count ?? 0)")
        jg_viewWillDisappear(animated)
    }
    
    @objc func jg_viewDidAppear(_ animated: Bool)
    {
        print("\(self) => jg_viewDidAppear; count = \(self.navigationController?.viewControllers.count ?? 0)")
        jg_viewDidAppear(animated)
    }
}
// MARK: - UINavigationController
extension UINavigationController : MethodExchangeNavProtocol{
    // call swizzling methods active 主动调用交换方法
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
    
    // swizzling system method: _updateInteractiveTransition
    @objc func jg_updateInteractiveTransition(_ percentComplete: CGFloat)
    {
        print("\(self) => jg_updateInteractiveTransition; percentComplete => \(percentComplete)")
        jg_updateInteractiveTransition(percentComplete)
    }
    
    // swizzling system method: popToViewController
    @objc func jg_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]?
    {
        print("\(self) => jg_popToViewController; vc = \(viewController); count = \(self.viewControllers.count)")
        let vcs = jg_popToViewController(viewController, animated: animated)
        return vcs
    }
    
    // swizzling system method: popToRootViewControllerAnimated
    @objc func jg_popToRootViewControllerAnimated(_ animated: Bool) -> [UIViewController]?
    {
        print("\(self) => jg_popToRootViewControllerAnimated; count = \(self.viewControllers.count)")
        let vcs = jg_popToRootViewControllerAnimated(animated)
        return vcs;
    }
    // swizzling system method: pushViewController
    @objc func jg_pushViewController(_ viewController: UIViewController, animated: Bool)
    {
        print("\(self) => jg_pushViewController; vc = \(viewController); count = \(self.viewControllers.count)")
        jg_pushViewController(viewController, animated: animated)
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
