//
//  CreateLoginViewController.swift
//  Breakfast Burrito Friday
//
//  Created by Mackenzie Fernandez on 6/3/15.
//  Copyright (c) 2015 Mackenzie Fernandez. All rights reserved.
//

import UIKit

class CreateLoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var createLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createLoginButtonPressed(sender: UIButton) {
        createLoginButton.setTitle("Creating user ...", forState: .Normal)
        
        
        println("Create Login button has been pressed")
        
        let ref = Firebase(url: "https://bbfriday.firebaseio.com")
        
        ref.createUser(emailTextField.text, password: passwordTextField.text,
            withValueCompletionBlock: { error, result in
                
                if error != nil {
                    // There was an error creating the account
                    println("There was an error: \(error)")
                    
                    var errorMessage = "There was an error creating your account"
                    
                    if error.code == -9 {
                        errorMessage = "That email already exists!"
                    }
                    if error.code == -5 {
                        errorMessage = "You must enter a valid email"
                    }
                    if error.code == -6 {
                        errorMessage = "You must enter a password"
                    }
                    
                    self.displayAlert("Whoops!", message: errorMessage, style: .Alert)
                    self.createLoginButton.setTitle("Let's Try Again!", forState: .Normal)
                    
                } else {
                    let uid = result["uid"]! as? String
                    println("Successfully created user account with uid: \(uid!)")
                    self.createLoginButton.setTitle("Logging in ...", forState: .Normal)
                    
                    // Log the user in after creating the account and add the name
                    ref.authUser(self.emailTextField.text, password: self.passwordTextField.text,
                        withCompletionBlock: { error, authData in
                            if error != nil {
                                // There was an error logging in to this account
                                println("there was an error logging the user in: \(error)")
                                
                                var errorMessage = "There was an error while trying to log you in, so let's try again using the email and password you created."
                                self.displayAlert("Uh-oh!", message: errorMessage, style: .Alert)
                                
                                self.dismissViewControllerAnimated(true, completion: nil)
                                
                            } else {
                                // We are now logged in
                                println("Yay, logged in")
                                // Now add the name to the users section of the database
                                ref.childByAppendingPath("users/\(uid!)").setValue(["name":self.nameTextField.text], withCompletionBlock: { (error2, result) -> Void in
                                    if error2 != nil {
                                        println("there was an error adding the name: \(error2)")
                                    }
                                    else {
                                        println("name successfully added to database")
                                        
                                        self.dismissViewControllerAnimated(true, completion: nil)
                                        
                                    }
                                    
                                })
                                
                            }
                    })
                    
                    
                }
        })
    }

    @IBAction func backButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
