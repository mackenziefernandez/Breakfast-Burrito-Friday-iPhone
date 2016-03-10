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
import Firebase

extension Array {
    mutating func removeOne <U: Equatable> (object: U) {
        for i in (self.count-1).stride(through: 0, by: -1) {
            if let element = self[i] as? U {
                if element == object {
                    self.removeAtIndex(i)
                    break
                }
            }
        }
    }
    mutating func remove <U: Equatable> (object: U) {
        for i in (self.count-1).stride(through: 0, by: -1) {
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
    var myRootRef = Constants.fireRef
    let todayDate = NSDate.today()
    var friday : NSDate?
        var orderDict = [String: [String]]()
    
    @IBOutlet var burritoTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showWaitOverlay()
        
        friday = thisFriday(todayDate)
        
        let fridayString = friday!.toString(DateFormat.Custom("YYYY-MM-dd"))
//        var fridayPath = myRootRef.childByAppendingPath("orders/")
        
        myRootRef.childByAppendingPath("orders").queryOrderedByChild("friday").queryEqualToValue(fridayString).observeEventType(.Value, withBlock: { snapshot in
            print(snapshot)
            
            self.setOrders(snapshot)
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    func setOrders(snapshot: FDataSnapshot) {
        // Make sure the order dictionary is empty before starting!
        self.orderDict = [String: [String]]()
        
        let json = JSON(snapshot.value)
        print(json)
        
        for (_,subJson) in json {
            print(subJson)
            let flavor = subJson["flavor"].string
            let uid = subJson["uid"].string
            
            // Get users name, add name and flavor to dictionary
            let path = "users/" + uid!
            myRootRef.childByAppendingPath(path).observeEventType(.Value, withBlock: {snapshot2 in
                let jsonName = JSON(snapshot2.value)
                let name = jsonName["name"].string
                
                if var arr = self.orderDict[flavor!] {
                    arr.append(name!)
                    self.orderDict[flavor!] = arr
                }
                else {
                    self.orderDict[flavor!] = [name!]
                }
                
                self.burritoTableView.reloadData()
                
                
                }, withCancelBlock: { error2 in
                    print("error with finding name: \(error2)")
            })
            
        }
        
        self.removeAllOverlays()
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
        return self.orderDict.isEmpty ? 1 : self.orderDict.count
    }
    
    //UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        //performSegueWithIdentifier("showBookDetail", sender: self)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: BurritoTableViewCell = tableView.dequeueReusableCellWithIdentifier("cell") as! BurritoTableViewCell
        
        if (!self.orderDict.isEmpty) {
            var keyArray = [String]()
            
            for (key, _) in self.orderDict {
                keyArray.append(key)
            }
            let valueArray = self.orderDict[keyArray[indexPath.row]]!

            cell.numberOfBurritosLabel.text = "\(self.orderDict[keyArray[indexPath.row]]!.count)" //self.orderDict[indexPath]!.count
            cell.burritoFlavorLabel.text = "\(keyArray[indexPath.row])"
            
            var whoOrderedText = ""
            for (index, value) in valueArray.enumerate() {
                if index == 0 {
                    whoOrderedText = whoOrderedText + value
                }
                else {
                    whoOrderedText = whoOrderedText + ", " + value
                }
            }
            
            cell.whoOrderedLabel.text = whoOrderedText
        } else {
            cell.numberOfBurritosLabel.text = "0"
            cell.burritoFlavorLabel.text = "Burritos have been ordered"
            cell.whoOrderedLabel.text = "Sad day"
        }
        
        // First three names and then number for the additional names
        //        var count = 0
        //        var whoOrderedText = ""
        //        for value in self.orderDict[keyArray[indexPath.row]]! {
        //            if count == 3 {
        //                whoOrderedText += value + " and "
        //            }
        //        }
        

        
        return cell
    }
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
