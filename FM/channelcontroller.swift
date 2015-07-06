//
//  channelcontroller.swift
//  FM
//
//  Created by 吴国柱 on 15/6/29.
//  Copyright (c) 2015年 吴国柱. All rights reserved.
//

import UIKit
protocol channelprotocol{
    func channelchanged(channelid:String)
}

class channelcontroller: UIViewController ,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tv: UITableView!
    
    var channeldata:NSArray = NSArray()
    var delegate:channelprotocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func backtomain(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channeldata.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let channelcell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "channel")
        let rowdata:NSDictionary = self.channeldata[indexPath.row] as! NSDictionary
        channelcell.textLabel?.text = rowdata["name"] as? String
        return channelcell
    }
    
    
    
    //加载频道列表是添加动画效果
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
    
    
    //选择频道某个Cell后返回那个Cell对应的channel_id
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var rowdata:NSDictionary = self.channeldata[indexPath.row] as! NSDictionary
        let channelid:AnyObject = (rowdata["channel_id"] as AnyObject?)!
        let channel:String = "\(channelid)"
        delegate?.channelchanged(channel)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}