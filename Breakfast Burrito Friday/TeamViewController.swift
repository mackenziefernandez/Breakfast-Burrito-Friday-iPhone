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
import Firebase

class TeamViewController: UIViewController {
    
    // Create a reference to a Firebase location
    var myRootRef = Constants.fireRef
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
        let fridayString = friday!.toString(DateFormat.Custom("YYYY-MM-dd"))
        
        myRootRef.childByAppendingPath("orders").queryOrderedByChild("friday").queryEqualToValue(fridayString).observeEventType(.Value, withBlock: { snapshot in
            print(snapshot)
            
            //self.setOrders(snapshot)
            
            }, withCancelBlock: { error in
                print(error.description)
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
    
}
