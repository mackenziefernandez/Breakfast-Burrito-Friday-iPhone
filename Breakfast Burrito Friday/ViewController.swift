//
//  ViewController.swift
//  Breakfast Burrito Friday
//
//  Created by Mackenzie Fernandez on 3/13/15.
//  Copyright (c) 2015 Mackenzie Fernandez. All rights reserved.
//

import UIKit

import SwiftDate
import SwiftyJSON
import SwiftOverlays
import Firebase

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var burritoPickerView: UIPickerView!
    
    @IBOutlet var uiBurritoView: UIView!
    @IBOutlet weak var greetingsLabel: UILabel!
    
    
    let tapRec = UITapGestureRecognizer() // Tap gesture inserted manually to the view
    let burritoArray = ["Chorizo", "Sausage", "Bacon", "Cheese"]//, "Unicorn"]
    var selectedFlavor = "Chorizo"
    
    let todayDate = NSDate()
    
    // Create a reference to a Firebase location
    var myRootRef = Constants.fireRef
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // TapGestureRecognizer Setup
        tapRec.addTarget(self, action: "tappedView")
        uiBurritoView.addGestureRecognizer(tapRec)
        uiBurritoView.userInteractionEnabled = true
        
        burritoPickerView.delegate = self
        burritoPickerView.dataSource = self
        
        myRootRef.observeAuthEventWithBlock({ authData in
            if authData != nil {
                // Make sure that the user has a name in the database
                //println(authData.uid)
                let path = "users/" + authData.uid
                self.myRootRef.childByAppendingPath(path).observeEventType(.Value, withBlock: {snapshot2 in
                    let jsonName = JSON(snapshot2.value)
                    
                    if let name = jsonName["name"].string {
                        // Then display this name in the title
                        // But make sure to get the custom greeting, if it exists
                        if let greeting = jsonName["greeting"].string {
                            self.greetingsLabel.text = greeting + ", " + name
                        } else {
                            self.greetingsLabel.text = "Hello, " + name
                        }
                    } else {
                        // Make an alert to gather the name
                        self.getNameAlert("What should I call you?", message: "I don't know what to call you! What's your name?", style: .Alert)
                    }
                    
                    
                    
                    }, withCancelBlock: { error2 in
                        print("error with finding name: \(error2)")
                        
                        // Make an alert to gather the name
                        self.getNameAlert("What should I call you?", message: "I don't know what to call you! What's your name?", style: .Alert)
                })
            } else {
                // No user is logged in
                print("User is not logged in")
                
                // Segue (modally) to the login screen
                //self.performSegueWithIdentifier("loginSegue", sender: self)
            }
        })

    }
    
    func displayAlert(title:String, message:String, style: UIAlertControllerStyle) {
        // Make an error message alert thingy
        //1. Create the alert controller.
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func getNameAlert(title:String, message:String, style: UIAlertControllerStyle) {
        // Make an error message alert thingy
        //1. Create the alert controller.
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
        })
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] 
                        print("Add username: \(textField.text)")
            if textField.text == "" {
                textField.text = "Unnamed Loser"
            }
            
            // Search for the user with the uid of the current users uid
            self.myRootRef.childByAppendingPath("users/" + self.myRootRef.authData.uid).updateChildValues(["name":textField.text!], withCompletionBlock: {(error:NSError?, ref:Firebase!) in
                if (error != nil) {
                    print("Data could not be saved.")
                } else {
                    print("Data saved successfully!")
                }
            })
        }))

        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Tapped View
    func tappedView(){
        // Dismiss the keyboard specifically
        // nameTextField.resignFirstResponder()
        self.removeAllOverlays()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView,
        numberOfRowsInComponent component: Int) -> Int {
            return burritoArray.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedFlavor = burritoArray[row]
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let titleData = burritoArray[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "RobotoCondensed-Regular", size: 26.0)!, NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .Center
        return pickerLabel
    }
    
    @IBAction func burritoMeButtonPressed(sender: UIButton) {
        
        let gifsRef = myRootRef.childByAppendingPath("fun/gifs")
        
        gifsRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let jsonGifs = JSON(snapshot.value)
            print(jsonGifs.count)
            var gifURL = ""
            let random = Int(arc4random_uniform(UInt32(jsonGifs.count)) + 1) // Since we are grabbing numbers between 0 and 2
            var i = 1
            for (key, value) in jsonGifs {
                if (i == random) {
                    print("random number is \(random)")
                    print(key)
                    print(value["url"])
                    gifURL = value["url"].string!
                    let url = NSURL(string: gifURL)
        let data = NSData(contentsOfURL: url!)
//                    self.showImageAndTextOverlay(PPSwiftGifs.animatedImageWithGIFData(data!)!, text: "\nYour burrito is on it's way!")
                }
                i += 1
            }
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        
        
        
//        self.confirmationImageView.image = PPSwiftGifs.animatedImageWithGIFData(data!)
//        self.confirmationImageView.hidden = false
        
        
        
        let userid: String = myRootRef.authData.uid as String
        
        let friday = thisFriday(todayDate)
        
        let fridayString = friday.toString(DateFormat.Custom("YYYY-MM-dd"))
        
        let orderPath = "orders/" //+ fridayString
        // Write data to Firebase
        let orderRef = myRootRef.childByAppendingPath(orderPath)
        let orderRef1 = orderRef.childByAutoId()
        let theOrder = NSMutableDictionary(objects: [todayDate.toString(DateFormat.Custom("YY-MM-dd"))!, userid, selectedFlavor, fridayString!], forKeys: ["orderedDate", "uid", "flavor", "friday"])
        orderRef1.setValue(theOrder)
        
        
        // Segue to see the orders they made (and can edit)
    }

}

