//
//  ViewController.swift
//  FM
//
//  Created by 吴国柱 on 15/6/29.
//  Copyright (c) 2015年 吴国柱. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation
import QuartzCore

class ViewController: UIViewController ,UITableViewDataSource ,UITableViewDelegate ,httpprotocol,channelprotocol{
    
    @IBOutlet weak var pauseimg: UIImageView!
    @IBOutlet var tap: UITapGestureRecognizer!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var lv: UILabel!
    @IBOutlet weak var iv: UIImageView!
    @IBOutlet weak var pv: UIProgressView!
    
    var doubandata:NSArray = NSArray()   //播放列表的数组
    var channeldata:NSArray = NSArray()           //频道列表的数组
    var ehttp:httpcontroller = httpcontroller()
    var imagecache = Dictionary<String,UIImage>()
    var audioPlayer:MPMoviePlayerController = MPMoviePlayerController()
    var time:NSTimer?
    var cursongindex:NSInteger = 0
    var avs:AVAudioSession = AVAudioSession()

    //监听触摸手势
    @IBAction func tapped(sender: AnyObject) {
        if sender.view == iv {
            pauseimg.hidden = false
            audioPlayer.pause()
            pauseimg.addGestureRecognizer(tap)
            iv.removeGestureRecognizer(tap)
        }
        else if sender.view == pauseimg {
            pauseimg.hidden = true
            audioPlayer.play()
            avs.setActive(true, error: nil)
            avs.setCategory(AVAudioSessionCategoryPlayback, error: nil)
            pauseimg.removeGestureRecognizer(tap)
            iv.addGestureRecognizer(tap)
        }
    }
    
    //选择频道后把频道ID传进新的URL再发送新的HTTP请求
    func channelchanged(channelid: String) {
        let url:String = "http://douban.fm/j/mine/playlist?channel=\(channelid)"
        ehttp.onsearch(url)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doubandata.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    
    
    //初始化播放列表的TableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let doubancell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "douban")
        let rowdata:NSDictionary = self.doubandata[indexPath.row] as! NSDictionary
        doubancell.textLabel?.text = rowdata["title"] as? String
        doubancell.detailTextLabel?.text = rowdata["artist"] as? String
        doubancell.imageView?.image = UIImage(named: "default.png")
        let url = rowdata["picture"] as! String
        let image = self.imagecache[url] as UIImage?
        if !(image != nil) {
            let imgurl:NSURL = NSURL(string:url)!
            let request:NSURLRequest = NSURLRequest(URL: imgurl)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(
                response:NSURLResponse!,data:NSData!,error:NSError!
                )->Void in
                let img = UIImage(data:data)
                doubancell.imageView?.image = img
                self.imagecache[url] = img
            })
        }
        else {
            doubancell.imageView?.image = image
        }
        doubancell.selectionStyle = UITableViewCellSelectionStyle.Gray
        return doubancell
    }
    
    //添加显示播放列表时的动画效果
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
    
    
    //选择TablieView上某个Cell之后做的动作
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let rowdata:NSDictionary = self.doubandata[indexPath.row] as! NSDictionary
        let audiourl:String = rowdata["url"] as! String
        let imgurl:String = rowdata["picture"] as! String
        cursongindex = indexPath.row
        setaudio(audiourl)
        setimage(imgurl)
        tv.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    
    
    //加载页面完成后的函数，设置了ImageView的触摸监听 和 摇一摇的动作监听
    override func viewDidLoad() {
        super.viewDidLoad()
        NSThread.sleepForTimeInterval(2)
        ehttp.delegate = self
        ehttp.onsearch("http://www.douban.com/j/app/radio/channels")
        ehttp.onsearch("http://douban.fm/j/mine/playlist?channel=0")
        // Do any additional setup after loading the view, typically from a nib.
        iv.addGestureRecognizer(tap)
        UIApplication.sharedApplication().applicationSupportsShakeToEdit = true
        self.becomeFirstResponder()
    }
    
    
    //摇一摇动作之后实现的函数（随机播放播放列表内的歌）
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent){
        if motion == UIEventSubtype.MotionShake {
            var randrow:NSInteger = random() % self.doubandata.count as NSInteger
            var randdict:NSDictionary = self.doubandata[randrow] as! NSDictionary
            var audiourl:String = randdict["url"] as! String
            var imgurl:String = randdict["picture"] as! String
            setaudio(audiourl)
            setimage(imgurl)
        }
    }
    
    
    //转换页面时传值，把加载时获取到的频道数组传进channelcontroller的channeldata里
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var channelC:channelcontroller = segue.destinationViewController as! channelcontroller
        channelC.delegate = self
        channelC.channeldata = self.channeldata
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //通过一个字典设置播放列表
    func didrr(result: NSDictionary) {
        if let song: AnyObject = result["song"] {
            self.doubandata = song as! NSArray
            self.tv.reloadData()
            let firstd:NSDictionary = self.doubandata[0] as! NSDictionary
            let audiourl:String = firstd["url"] as! String
            let imgurl:String = firstd["picture"] as! String
            cursongindex = 0
            setaudio(audiourl)
            setimage(imgurl)
        }
         if let channel: AnyObject = result["channels"] {
            self.channeldata = channel as! NSArray
        }
    }
    
    
    //通过一个URL来设置播放的音乐，同时在时间间隔内不断执行update函数
    func setaudio(url:String){
        time?.invalidate()
        lv.text = "00:00"
        self.audioPlayer.stop()
        self.audioPlayer.contentURL = NSURL(string: url)
        self.audioPlayer.play()
        avs.setActive(true, error: nil)
        avs.setCategory(AVAudioSessionCategoryPlayback, error: nil)
        time = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "update", userInfo: nil, repeats: true)
        pauseimg.removeGestureRecognizer(tap)
        iv.addGestureRecognizer(tap)
        pauseimg.hidden = true
    }
    
    
    //update函数，播放音乐时不断执行这个函数，目的是为了更新进度条和播放时间的Lable
    func update(){
        var c = audioPlayer.currentPlaybackTime
        if c > 0.0 {
            let t = audioPlayer.duration
            let p:CFloat = CFloat(c/t)
            pv.setProgress(p, animated: true)
        }
        if c > -1.0 {
            let m = Int(c % 60.0)
            let f = Int(c / 60.0)
            var sj:String = ""
            if f < 10 {
                sj = "0\(f)"
            }else {
                sj = "\(f)"
            }
            if m < 10 {
                sj += ":0\(m)"
            }else {
                sj += ":\(m)"
            }
            lv.text = sj
        }
    }
    
    
    //通过一个URL设置音乐的图片
    func setimage(url:String){
        let image = self.imagecache[url] as UIImage?
        if !(image != nil) {
            let imgurl:NSURL = NSURL(string:url)!
            let request:NSURLRequest = NSURLRequest(URL: imgurl)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(
                response:NSURLResponse!,data:NSData!,error:NSError!
                )->Void in
                let img = UIImage(data:data)
                self.iv.image = img
                self.imagecache[url] = img
            })
        }
        else {
            self.iv.image = image
        }
        
    }

}

