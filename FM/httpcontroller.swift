//
//  httpcontroller.swift
//  FM
//
//  Created by 吴国柱 on 15/6/29.
//  Copyright (c) 2015年 吴国柱. All rights reserved.
//

import UIKit

protocol httpprotocol{
    func didrr(result:NSDictionary)
}



//一个发送HTTP请求的类
class httpcontroller:NSObject{
    
    var delegate:httpprotocol?
    
    func onsearch(url:String){
        var URL = NSURL(string:url)
        var request = NSURLRequest(URL: URL!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(respondse:NSURLResponse!,data:NSData!,error:NSError!) -> Void in
            var jsonr:NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary!
            self.delegate?.didrr(jsonr)
        })

    }
}
