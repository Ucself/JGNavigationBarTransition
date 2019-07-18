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
    
    fileprivate struct AssociatedKeys {
        static var backgroundImageViewKey: String = "backgroundImageViewKey"
    }
    
    fileprivate var backgroundImageView:UIImageView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.backgroundImageViewKey) as? UIImageView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.backgroundImageViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // set navigationBar backgroundImage
    fileprivate func jg_setBackgroundImage(image:UIImage)
    {
        let navBarHeight =  JGNavigationBar.isiPhoneXScreen() ? 88 : 64;
        if (backgroundImageView == nil)
        {
            setBackgroundImage(UIImage(), for: .default)
            backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: Int(bounds.width), height: navBarHeight))
            backgroundImageView!.contentMode = .scaleAspectFill
            backgroundImageView!.clipsToBounds = true
            subviews.first?.insertSubview(backgroundImageView ?? UIImageView(), at: 0)
        }
        backgroundImageView!.image = image
    }
    
    // 导航栏颜色
    fileprivate func jg_setBarTintColor(color:UIColor)
    {
        barTintColor = color
    }
    // 标题颜色
    fileprivate func jg_setTitleColor(color:UIColor)
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
    fileprivate func jg_setBackgroundAlpha(alpha:CGFloat)
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
    // 导航栏主题颜色
    fileprivate func jg_setTintColor(color:UIColor)
    {
        tintColor = color
    }
    
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
    
    //运行时导入属性key
    fileprivate struct AssociatedKeys
    {
        static var navBarBarTintColorKey: String = "navBarBarTintColorKey"
        static var navBarTitleColorKey: String = "navBarTitleColorKey"
        static var navBarBackgroundAlphaKey: String = "navBarBackgroundAlphaKey"
        static var navBarTintColorKey: String = "navBarTintColorKey"
        static var navBarBackgroundImageKey: String = "navBarBackgroundImageKey"
        static var statusBarStyle: String = "statusBarStyle"
    }
    
    /// 导航栏颜色
    var jg_navBarBarTintColor: UIColor? {
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
    var jg_navBarTitleColor: UIColor? {
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
    var jg_navBarBackgroundAlpha:CGFloat? {
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
    
    /// 导航栏主题色（默认系统按钮，标题等等）
    var jg_navBarTintColor:UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.navBarTintColorKey) as? UIColor
        }
        set {
            if newValue != nil {
                objc_setAssociatedObject(self, &AssociatedKeys.navBarTintColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                navigationController?.navigationBar.jg_setTintColor(color: newValue!)
            }
        }
    }
    
    /// 导航栏背景图片 ，弃用使用场景不适合
    //    var jg_navBarBackgroundImage:UIImage? {
    //        get {
    //            return objc_getAssociatedObject(self, &AssociatedKeys.navBarBackgroundImageKey) as? UIImage
    //        }
    //        set {
    //            if newValue != nil {
    //                objc_setAssociatedObject(self, &AssociatedKeys.navBarBackgroundImageKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    //                navigationController?.navigationBar.jg_setBackgroundImage(image: newValue!)
    //            }
    //        }
    //    }
    
    var jg_statusBarStyle:UIStatusBarStyle? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.statusBarStyle) as? UIStatusBarStyle
        }
        set {
            if newValue != nil {
                objc_setAssociatedObject(self, &AssociatedKeys.statusBarStyle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                setNeedsStatusBarAppearanceUpdate()
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
        //print("\(self) => jg_viewWillAppear; count = \(self.navigationController?.viewControllers.count ?? 0)")
        //设置NavigationBar 背景色
        if jg_navBarBarTintColor != nil {
            navigationController?.navigationBar.jg_setBarTintColor(color: jg_navBarBarTintColor!)
        }
        //设置NavigationBar title 颜色
        if jg_navBarTitleColor != nil {
            navigationController?.navigationBar.jg_setTitleColor(color: jg_navBarTitleColor!)
        }
        
        jg_viewWillAppear(animated)
    }
    
    @objc func jg_viewWillDisappear(_ animated: Bool)
    {
        //print("\(self) => jg_viewWillDisappear; count = \(self.navigationController?.viewControllers.count ?? 0)")
        jg_viewWillDisappear(animated)
    }
    
    @objc func jg_viewDidAppear(_ animated: Bool)
    {
        //print("\(self) => jg_viewDidAppear; count = \(self.navigationController?.viewControllers.count ?? 0)")
        //设置NavigationBar 背景色
        if jg_navBarBarTintColor != nil {
            navigationController?.navigationBar.jg_setBarTintColor(color: jg_navBarBarTintColor!)
        }
        //设置NavigationBar title 颜色
        if jg_navBarTitleColor != nil {
            navigationController?.navigationBar.jg_setTitleColor(color: jg_navBarTitleColor!)
        }
        //设置NavigationBar 透明度
        if jg_navBarBackgroundAlpha != nil {
            navigationController?.navigationBar.jg_setBackgroundAlpha(alpha: jg_navBarBackgroundAlpha!)
        }
        //设置NavigationBar 导航栏主题色
        if jg_navBarTintColor != nil {
            navigationController?.navigationBar.jg_setTintColor(color: jg_navBarTintColor!)
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
    
    // swizzling system method: popToViewController
    @objc func jg_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]?
    {
        //print("\(self) => jg_popToViewController; vc = \(viewController); count = \(self.viewControllers.count)")
        let vcs = jg_popToViewController(viewController, animated: animated)
        return vcs
    }
    
    // swizzling system method: popToRootViewControllerAnimated
    @objc func jg_popToRootViewControllerAnimated(_ animated: Bool) -> [UIViewController]?
    {
        //print("\(self) => jg_popToRootViewControllerAnimated; count = \(self.viewControllers.count)")
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

class JGNavigationBar {
    //判断刘海儿屏手机
    class func isiPhoneXScreen() -> Bool {
        guard #available(iOS 11.0, *) else {
            return false
        }
        let windows:[UIWindow] = UIApplication.shared.windows
        if windows.count <= 0 {
            return false
        }
        return windows[0].safeAreaInsets.bottom > 0
    }
}
