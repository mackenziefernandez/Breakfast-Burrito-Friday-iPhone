//
//  BurritoTableViewController.swift
//  Breakfast Burrito Friday
//
//  Created by Mackenzie Fernandez on 3/17/15.
//  Copyright (c) 2015 Mackenzie Fernandez. All rights reserved.
//

import UIKit
import SwiftDate
import SwiftyJSON
import SwiftOverlays

extension Array {
    mutating func removeOne <U: Equatable> (object: U) {
        for i in stride(from: self.count-1, through: 0, by: -1) {
            if let element = self[i] as? U {
                if element == object {
                    self.removeAtIndex(i)
                    break
                }
            }
        }
    }
    mutating func remove <U: Equatable> (object: U) {
        for i in stride(from: self.count-1, through: 0, by: -1) {
            if let element = self[i] as? U {
                if element == object {
                    self.removeAtIndex(i)
                }
            }
        }
    }
}

class BurritoTableViewController: UITableViewController {
    
    // Create a reference to a Firebase location
    var myRootRef = Firebase(url:"https://bbfriday.firebaseio.com")
    let todayDate = NSDate.today()
    var friday : NSDate?
        var orderDict = [String: [String]]()
    
    @IBOutlet var burritoTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showWaitOverlay()
        
        friday = thisFriday(todayDate)
        
        var fridayString = friday!.toString(format: DateFormat.Custom("YYYY-MM-dd"))
        var fridayPath = myRootRef.childByAppendingPath("orders/")
        
        myRootRef.childByAppendingPath("orders").queryOrderedByChild("friday").queryEqualToValue(fridayString).observeEventType(.Value, withBlock: { snapshot in
            println(snapshot)
            
            self.setOrders(snapshot)
            
            }, withCancelBlock: { error in
                println(error.description)
        })
    }
    
    func setOrders(snapshot: FDataSnapshot) {
        // Make sure the order dictionary is empty before starting!
        self.orderDict = [String: [String]]()
        
        let json = JSON(snapshot.value)
        println(json)
        
        for (key,subJson) in json {
            println(subJson)
            var flavor = subJson["flavor"].string
            var uid = subJson["uid"].string
            
            // Get users name, add name and flavor to dictionary
            var path = "users/" + uid!
            myRootRef.childByAppendingPath(path).observeEventType(.Value, withBlock: {snapshot2 in
                let jsonName = JSON(snapshot2.value)
                var name = jsonName["name"].string
                
                if var arr = self.orderDict[flavor!] {
                    arr.append(name!)
                    self.orderDict[flavor!] = arr
                }
                else {
                    self.orderDict[flavor!] = [name!]
                }
                
                self.burritoTableView.reloadData()
                
                
                }, withCancelBlock: { error2 in
                    println("error with finding name: \(error2)")
            })
            
        }
        
        self.removeAllOverlays()
    }
    
    func thisFriday(referenceDate:NSDate) -> NSDate {
        if (referenceDate.weekdayName == "Friday") {
            return referenceDate
        }
        else {
            return thisFriday(referenceDate+1.day)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.orderDict.count
    }
    
    //UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        //performSegueWithIdentifier("showBookDetail", sender: self)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var keyArray = [String]()
        
        for (key, value) in self.orderDict {
            keyArray.append(key)
        }
        println("orderDict empty?")
        println(self.orderDict.isEmpty)
        var valueArray = self.orderDict[keyArray[indexPath.row]]!
        
        //let bookDict = fetchedResultsController.objectAtIndexPath(indexPath) as BookModel
        var cell: BurritoTableViewCell = tableView.dequeueReusableCellWithIdentifier("cell") as! BurritoTableViewCell
        cell.numberOfBurritosLabel.text = "\(self.orderDict[keyArray[indexPath.row]]!.count)" //self.orderDict[indexPath]!.count
        cell.burritoFlavorLabel.text = "\(keyArray[indexPath.row])"
        
        // First three names and then number for the additional names
        //        var count = 0
        //        var whoOrderedText = ""
        //        for value in self.orderDict[keyArray[indexPath.row]]! {
        //            if count == 3 {
        //                whoOrderedText += value + " and "
        //            }
        //        }
        
        var whoOrderedText = ""
        for (index, value) in enumerate(valueArray) {
            if index == 0 {
                whoOrderedText = whoOrderedText + value
            }
            else {
                whoOrderedText = whoOrderedText + ", " + value
            }
        }
        
        cell.whoOrderedLabel.text = whoOrderedText
        
        return cell
    }
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
