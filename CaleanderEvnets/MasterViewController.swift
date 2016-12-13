//
//  MasterViewController.swift
//  CaleanderEvnets
//
//  Created by tinkl on 12/13/16.
//  Copyright © 2016 tinkl. All rights reserved.
//

import UIKit

import EventKit
import EventKitUI


class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [AnyObject]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        testCalander()
       
        
    }
    
    
    func testCalander() {
        
        let eventStore = EKEventStore()
        
        let tempFormatter = NSDateFormatter()
        tempFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        //获取一个时间段中的日历事件
        let startDate = tempFormatter.dateFromString("10.08.2016 15:10")!
        let endDate = tempFormatter.dateFromString("20.12.2016 15:30")!
        
        let predicate = eventStore.predicateForEventsWithStartDate(startDate, endDate: endDate, calendars: [eventStore.defaultCalendarForNewEvents])
        
        //获取这个时间段中的所有日程
        let events: [EKEvent] = eventStore.eventsMatchingPredicate(predicate)
        
        events.forEach { (event) in
            print("\(event.title)")
        }
        
        
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        objects.insert(NSDate(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        //新建日历事件
        insertCalender()
    }
    
    func insertCalender() {
        let eventStore = EKEventStore()
        
        eventStore.requestAccessToEntityType(.Event) { (granted, error) in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if error != nil {
                    //发生错误
                } else if !granted {
                    //不允许访问日历
                } else {
                    
                    //创建事件
                    let event = EKEvent(eventStore: eventStore)
                    event.title = "免费下载最新游戏，送50元话费"
                    event.location = "这年头，发广告诱导强制分享不是事儿，发广告诱导强制分享还不被微信封才是真事儿。据说这套黑客宝典能让张小龙梦碎，能让微商实现我的梦，营销梦。http://weixin.qq.com/"
                    event.notes = "这年头，发广告诱导强制分享不是事儿，发广告诱导强制分享还不被微信封才是真事儿。据说这套黑客宝典能让张小龙梦碎，能让微商实现我的梦，营销梦。"
                    event.URL = NSURL(string: "http://weixin.qq.com/")
                    
                    let tempFormatter = NSDateFormatter()
                    tempFormatter.dateFormat = "dd.MM.yyyy HH:mm"
                    
                    //创建一个时间段的日历事件
                    event.startDate = tempFormatter.dateFromString("13.12.2016 12:13")!
                    event.endDate = tempFormatter.dateFromString("13.12.2016 12:40")!
                    
                    //设置是否为全天事件
                    //event.allDay = true
                    
                    //设置事件的提醒时间（相对时间）提前5分钟提醒
                    //event.addAlarm(EKAlarm(relativeOffset: -60.0 * 5.0))
                    //设置事件的提醒时间（绝对时间）
                    event.addAlarm(EKAlarm(absoluteDate: NSDate(timeInterval: -60 * 1, sinceDate: event.startDate)))
                    
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    
                    //保存事件，添加到日历中
                    do {
                        try eventStore.saveEvent(event, span: .ThisEvent, commit: true)
                        print("insert OK")
                    } catch {
                        print("insert Error")
                    }
                }
                
            })
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row] as! NSDate
        cell.textLabel!.text = object.description
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
         testCalander()
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

