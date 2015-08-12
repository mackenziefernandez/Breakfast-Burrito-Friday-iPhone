//
//  TeamViewController.swift
//  Breakfast Burrito Friday
//
//  Created by Mackenzie Fernandez on 7/23/15.
//  Copyright (c) 2015 Mackenzie Fernandez. All rights reserved.
//

import UIKit
import SwiftOverlays
import SwiftDate
import SwiftyJSON

class TeamViewController: UIViewController {
    
    // Create a reference to a Firebase location
    var myRootRef = Firebase(url:"https://bbfriday.firebaseio.com")
    let todayDate = NSDate.today()
    var friday : NSDate?
    
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var numberOfOrdersLabel: UILabel!
    @IBOutlet weak var sinceTeamBeganLabel: UILabel!
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var ordersForThisFridayLabel: UILabel!
    
    @IBOutlet weak var thisFridayOrderScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showWaitOverlay()
        
        friday = thisFriday(todayDate)
        var fridayString = friday!.toString(format: DateFormat.Custom("YYYY-MM-dd"))
        
        myRootRef.childByAppendingPath("orders").queryOrderedByChild("friday").queryEqualToValue(fridayString).observeEventType(.Value, withBlock: { snapshot in
            println(snapshot)
            
            //self.setOrders(snapshot)
            
            }, withCancelBlock: { error in
                println(error.description)
        })

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func changeTeamButtonPressed(sender: UIButton) {
        
    }
    
    @IBAction func changeMenuButtonPressed(sender: UIButton) {
        
    }
    
    func thisFriday(referenceDate:NSDate) -> NSDate {
        if (referenceDate.weekdayName == "Friday") {
            return referenceDate
        }
        else {
            return thisFriday(referenceDate+1.day)
        }
    }
    
}
