# FKConsole
A convenient console view

Features
---
- [x] Easy to use
- [x] Convenient to debug
- [x] Don't need to change key window
- [x] Easy to distinguish between different Log Levels
- [x] Log with class and function info, easy to find in project

Requirment
---
iOS 8.0 or later  
Swift 3.0 or later

Install
---
*Manually:* Copy FKConsole.swift to your project  
*CocoaPods:* `pod 'FKConsole'`

How to use
---
First, register FKConsole in AppDelegate.
```Swift
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // register FKConsole with default gesture (Double tap with three fingers to toggle)
        FKConsole.register(window: self.window)
        
        // Register FKConsole with custom gesture
        /*
        let showGesture = UITapGestureRecognizer.init()
        showGesture.numberOfTapsRequired = 2
        showGesture.numberOfTouchesRequired = 3
        let hideGesture = UILongPressGestureRecognizer.init()
        hideGesture.minimumPressDuration = 1.0
        hideGesture.numberOfTouchesRequired = 3
        FKConsole.register(window: window, showGesture: showGesture, hideGesture: hideGesture)
        */
        return true
    }
```

Then you can use these functions to print log.
```Swift
/// Override to intercept print method
/// It's not recommended, please use Log.v(xxx) instead.
/// If you don't want to use this method, please remove it.
public func print(_ items: Any...)

public class Log: NSObject {
    /// Print verbose log (white)
    ///
    /// - parameter log: log content string
    public class func v(_ log: String?, fileName: String = #file, function: String = #function, lineNumber: Int = #line)
    
    /// Print debug log (blue)
    ///
    /// - parameter log: log content string
    public class func d(_ log: String?, fileName: String = #file, function: String = #function, lineNumber: Int = #line)
    
    /// Print info log (green)
    ///
    /// - parameter log: log content string
    public class func i(_ log: String?, fileName: String = #file, function: String = #function, lineNumber: Int = #line)
    
    /// Print warning log (yellow)
    ///
    /// - parameter log: log content string
    public class func w(_ log: String?, fileName: String = #file, function: String = #function, lineNumber: Int = #line)
    
    /// Print error log (red)
    ///
    /// - parameter log: log content string
    public class func e(_ log: String?, fileName: String = #file, function: String = #function, lineNumber: Int = #line)
}
```

Example
---
Warning: print function is not recommended! It won't print class and function where you call `print()`.
```Swift
    print("Print a verbose log.")
    Log.v("This is a verbose log.")
    Log.d("This is a debug log.")
    Log.i("This is a info log.")
    Log.w("This is a warning log.")
    Log.e("This is a error log.")
```
<p>
    <img src="example.PNG" alt="example" width="375" />
</p>

License
---
All source code is licensed under [MIT License](https://github.com/FlyKite/FKConsole/blob/master/LICENSE)
