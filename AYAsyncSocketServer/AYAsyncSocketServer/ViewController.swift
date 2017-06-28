//
//  ViewController.swift
//  AYAsyncSocketServer
//
//  Created by Andy on 2017/6/28.
//  Copyright © 2017年 AndyCuiYTT. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        AYSocketServer.socketServer.startServer()
//        RunLoop.current.run()
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        AYSocketServer.socketServer.ay_sendMessageData(data: "ddddddd".data(using: .utf8)!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

