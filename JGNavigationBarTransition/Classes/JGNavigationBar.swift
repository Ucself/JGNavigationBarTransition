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
//    public static func runOnce() {
//        UINavigationBar.methodExchange()
//        UIViewController.methodExchange()
//        UINavigationController.methodExchangeNav()
//    }
        //使用静态属性以保证只调用一次(该属性是个方法)
        public static let runOnce:Void = {
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
    
    // 导航栏颜色
    public func jg_setBarTintColor(color:UIColor)
    {
        barTintColor = color
    }
    // 标题颜色
    public func jg_setTitleColor(color:UIColor)
    {
        guard let oldTitleTextAttributes = self.titleTextAttributes else {
            self.titleTextAttributes = [NSAttributedString.Key.foregroundColor:color]
            return
        }
        var newTitleTextAttributes = oldTitleTextAttributes
        newTitleTextAttributes.updateValue(color, forKey: NSAttributedString.Key.foregroundColor)
        self.titleTextAttributes = newTitleTextAttributes
    }
    // 透明度
    public func jg_setBackgroundAlpha(alpha:CGFloat)
    {
        if let barBackgroundView = subviews.first
        {
            if #available(iOS 11.0, *)
            {   // sometimes we can't change _UIBarBackground alpha
                for view in barBackgroundView.subviews {
                    view.alpha = alpha
                }
            } else {
                barBackgroundView.alpha = alpha
            }
        }
    }
}
// MARK: - UIViewController
extension UIViewController : MethodExchangeProtocol{
    
    //运行时导入属性key
    fileprivate struct AssociatedKeys
    {
        static var navBarBarTintColorKey: String = "navBarBarTintColorKey"
        static var navBarTitleColorKey: String = "navBarTitleColorKey"
        static var navBarBackgroundAlphaKey: String = "navBarBackgroundAlphaKey"
    }
    
    /// 导航栏颜色
    var navBarBarTintColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.navBarBarTintColorKey) as? UIColor
        }
        set {
            if newValue != nil {
                objc_setAssociatedObject(self, &AssociatedKeys.navBarBarTintColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                navigationController?.navigationBar.jg_setBarTintColor(color: newValue!)
            }
        }
    }
    
    /// 标题颜色
    var navBarTitleColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.navBarTitleColorKey) as? UIColor
        }
        set {
            if newValue != nil {
                objc_setAssociatedObject(self, &AssociatedKeys.navBarTitleColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                navigationController?.navigationBar.jg_setTitleColor(color: newValue!)
            }
        }
    }
    
    /// 导航栏透明度
    var navBarBackgroundAlpha:CGFloat? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.navBarBackgroundAlphaKey) as? CGFloat
        }
        set {
            if newValue != nil {
                objc_setAssociatedObject(self, &AssociatedKeys.navBarBackgroundAlphaKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                navigationController?.navigationBar.jg_setBackgroundAlpha(alpha: newValue!)
            }
        }
    }
    
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
        print("\(self) => jg_viewWillAppear; count = \(self.navigationController?.viewControllers.count ?? 0)")
        //设置NavigationBar 背景色
        if navBarBarTintColor != nil {
            navigationController?.navigationBar.jg_setBarTintColor(color: navBarBarTintColor!)
        }
        //设置NavigationBar title 颜色
        if navBarTitleColor != nil {
            navigationController?.navigationBar.jg_setTitleColor(color: navBarTitleColor!)
        }
        
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
        //设置NavigationBar 背景色
        if navBarBarTintColor != nil {
            navigationController?.navigationBar.jg_setBarTintColor(color: navBarBarTintColor!)
        }
        //设置NavigationBar title 颜色
        if navBarTitleColor != nil {
            navigationController?.navigationBar.jg_setTitleColor(color: navBarTitleColor!)
        }
        //设置NavigationBar 透明度
        if navBarBackgroundAlpha != nil {
            navigationController?.navigationBar.jg_setBackgroundAlpha(alpha: navBarBackgroundAlpha!)
        }
        
        jg_viewDidAppear(animated)
    }
}
// MARK: - UINavigationController
extension UINavigationController : MethodExchangeNavProtocol{
    // MARK: - call swizzling methods active 主动调用交换方法
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
                // _updateInteractiveTransition:  =>  jg_updateInteractiveTransition:
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
        guard let topViewController = topViewController,let coordinator = topViewController.transitionCoordinator else {
            jg_updateInteractiveTransition(percentComplete)
            return
        }
        
        let fromVC = coordinator.viewController(forKey: .from)
        let toVC = coordinator.viewController(forKey: .to)
        updateNavigationBar(fromVC: fromVC, toVC: toVC, progress: percentComplete)
        
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
    
    // MARK: - extension methods
    // 更新导航栏
    fileprivate func updateNavigationBar(fromVC: UIViewController?, toVC: UIViewController?, progress: CGFloat)
    {
        // 只改变透明度
        guard let fromBarBackgroundAlpha = fromVC?.navBarBackgroundAlpha,let toBarBackgroundAlpha = toVC?.navBarBackgroundAlpha else {
            return
        }
        
        let newBarBackgroundAlpha = self.middleAlpha(fromAlpha: fromBarBackgroundAlpha, toAlpha: toBarBackgroundAlpha, percent: progress)
        self.navigationBar.jg_setBackgroundAlpha(alpha: newBarBackgroundAlpha)
    }
    // 更具转场值修改透明度值
    fileprivate func middleAlpha(fromAlpha: CGFloat, toAlpha: CGFloat, percent: CGFloat) -> CGFloat
    {
        let newAlpha = fromAlpha + (toAlpha - fromAlpha) * percent
        return newAlpha
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
