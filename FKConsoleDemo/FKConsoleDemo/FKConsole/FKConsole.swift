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

public class FKConsole: UIView {
    // MARK:- singleton
    static let console = FKConsole.init(frame: CGRect(x:0, y:0, width:SCREEN_WIDTH, height:SCREEN_HEIGHT))
    
    // MARK:- register functions
    
    /// Register FKConsole to window (Double tap with three fingers to toggle)
    ///
    /// - parameter window: The window will be registered
    public class func register(window: UIWindow?) {
        let showGesture = UITapGestureRecognizer.init()
        showGesture.numberOfTapsRequired = 2
        showGesture.numberOfTouchesRequired = 3
        let hideGesture = UITapGestureRecognizer.init()
        hideGesture.numberOfTapsRequired = 2
        hideGesture.numberOfTouchesRequired = 3
        register(window: window, showGesture: showGesture, hideGesture: hideGesture)
    }

    /// Register FKConsole to window
    ///
    /// - parameter window: The window will be registered
    /// - parameter showGesture: The gesture to show FKConsole
    /// - parameter hideGesture: The gesture to hide FKConsole (Don't use SWIPE gesture for hideGesture, it won't be work)
    public class func register(window wd: UIWindow?, showGesture: UIGestureRecognizer?, hideGesture: UIGestureRecognizer?) {
        guard let window = wd else {
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
            console.logView.addHideGesture(gesture: hideGesture!)
        }
    }
    
    /// Remove FKConsole from registered window
    public class func removeConsole() {
        guard let window = console.shownWindow else {
            return
        }
        window.removeGestureRecognizer(console.showGesture)
        console.logView.removeHideGesture(gesture: console.hideGesture)
        console.shownWindow = nil
    }
    
    // MARK:- functions
    
    /// Print Log object to FKConsole and Console in Xcode
    ///
    /// - parameter log: Log object
    public func addLog(_ log: Log!) {
        self.logView.addLog(log)
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
    public var verboseColor: UIColor = UIColor.white
    public var debugColor: UIColor = UIColor(red: 0, green: 0.627, blue: 0.745, alpha: 1)
    public var infoColor: UIColor = UIColor(red: 0.514, green: 0.753, blue: 0.341, alpha: 1)
    public var warningColor: UIColor = UIColor.yellow
    public var errorColor: UIColor = UIColor.red
    
    private var shownWindow: UIWindow?
    private var showGesture: UIGestureRecognizer!
    private var hideGesture: UIGestureRecognizer!
    private var animating: Bool! = false
    private var originalStatusBarStyle: UIStatusBarStyle?
    
    private lazy var logView: LogView = {
        let logView = LogView.init(frame: CGRect(x:0, y:0, width:SCREEN_WIDTH, height:SCREEN_HEIGHT))
        logView.backgroundColor = UIColor.white
        self.addSubview(logView)
        return logView
    }()
    
    private lazy var closeButton: UIButton = {
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
    
    private lazy var clearButton: UIButton = {
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
fileprivate class LogView: UIView, UITableViewDelegate, UITableViewDataSource {
    private lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect(x: 0, y: 20, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 20), style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = UIColor.black
        self.addSubview(tableView)
        self.backgroundColor = UIColor.white
        return tableView
    }()
    
    public override var frame: CGRect {
        get {
            return super.frame
        }
        set(value) {
            super.frame = value
            self.tableView.frame = CGRect(x: 0, y: 20, width: self.bounds.width, height: self.bounds.height - 20)
        }
    }
    
    private var logs = Array<Log>()
    
    // MARK:- LogView functions
    public func addLog(_ log: Log!) {
        self.logs.append(log)
        let indexPath = IndexPath(row: logs.count - 1, section: 0)
        self.tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.none)
    }
    
    public func clearLogs() {
        self.logs.removeAll()
        self.tableView.reloadData()
    }
    
    fileprivate func addHideGesture(gesture: UIGestureRecognizer!) {
        guard let ges = gesture else {
            return
        }
        self.addGestureRecognizer(ges)
    }
    
    fileprivate func removeHideGesture(gesture: UIGestureRecognizer!) {
        guard let ges = gesture else {
            return
        }
        self.removeGestureRecognizer(ges)
    }
    
    // return the color of Log.Level
    private func logColor(level: Log.Level) -> UIColor! {
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
    
    private func logHeight(log: String) -> CGFloat {
        let size = CGSize(width: SCREEN_WIDTH, height: CGFloat(MAXFLOAT))
        let bounds = log.boundingRect(with: size,
                                      options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                      attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15)],
                                      context: nil)
        return bounds.height
    }
    
    // MARK:- tableView delegate & dataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.logs.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.selectionStyle = .none
        let log = logs[indexPath.row]
        var label: UILabel? = cell?.viewWithTag(1) as? UILabel
        if label == nil {
            label = UILabel()
            label?.font = UIFont.systemFont(ofSize: 15)
            label?.numberOfLines = 0
            cell?.addSubview(label!)
        }
        label!.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: logHeight(log: log.info + log.log))
        label!.textColor = logColor(level: log.level)
        
        let attrStr = NSMutableAttributedString.init(string: log.info + log.log)
        attrStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGray, range: NSRange(location: 0, length: log.info.lengthOfBytes(using: String.Encoding.utf8)))
        label!.attributedText = attrStr
        
        cell?.backgroundColor = UIColor.black
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return logHeight(log: logs[indexPath.row].info + logs[indexPath.row].log)
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
public class Log: NSObject {
    
    enum Level {
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
    
    private class func addLog(_ log: Any?, info: String!, level: Log.Level!) {
        let log = Log(info: info, log: log, level: level)
        FKConsole.console.addLog(log)
    }
    
    private class func formatInfo(fileName: String!, function: String!, lineNumber: Int!) -> String! {
        
        let className = (fileName as NSString).pathComponents.last!.replacingOccurrences(of: "swift", with: "")
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let date = fmt.string(from: Date())
        let text = date + " " + className + function + " [line " + String(lineNumber) + "]:\n"
        
        return text
    }
    
    var info: String!
    var log: String!
    var level: Log.Level!
    init(info i: String!, log l: Any?, level lv: Log.Level!) {
        self.info = i
        self.level = lv
        guard let log_t = l else {
            self.log = ""
            return
        }
        self.log = String.init(describing: log_t)
    }
}
