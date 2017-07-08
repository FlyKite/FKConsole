//
//  FKConsole.swift
//  FKConsole
//
//  Created by FlyKite on 2016/12/2.
//  Copyright © 2016年 FlyKite. All rights reserved.
//

import UIKit

// Constants
fileprivate let SCREEN_WIDTH = UIScreen.main.bounds.width
fileprivate let SCREEN_HEIGHT = UIScreen.main.bounds.height

// Handle uncaught exception
fileprivate func exceptionHandler(_ exception: NSException) {
    Log.e(exception)
    FKConsole.console.logView.saveLogs()
}

public class FKConsole: UIView {
    
    // MARK:- singleton
    static let console = FKConsole.init(frame: CGRect(x:0, y:0, width:SCREEN_WIDTH, height:SCREEN_HEIGHT))
    
    // MARK:- register functions
    
    /// Register FKConsole to window (Double tap with three fingers to toggle)
    ///
    /// - parameter window: The window will be registered
    public class func register(to window: UIWindow?) {
        let showGesture = UITapGestureRecognizer.init()
        showGesture.numberOfTapsRequired = 2
        showGesture.numberOfTouchesRequired = 3
        let hideGesture = UITapGestureRecognizer.init()
        hideGesture.numberOfTapsRequired = 2
        hideGesture.numberOfTouchesRequired = 3
        register(to: window, showGesture: showGesture, hideGesture: hideGesture)
    }
    
    /// Register FKConsole to window
    ///
    /// - parameter window: The window will be registered
    /// - parameter showGesture: The gesture to show FKConsole
    /// - parameter hideGesture: The gesture to hide FKConsole (Don't use SWIPE gesture for hideGesture, it won't be work)
    public class func register(to window: UIWindow?, showGesture: UIGestureRecognizer?, hideGesture: UIGestureRecognizer?) {
        guard let window = window else {
            removeConsole()
            return
        }
        
        // set variables
        console.shownWindow = window
        
        // deal with gestures
        if showGesture != nil {
            console.showGesture = showGesture
            showGesture!.addTarget(console, action: #selector(show))
            window.addGestureRecognizer(showGesture!)
        }
        if hideGesture != nil {
            console.hideGesture = hideGesture
            hideGesture!.addTarget(console, action: #selector(hide))
            console.logView.addHideGesture(hideGesture!)
        }
    }
    
    /// Remove FKConsole from registered window
    public class func removeConsole() {
        guard let window = console.shownWindow else {
            return
        }
        window.removeGestureRecognizer(console.showGesture)
        console.logView.removeHideGesture(console.hideGesture)
        console.shownWindow = nil
    }
    
    // MARK:- initial and deinit
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        NSSetUncaughtExceptionHandler(exceptionHandler)
        self.logView.registerObserver()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- functions
    
    /// Print Log object to FKConsole and Console in Xcode
    ///
    /// - parameter log: Log object
    public func addLog(_ log: Log) {
        if Thread.current == Thread.main {
            self.logView.addLog(log)
        } else {
            self.logView.performSelector(onMainThread: #selector(addLog(_:)), with: log, waitUntilDone: true)
        }
        print(log.info, log.log, separator: "", terminator: "\n")
    }
    
    /// Clear logs in FKConsole
    public func clearLogs() {
        self.logView.clearLogs()
    }
    
    /// Show FKConsole in registered window
    final func show() {
        if self.animating || self.superview != nil {
            return
        }
        guard let window = self.shownWindow else {
            return
        }
        
        self.animating = true
        
        self.originalStatusBarStyle = UIApplication.shared.statusBarStyle
        UIApplication.shared.statusBarStyle = .default
        
        self.frame = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        
        self.logView.frame = self.bounds
        self.closeButton.frame = CGRect(x: SCREEN_WIDTH - 50, y: SCREEN_HEIGHT - 50, width: 40, height: 40)
        self.clearButton.frame = CGRect(x: SCREEN_WIDTH - 100, y: SCREEN_HEIGHT - 50, width: 40, height: 40)
        
        window.addSubview(self)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        }, completion: { (finished) in
            self.animating = false
        })
    }
    
    /// Hide FKConsole
    final func hide() {
        if self.animating || self.superview == nil {
            return
        }
        
        self.animating = true
        
        if let style = self.originalStatusBarStyle {
            UIApplication.shared.statusBarStyle = style
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        }, completion: { (finished) in
            self.animating = false
            self.removeFromSuperview()
        })
    }
    
    // MARK:- variables
    
    /// Default is true, it determines whether to save logs to disk.
    /// If you don't want to save logs to disk, please set it to false.
    public var shouldSaveLogsToDisk = true
    
    /// Color of verbose logs, default is white.
    public var verboseColor: UIColor = UIColor.white
    
