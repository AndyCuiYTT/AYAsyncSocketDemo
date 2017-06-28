//
//  AYSocketManager.swift
//  AYAsyncSocketClient
//
//  Created by Andy on 2017/6/28.
//  Copyright © 2017年 AndyCuiYTT. All rights reserved.
//




/**
 *  粘包丢包问题参考 : http://www.cocoachina.com/ios/20170209/18657.html
 *
 *  
 */

import UIKit

class AYSocketManager: NSObject, GCDAsyncSocketDelegate {
    
    
    private var clientSocket: GCDAsyncSocket!
    private var headerDic: [String : Any]? = nil // 处理接收信息用到
    
    private let serverUrl: String = "192.168.1.102"
    private let serverPort: UInt16 = 8080
    
    static let socketManager = AYSocketManager()
    
    override init() {
        super.init()
        clientSocket = GCDAsyncSocket()
        clientSocket.delegate = self
        clientSocket.delegateQueue = DispatchQueue.global()
    }
    
    
    /// 连接服务器
    func ay_socketConnect() -> Void {
        
        do {
            try clientSocket.connect(toHost: serverUrl, onPort: serverPort)
        } catch {
            print("socketConnect error")
            print(error)
        }
        
    }
    
    
    /// 断开 socket 链接
    func ay_disconnect() -> Void {
        if clientSocket.isConnected {
            clientSocket.disconnect()
        }
    }
    
    
    /// 发送消息
    ///
    /// - Parameter data: 消息的二进制
    func ay_sendMessageData(data: Data) -> Void {

        var headerDic: [String : Any] = [String : Any]();
        headerDic["size"] = data.count
        
        var mData = headerDic.ay_toJSONData()
        mData.append(GCDAsyncSocket.crlfData()) // 分界
        mData.append(data)
        
        clientSocket.write(mData, withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("连接成功")
        clientSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: 0)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("连接断开")
        print(err ?? "")
    }
    
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        
        if headerDic == nil {
            headerDic = data.ay_JSONToAny() as? [String : Any]
            
            if headerDic == nil {
                print("当前数据包头为空")
                clientSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: 0)
            }else {
                let length = headerDic?["size"] as! UInt
                clientSocket.readData(toLength: length, withTimeout: -1, tag: 0)
            }
            return;
        }
        
        let packetLength: UInt = headerDic?["size"] as! UInt
        if packetLength <= 0 || Int(packetLength) != data.count {
            print("当前数据包错误")
            clientSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: 0)
            return
        }
        
        // 处理 data 数据
        print(String(data: data, encoding: .utf8) ?? "")

        headerDic = nil
        
        
        clientSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: 0)
        
    }
    
}

extension Dictionary {
    
    /// 将字典转为 JSON 字符串
    ///
    /// - Returns: JSON 字符串
    func ay_toJSONData() -> Data {
        return try! JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
    }
}

extension Data {
    
    /// JSON 解析
    ///
    /// - Returns: JSON 解析后的对象
    func ay_JSONToAny() -> Any {
        do {
            let result = try JSONSerialization.jsonObject(with: self, options: .mutableContainers)
            return result
        } catch  {
            return self
        }
    }
    
}

