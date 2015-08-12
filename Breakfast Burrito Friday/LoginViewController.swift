//
//  LoginViewController.swift
//  Breakfast Burrito Friday
//
//  Created by Mackenzie Fernandez on 6/3/15.
//  Copyright (c) 2015 Mackenzie Fernandez. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    let ref = Firebase(url: "https://bbfriday.firebaseio.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        // If the user is not authenticated, then make them log in
        
//        ref.observeAuthEventWithBlock({ authData in
//            
//            if authData != nil {
//                // user authenticated with Firebase
//                //self.dismissViewControllerAnimated(true, completion: nil)
//            } else {
//                // No user is logged in
//                println("User is not logged in")
//                
//                // Segue (modally) to the login screen
//                //self.dismissViewControllerAnimated(true, completion: nil)
//            }
//        })
    }
    
    @IBAction func forgotPasswordButtonPressed(sender: UIButton) {
        // Gather the user's email in an alert and then call the send email function
        // Make an error message alert thingy
        //1. Create the alert controller.
        var alert = UIAlertController(title: "Forgot Password", message: "Please enter your email", preferredStyle: .Alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
        })
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Done", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as! UITextField
            println("New Password for: \(textField.text)")
            
            self.ref.resetPasswordForUser(textField.text, withCompletionBlock: { error in
                if (error != nil) {
                    println("error")
                }
                else {
                    println("no error")
                    self.displayAlert("New Password Sent", message: "Your new and shiny password has been sent! Check your email :)", style: .Alert)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "createLoginSegue" {
            let createLogVC: CreateLoginViewController = segue.destinationViewController as! CreateLoginViewController
        }
    }
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        // Change the button text to say that they are being logged in
        self.loginButton.setTitle("Logging in ...", forState: .Normal)
        
        // If the user is authenticated, then segue to the next view
        ref.authUser(emailTextField.text, password: passwordTextField.text,
            withCompletionBlock: { error, authData in
                
                if error != nil {
                    // There was an error logging in to this account
                    println("There was an error")
                    println(error)
                    
                    var errorMessage = "Wow, nice job. I'm giving you a default error message because I don't even know what you did wrong."
                    if error.code == -6 {
                        errorMessage = "Take a look at that password again and make sure it's the right one!"
                    }
                    if error.code == -5 {
                        errorMessage = "Well that email certainly isn't right. Try again"
                    }
                    
                    self.displayAlert("Uh-oh!", message: errorMessage, style: .Alert)
                    
                } else {
                    // We are now logged in
                    println("Now logged in")
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
        })
    }
    
    func displayAlert(title:String, message:String, style: UIAlertControllerStyle) {
        // Make an error message alert thingy
        //1. Create the alert controller.
        var alert = UIAlertController(title: title, message: message, preferredStyle: style)
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func createLoginButtonPressed(sender: UIButton) {
        // Segue (modally) to the create login screen
        self.performSegueWithIdentifier("createLoginSegue", sender: self)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