    /// Color of debug logs, default is blue.
    public var debugColor: UIColor = UIColor(red: 0, green: 0.627, blue: 0.745, alpha: 1)
    
    /// Color of info logs, default is green.
    public var infoColor: UIColor = UIColor(red: 0.514, green: 0.753, blue: 0.341, alpha: 1)
    
    /// Color of warning logs, default is yellow.
    public var warningColor: UIColor = UIColor.yellow
    
    /// Color of error logs, default is red.
    public var errorColor: UIColor = UIColor.red
    
    /// Font of logs, default is system font of 15 pix.
    public var font: UIFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            self.logView.textView.font = font
        }
    }
    
    fileprivate var shownWindow: UIWindow?
    fileprivate var showGesture: UIGestureRecognizer!
    fileprivate var hideGesture: UIGestureRecognizer!
    fileprivate var animating: Bool = false
    fileprivate var originalStatusBarStyle: UIStatusBarStyle?
    
    fileprivate lazy var logView: LogView = {
        let logView = LogView.init(frame: CGRect(x:0, y:0, width:SCREEN_WIDTH, height:SCREEN_HEIGHT))
        logView.backgroundColor = UIColor.white
        logView.textView.font = self.font
        self.addSubview(logView)
        return logView
    }()
    
    fileprivate lazy var closeButton: UIButton = {
        let closeButton = UIButton.init(type: UIButtonType.custom)
        closeButton.setTitle("×", for: UIControlState.normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        closeButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        closeButton.setTitleColor(UIColor.gray, for: UIControlState.highlighted)
        closeButton.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
        closeButton.layer.cornerRadius = 20
        closeButton.addTarget(self, action: #selector(hide), for: UIControlEvents.touchUpInside)
        self.addSubview(closeButton)
        return closeButton
    }()
    
    fileprivate lazy var clearButton: UIButton = {
        let clearButton = UIButton.init(type: UIButtonType.custom)
        clearButton.setTitle("C", for: UIControlState.normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        clearButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        clearButton.setTitleColor(UIColor.gray, for: UIControlState.highlighted)
        clearButton.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
        clearButton.layer.cornerRadius = 20
        clearButton.addTarget(self, action: #selector(clearLogs), for: UIControlEvents.touchUpInside)
        self.addSubview(clearButton)
        return clearButton
    }()
    
}

// MARK:- LogView
fileprivate class LogView: UIView {
    
    fileprivate lazy var textView: UITextView = {
        let textView = UITextView.init()
        textView.frame = CGRect(x: 0, y: 20, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 20)
        textView.backgroundColor = UIColor.black
        textView.textColor = UIColor.darkGray
        textView.isEditable = false
        self.addSubview(textView)
        self.backgroundColor = UIColor.white
        return textView
    }()
    
    public override var frame: CGRect {
        get {
            return super.frame
        }
        set(value) {
            super.frame = value
            self.textView.frame = CGRect(x: 0, y: 20, width: self.bounds.width, height: self.bounds.height - 20)
        }
    }
    
    private let logKey = "FKConsoleLog"
    private var logsAttributedString = NSMutableAttributedString.init(string: "")
    private lazy var logs: [Log] = {
        var logs = [Log]()
        if !FKConsole.console.shouldSaveLogsToDisk {
            return logs
        }
        guard let logsData = UserDefaults.standard.object(forKey: self.logKey) as? Data else {
            return logs
        }
        guard let logsArray = NSKeyedUnarchiver.unarchiveObject(with: logsData) as? [Log] else {
            return logs
        }
        for log in logsArray {
            self.logsAttributedString.append(self.handleLog(log))
        }
        logs.append(contentsOf: logsArray)
        return logs
    }()
    
    // MARK:- LogView functions
    public func addLog(_ log: Log) {
        self.logs.append(log)
        self.logsAttributedString.append(self.handleLog(log))
        self.textView.attributedText = self.logsAttributedString
    }
    
    public func clearLogs() {
        self.logs.removeAll()
        self.logsAttributedString = NSMutableAttributedString.init(string: "")
        self.textView.attributedText = self.logsAttributedString
    }
    
    @objc fileprivate func saveLogs() {
        if !FKConsole.console.shouldSaveLogsToDisk {
            return
        }
        let logsData = NSKeyedArchiver.archivedData(withRootObject: self.logs)
        UserDefaults.standard.set(logsData, forKey: logKey)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: Register observer for App did enter background and App will Terminate
    fileprivate func registerObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(saveLogs),
                                               name: NSNotification.Name.UIApplicationDidEnterBackground,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(saveLogs),
                                               name: NSNotification.Name.UIApplicationWillTerminate,
                                               object: nil)
    }
    
    @objc fileprivate func addHideGesture(_ gesture: UIGestureRecognizer) {
        self.addGestureRecognizer(gesture)
    }
    
    @objc fileprivate func removeHideGesture(_ gesture: UIGestureRecognizer) {
        self.removeGestureRecognizer(gesture)
    }
    
    private func handleLog(_ log: Log) -> NSAttributedString {
        let aStr = NSMutableAttributedString.init(string: log.info + log.log + "\n")
        aStr.addAttribute(NSForegroundColorAttributeName,
                          value: UIColor.darkGray,
                          range: NSMakeRange(0, log.info.characters.count + log.log.characters.count))
        aStr.addAttribute(NSForegroundColorAttributeName,
                          value: self.logColor(level: log.level),
                          range: NSMakeRange(log.info.characters.count, log.log.characters.count))
        return aStr
    }
    
    // return the color of Log.Level
    private func logColor(level: Log.Level) -> UIColor {
        switch level {
        case Log.Level.verbose:
            return FKConsole.console.verboseColor
        case Log.Level.debug:
            return FKConsole.console.debugColor
        case Log.Level.info:
            return FKConsole.console.infoColor
        case Log.Level.warning:
            return FKConsole.console.warningColor
        case Log.Level.error:
            return FKConsole.console.errorColor
        }
    }
    
}

// MARK:- Print
/// Override to intercept print method
/// It's not recommended, please use Log.v(xxx) instead.
/// If you don't want to use this method, please remove it.
public func print(_ items: Any...) {
    var text = ""
    for index in 1...items.count {
        text.append(String(describing: items[index - 1]))
        if index == items.count - 1 {
            text.append("\n")
        } else {
            text.append(" ")
        }
    }
    Log.v(text)
}

// MARK:- Log
public class Log: NSObject, NSCoding {
    
    enum Level: String {
        case verbose
        case debug
        case info
        case warning
        case error
    }
    
    /// Print verbose log (white)
    ///
    /// - parameter log: log content string
    public class func v(_ log: Any?, fileName: String = #file, function: String = #function, lineNumber: Int = #line) {
        let info = formatInfo(fileName: fileName, function: function, lineNumber: lineNumber)
        self.addLog(log, info: info, level: Log.Level.verbose)
    }
    /// Print debug log (blue)
    ///
    /// - parameter log: log content string
    public class func d(_ log: Any?, fileName: String = #file, function: String = #function, lineNumber: Int = #line) {
        let info = formatInfo(fileName: fileName, function: function, lineNumber: lineNumber)
        self.addLog(log, info: info, level: Log.Level.debug)
    }
    /// Print info log (green)
    ///
    /// - parameter log: log content string
    public class func i(_ log: Any?, fileName: String = #file, function: String = #function, lineNumber: Int = #line) {
        let info = formatInfo(fileName: fileName, function: function, lineNumber: lineNumber)
        self.addLog(log, info: info, level: Log.Level.info)
    }
    /// Print warning log (yellow)
    ///
    /// - parameter log: log content string
    public class func w(_ log: Any?, fileName: String = #file, function: String = #function, lineNumber: Int = #line) {
        let info = formatInfo(fileName: fileName, function: function, lineNumber: lineNumber)
        self.addLog(log, info: info, level: Log.Level.warning)
    }
    /// Print error log (red)
    ///
    /// - parameter log: log content string
    public class func e(_ log: Any?, fileName: String = #file, function: String = #function, lineNumber: Int = #line) {
        let info = formatInfo(fileName: fileName, function: function, lineNumber: lineNumber)
        self.addLog(log, info: info, level: Log.Level.error)
    }
    
    private class func addLog(_ log: Any?, info: String, level: Log.Level) {
        let log = Log(info: info, log: log, level: level)
        FKConsole.console.addLog(log)
    }
    
    private class func formatInfo(fileName: String, function: String, lineNumber: Int) -> String {
        
        let className = (fileName as NSString).pathComponents.last!.replacingOccurrences(of: "swift", with: "")
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let date = fmt.string(from: Date())
        let text = date + " " + className + function + " [line " + String(lineNumber) + "]:\n"
        
        return text
    }
    
    var info: String
    var log: String
    var level: Log.Level
    init(info i: String, log l: Any?, level lv: Log.Level) {
        self.info = i
        self.level = lv
        guard let log_t = l else {
            self.log = ""
            return
        }
        self.log = String.init(describing: log_t)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.info = aDecoder.decodeObject(forKey: "info") as! String
        self.log = aDecoder.decodeObject(forKey: "log") as! String
        let levelString = aDecoder.decodeObject(forKey: "level") as! String
        self.level = Level.init(rawValue: levelString)!
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.info, forKey: "info")
        aCoder.encode(self.log, forKey: "log")
        aCoder.encode(self.level.rawValue, forKey: "level")
    }
}
