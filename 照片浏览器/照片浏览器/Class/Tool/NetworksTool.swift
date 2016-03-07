//
//  NetworksTool.swift
//  照片浏览器
//
//  Created by apple on 16/3/6.
//  Copyright © 2016年 xiaomage. All rights reserved.
//

import UIKit
import AFNetworking

class NetworksTool: AFHTTPSessionManager {
    // 设计swift单例
    static let shareInstance : NetworksTool = {
        let tools = NetworksTool()
        tools.responseSerializer.acceptableContentTypes?.insert("text/html")
        
        return tools
    }()
    
    // 给闭包起别名
    typealias FinishedCallBack = (results : [[String : AnyObject]]?, error : NSError?) -> ()
}

// MARK:- 请求数据
extension NetworksTool {
    func loadData(page : Int, offset : Int, finished : FinishedCallBack) {
        
        // 1.获取请求的URL
        let urlString = "http://mobapi.meilishuo.com/2.0/twitter/popular.json?_sign=cb1eae5a6e78cc0022c4a7346c726908cc8224f4&_res=750%2A1334&mac=02%3A00%3A00%3A00%3A00%3A00&st=1448412747&open_udid=8304383f121a72f64fe0172f970a90ef80b1f78f&idfa=ADD6861B-1B6E-467F-B33C-2D4D5CC59A47&offset=\(offset)&limit=30&idfv=B366E59B-2C37-41ED-9D8E-8F86230CBA2B&device_id=oudid_8304383f121a72f64fe0172f970a90ef80b1f78f&page=\(page)&access_token=b92e0c6fd3ca919d3e7547d446d9a8c2"
        
        // 2.发送网络请求
        GET(urlString, parameters: nil, progress: nil, success: { (_, result) -> Void in
            // 1.判断结果是否为正确的字典
            guard let resultDict = result else {
                finished(results: nil, error: NSError(domain: "com.520it.why", code: 1000, userInfo: ["errorInfo" : "获取数据不正确"]))
                return
            }
            
            // 2.从字典中取出数组
            guard let shopDicts = resultDict["data"] as? [[String: AnyObject]] else {
                finished(results: nil, error: NSError(domain: "com.520it.why", code: 1001, userInfo: ["errorInfo" : "获取数据不正确"]))
                return
            }
            
            finished(results: shopDicts, error: nil)
            
            }) { (task, error) -> Void in
                finished(results: nil, error: error)
        }
    }
}
