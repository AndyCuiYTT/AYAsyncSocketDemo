//
//  ViewController.swift
//  AYAsyncSocketClient
//
//  Created by Andy on 2017/6/28.
//  Copyright © 2017年 AndyCuiYTT. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var messageTextFiled: UITextField!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func connectAction(_ sender: UIButton) {
        
        AYSocketManager.socketManager.ay_socketConnect()
    }
    
    
    
    @IBAction func senderAction(_ sender: UIButton) {
        AYSocketManager.socketManager.ay_sendMessageData(data: (messageTextFiled.text?.data(using: .utf8))!)
    }
    


}

