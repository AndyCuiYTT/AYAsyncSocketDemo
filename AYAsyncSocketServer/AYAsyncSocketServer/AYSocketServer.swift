//
//  AYSocketServer.swift
//  AYAsyncSocketServer
//
//  Created by Andy on 2017/6/28.
//  Copyright © 2017年 AndyCuiYTT. All rights reserved.
//

import UIKit

class AYSocketServer: NSObject, GCDAsyncSocketDelegate {

    var serverSocket: GCDAsyncSocket!
    var clientSockets: [GCDAsyncSocket] = [GCDAsyncSocket]() // 保存链接的客户端 socke 的向客户端发送消息是用的该 socket
    private var headerDic: [String : Any]? = nil

    
    static let socketServer = AYSocketServer()
    
    override init() {
        super.init()
        serverSocket = GCDAsyncSocket()
        serverSocket.delegate = self
        serverSocket.delegateQueue = DispatchQueue.global()
    }
    
    func startServer() -> Void {
        do {
            try serverSocket.accept(onPort: 8080)
        } catch  {
            print(error)
        }
    }
    
    
    
    func ay_sendMessageData(data: Data) -> Void {
        
        var headerDic: [String : Any] = [String : Any]();
        headerDic["size"] = data.count
        
        var mData = headerDic.ay_toJSONData()
        mData.append(GCDAsyncSocket.crlfData()) // 分界
        mData.append(data)
        
        clientSockets.first?.write(mData, withTimeout: -1, tag: 0)
    }

    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        print("新的连接")
        clientSockets.append(newSocket)
        newSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: 0)
        
    }
    
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        
        // socket 为客户端链接 socket
        
        if headerDic == nil {
            headerDic = data.ay_JSONToAny() as? [String : Any]
            
            if headerDic == nil {
                print("当前数据包头为空")
                sock.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: 0)
            }else {
                let length = headerDic?["size"] as! UInt
                sock.readData(toLength: length, withTimeout: -1, tag: 0)
            }
            return;
        }
        
        let packetLength: UInt = headerDic?["size"] as! UInt
        if packetLength <= 0 || Int(packetLength) != data.count {
            print("当前数据包错误")
            sock.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: 0)
            return
        }
        
        headerDic = nil
        // 处理 data 数据
        
        print(String(data: data, encoding: .utf8) ?? "")
        
        
        sock.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: 0)
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

