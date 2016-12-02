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

class FKConsole: UIView {
    // MARK:- singleton
    static let console = FKConsole.init(frame: CGRect(x:0, y:0, width:SCREEN_WIDTH, height:SCREEN_HEIGHT))
    
    // MARK:- register functions
    public class func register(window: UIWindow?) {
        let showGesture = UISwipeGestureRecognizer.init()
        showGesture.direction = UISwipeGestureRecognizerDirection.up
        showGesture.numberOfTouchesRequired = 3
        let hideGesture = UISwipeGestureRecognizer.init()
        hideGesture.direction = UISwipeGestureRecognizerDirection.down
        hideGesture.numberOfTouchesRequired = 3
        register(window: window, showGesture: showGesture, hideGesture: hideGesture)
    }
    
    public class func register(window wd: UIWindow?, showGesture: UIGestureRecognizer!, hideGesture: UIGestureRecognizer!) {
        guard let window = wd else {
            removeConsole()
            return
        }
        
        // set variables
        console.shownWindow = window
        console.showGesture = showGesture
        console.hideGesture = hideGesture
        
        // deal with gestures
        showGesture.addTarget(console, action: #selector(show))
        hideGesture.addTarget(console, action: #selector(hide))
        window.addGestureRecognizer(showGesture)
//        console.logView.addHideGesture(gesture: hideGesture)
//        window.addGestureRecognizer(hideGesture)
    }
    
    // remove function
    public class func removeConsole() {
        guard let window = console.shownWindow else {
            return
        }
        window.removeGestureRecognizer(console.showGesture)
//        console.logView.removeHideGesture(gesture: console.hideGesture)
//        window.removeGestureRecognizer(console.hideGesture)
        console.shownWindow = nil
    }
    
    // MARK:- variables
    private var shownWindow: UIWindow?
    private var showGesture: UIGestureRecognizer!
    private var hideGesture: UIGestureRecognizer!
    
    // Views
    private var _logView: LogView!
    private var logView: LogView! {
        get {
            if _logView == nil {
                _logView = LogView(frame: CGRect(x:0, y:0, width:SCREEN_WIDTH, height:SCREEN_HEIGHT))
                _logView.backgroundColor = UIColor.white
                self.addSubview(_logView)
            }
            return _logView
        }
    }
    
    private var _closeButton: UIButton!
    private var closeButton: UIButton! {
        get {
            if _closeButton == nil {
                _closeButton = UIButton(type: UIButtonType.custom)
                _closeButton.setTitle("×", for: UIControlState.normal)
                _closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 28)
                _closeButton.setTitleColor(UIColor.black, for: UIControlState.normal)
                _closeButton.setTitleColor(UIColor.gray, for: UIControlState.highlighted)
                _closeButton.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
                _closeButton.layer.cornerRadius = 20
                _closeButton.addTarget(self, action: #selector(hide), for: UIControlEvents.touchUpInside)
                self.addSubview(_closeButton)
            }
            return _closeButton
        }
    }
    
    // MARK:- functions
    final func show() {
        guard let window = self.shownWindow else {
            return
        }
        
        self.frame = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        logView.frame = self.bounds
        closeButton.frame = CGRect(x: SCREEN_WIDTH - 50, y: SCREEN_HEIGHT - 50, width: 40, height: 40)
        window.addSubview(self)
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        })
    }
    
    final func hide() {
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        }, completion: { (finished) in
            self.removeFromSuperview()
        })
    }
    
    public func addLog(_ log: Log!) {
        logView.addLog(log)
        print(log.log)
    }
}

// MARK:- LogView
fileprivate class LogView: UIView, UITableViewDelegate, UITableViewDataSource {
    private var _tableView: UITableView!
    private var tableView: UITableView! {
        get {
            if _tableView == nil {
                _tableView = UITableView(frame: CGRect(x:0, y:20, width:SCREEN_WIDTH, height:SCREEN_HEIGHT - 20), style: UITableViewStyle.plain)
                _tableView.delegate = self
                _tableView.dataSource = self
                _tableView.separatorStyle = UITableViewCellSeparatorStyle.none
                _tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
                _tableView.backgroundColor = UIColor.black
                self.addSubview(_tableView)
                self.backgroundColor = UIColor.white
            }
            return _tableView
        }
    }
    
    public override var frame: CGRect {
        get {
            return super.frame
        }
        set(value) {
            super.frame = value
            tableView.frame = CGRect(x:0, y:20, width:self.bounds.width, height:self.bounds.height - 20)
        }
    }
    
    public var verboseColor: UIColor! = UIColor.white
    public var debugColor: UIColor! = UIColor(red: 0, green: 0.627, blue: 0.745, alpha: 1)
    public var infoColor: UIColor! = UIColor(red: 0.514, green: 0.753, blue: 0.341, alpha: 1)
    public var warningColor: UIColor! = UIColor.yellow
    public var errorColor: UIColor! = UIColor.red
    private var logs = Array<Log>()
    
    // MARK:- LogView functions
    public func addLog(_ log: Log!) {
        logs.append(log)
        tableView.reloadData()
    }
    
    public func clearLog() {
        logs.removeAll()
        tableView.reloadData()
    }
    
    // return the color of Log.Level
    private func logColor(level: Log.Level) -> UIColor! {
        switch level {
        case Log.Level.verbose:
            return verboseColor
        case Log.Level.debug:
            return debugColor
        case Log.Level.info:
            return infoColor
        case Log.Level.warning:
            return warningColor
        case Log.Level.error:
            return errorColor
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
        return logs.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let log = logs[indexPath.row]
        var label: UILabel? = cell?.viewWithTag(1) as? UILabel
        if label == nil {
            label = UILabel()
            label?.font = UIFont.systemFont(ofSize: 15)
            label?.numberOfLines = 0
            cell?.addSubview(label!)
        }
        label!.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: logHeight(log: log.log))
        label!.text = log.log
        label!.textColor = logColor(level: log.level)
        cell?.backgroundColor = UIColor.black
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return logHeight(log: logs[indexPath.row].log)
    }
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
    
    public class func v(_ log: String?) {
        addLog(log, level: Log.Level.verbose)
    }
    public class func d(_ log: String?) {
        addLog(log, level: Log.Level.debug)
    }
    public class func i(_ log: String?) {
        addLog(log, level: Log.Level.info)
    }
    public class func w(_ log: String?) {
        addLog(log, level: Log.Level.warning)
    }
    public class func e(_ log: String?) {
        addLog(log, level: Log.Level.error)
    }
    private class func addLog(_ log: String?, level: Log.Level!) {
        let log = Log(log: log, level: level)
        FKConsole.console.addLog(log)
    }
    
    var log: String!
    var level: Log.Level!
    init(log l: String?, level lv: Log.Level!) {
        level = lv
        guard let log_t = l else {
            self.log = ""
            return
        }
        log = log_t
    }
}
