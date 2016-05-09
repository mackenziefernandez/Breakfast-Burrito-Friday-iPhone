//
//  MyBurritosViewController.swift
//  Breakfast Burrito Friday
//
//  Created by Mackenzie Fernandez on 6/12/15.
//  Copyright (c) 2015 Mackenzie Fernandez. All rights reserved.
//

import UIKit
import SwiftDate
import SwiftyJSON
import SwiftOverlays
import Firebase


class MyBurritosViewController: UIViewController {
    
    @IBOutlet weak var thisFridayScrollView: UIScrollView!
    @IBOutlet weak var totalBurritoLabel: UILabel!
    @IBOutlet weak var totalBurritosView: UIView!
    
    var myRootRef = Constants.fireRef
    let todayDate = NSDate.today()
    var friday : NSDate?
    var keyArray = [String]()
    
    var totalsDict = [String: [Int]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showWaitOverlay()
        
        friday = thisFriday(todayDate)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        thisFridayScrollView.contentSize = CGSize(width:10, height:10)
    }
    
    override func viewDidAppear(animated: Bool) {
        // If the user is not authenticated, then make them log in
        self.thisFridayScrollView.scrollEnabled = true
        myRootRef.observeAuthEventWithBlock({ authData in
            
            if authData != nil {
                // user authenticated with Firebase
                //println(myRootRef.authData)
                //println(myRootRef.authData.providerData["email"]!)
                //println(myRootRef.authData.providerData!)
                self.getOrders(authData.uid)
            } else {
                // No user is logged in
                print("User is not logged in")
                
                // Segue (modally) to the login screen
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getOrders(userID : String) {
        // Get all the burritos ordered by user
        myRootRef.childByAppendingPath("orders").queryOrderedByChild("uid").queryEqualToValue(userID).observeEventType(.Value, withBlock: { snapshot in
                self.getAllBurritos(snapshot)
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    func addToFridayView(list: JSON) {
        for view in self.thisFridayScrollView.subviews {
            view.removeFromSuperview()
        }
        
        var count = 0
        keyArray = [String]()
        
        for (key, value) in list {
            if (value["friday"].string! == friday!.toString(DateFormat.Custom("YYYY-MM-dd"))) {
                let label = UILabel(frame: CGRectMake(self.thisFridayScrollView.bounds.origin.x + 5, self.thisFridayScrollView.bounds.origin.y + CGFloat(count*20), 100, 21))
                label.text = value["flavor"].string
                
                let button = UIButton(type: UIButtonType.System)
                button.frame = CGRectMake(self.thisFridayScrollView.bounds.origin.x + 5 + 100, self.thisFridayScrollView.bounds.origin.y + CGFloat(count*20), 200, 21)
                button.setTitle("Cancel", forState: .Normal)
                button.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
                button.tag = count
                keyArray.append(key)
                
                self.thisFridayScrollView.addSubview(label)
                self.thisFridayScrollView.addSubview(button)
                count++
            }
        }
    }
    
    func buttonAction(sender:UIButton!) {
        let path = "orders/"// + friday!.toString(format: DateFormat.Custom("YYYY-MM-dd"))
        // Delete the burrito order that has that key
        myRootRef.childByAppendingPath(path).childByAppendingPath(keyArray[sender.tag]).removeValueWithCompletionBlock({ error in
            print(error)
        })
    }
    
    func getAllBurritos(snapshot: FDataSnapshot) {
        //println("getting all burritos")
        self.totalsDict = [String: [Int]]()
        
        // Clear out the view so we don't have overlapping labels
        for view in self.totalBurritosView.subviews {
            view.removeFromSuperview()
        }
        
        let allOrdersJson = JSON(snapshot.value)
        self.totalBurritoLabel.text = "\(snapshot.childrenCount)"
        var tag = 1
        
        for (key, subJson): (String, JSON) in allOrdersJson {
            let flavor = subJson["flavor"].string!

            if totalsDict[flavor] != nil {
                // Flavor is already in the dictionary
                var arr = totalsDict[flavor]
                let burritoNum = arr![1]+1
                        
                totalsDict[flavor] = [arr![0],burritoNum]
                        
                var count = burritoNum/Int(snapshot.childrenCount)
            } else {
                // Flavor is new
                totalsDict[flavor] = [tag, 1]
                        
                // Add a label for this flavor and the number (and the percent)
                let label = UILabel(frame: CGRectMake(self.totalBurritosView.bounds.origin.x, self.totalBurritosView.bounds.origin.y + CGFloat(tag*20), 300, 21))
                label.tag = tag
                tag += 1
                let percentText = 100*1/snapshot.childrenCount
                label.text = "\(flavor): \(1) (\(CGFloat(percentText))%)"
                        
                self.totalBurritosView.addSubview(label)
            }
        }
        self.addToFridayView(allOrdersJson)
        self.updateLabels(Int(snapshot.childrenCount))
    }
    
    func updateLabels(totalBurritosOrdered: Int) {
        // Loop through to find all the elements with tags from the dictionary
        // Update the labels
        for (key, array) in totalsDict {
            let theLabel : UILabel = self.totalBurritosView.viewWithTag(array[0]) as! UILabel
            let percentText = 100*(array[1])/totalBurritosOrdered
            theLabel.text = "\(key): \(array[1]) (\(CGFloat(percentText))%)"
        }
        
        self.removeAllOverlays()
    }
}
