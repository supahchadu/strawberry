//
//  SignInVC.swift
//  notefy
//
//  This class controls the Email Authentication and Facebook Authentication
//  automated sign-in via Keychain to prevent sign-in always from Facebook and via Email
//
//  Created by Chad on 8/7/16.
//  Copyright © 2016 Richard Dean D. All rights reserved.
//
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController {
    
    @IBOutlet weak var passField: PasswordDesignView!
    @IBOutlet weak var emailField: PasswordDesignView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = KeychainWrapper.stringForKey(KEY_UID) {
            // Send the user to the Note Feed View
            performSegueWithIdentifier("goToNoteFeed", sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func facebookButtonSignInButtonPressed(sender: AnyObject) {
        // Facebook Authentication <3
        // Permit the app to get somethings for functionality
        // just a go signal
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (result, error) in
            if error != nil { // If there are errors then you have to authenticate
                print("AUTHENTICATE WITH FACEBOOK - \(error)")
            } else if result?.isCancelled == true { // when they cancel the authentication
                print("User cancelled the authentication")
                
            } else {
                print("Authenticated with Facebook!")
                // Create an access token and once we get it! We got the email and account
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                self.firebaseAuthentication(credential) // Send the credentials to Firebase for database record
            }
            
        }
        // Firebase Authentication protocol <3
    }
    
    // Firebase authentication after the facebook gives credentials :)
    func firebaseAuthentication(credential: FIRAuthCredential){
        // We need error handling if everything goes wrong in the Firebase side and/or wrong credentials.
        FIRAuth.auth()?.signInWithCredential(credential, completion: {(result, error) in
            if error != nil {
                print("Unable to authenticate with fire base :(")
            }else {
                print("Successfully Authenticated with Firebase")
                if let user = result { // Encapsulate the Keychain wrapper and save the user login data on Keychain
                    let userData = ["provide": credential.provider]
                    self.completeSignIn(user.uid, userData: userData)// Auto Login
                }
            }
        })
    }
    
    // Register ? Sign In : we need to know if the user account exist <? then create
    // user account with email verification
    @IBAction func signInButtonTapped(sender: AnyObject) {
        if let email = emailField.text, let pwd = passField.text {
            FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: {(user, error) in
                if error == nil {
                    print("User is Authenticated with Firebase")
                    
                    if let user = user {
                        let userData = ["provide": user.providerID]
                        self.completeSignIn(user.uid, userData: userData)
                    }
                    
                    let alert = UIAlertController(title: "Notefy", message: "Your account has been successfully created!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                } else {
                    FIRAuth.auth()?.createUserWithEmail(email, password: pwd, completion: {(user,error) in
                        if error != nil {
                            let alert = UIAlertController(title: "Hold Up!", message: "Your Password or Username might be incorrect.", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                            print("Unable to Authenticate with Firebase using \(email)")
                        }else {
                            print("Successfully authenticate with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(user.uid, userData: userData) // Save login data to keychain
                            }
                        }
                    })
                }
                
            })
        }
    }
    
    // Function that saves the login data after the successfull authentication on both Firebase and 
    // Facebook.
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DatabaseService.databaseService.createFirebaseDBUser(id, userData: userData)
        let keychainResult = KeychainWrapper.setString(id, forKey: KEY_UID)
        print("Login Data saved to keychain \(keychainResult)")
        performSegueWithIdentifier("goToNoteFeed", sender: nil)
    }
}


