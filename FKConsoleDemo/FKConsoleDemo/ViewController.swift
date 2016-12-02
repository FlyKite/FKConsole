//
//  ViewController.swift
//  FKConsoleDemo
//
//  Created by FlyKite on 2016/12/2.
//  Copyright © 2016年 FlyKite. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let field = UITextField.init(frame: CGRect(x: 50, y: 100, width: 250, height: 20))

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        field.placeholder = "Log message..."
        self.view.addSubview(field)
        
        let button = UIButton.init(type: UIButtonType.system)
        button.frame = CGRect(x: 50, y: 120, width: 100, height: 50)
        button.setTitle("print it", for: UIControlState.normal)
        button.addTarget(self, action: #selector(printMessage), for: UIControlEvents.touchUpInside)
        self.view.addSubview(button)
        
        let tips = UILabel.init(frame: CGRect(x: 50, y: 200, width: 250, height: 100))
        tips.text = "Swipe up with 3 fingers to show console window, you should register FKConsole before use it (see AppDelegate)."
        tips.numberOfLines = 0
        self.view.addSubview(tips)
        
        Log.d("Debug start...")
    }
    
    func printMessage() {
        Log.v(field.text)
        Log.d(field.text)
        Log.i(field.text)
        Log.w(field.text)
        Log.e(field.text)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

