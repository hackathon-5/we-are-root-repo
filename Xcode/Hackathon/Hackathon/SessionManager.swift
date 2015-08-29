//
//  SessionManager.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/28/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit
import OAuthSwift
import KeychainAccess
import ObjectMapper
import SwiftyJSON

let kHackathonSessionManagerOAuthSuccess = "kHackathonSessionManagerOAuthSuccess"
let kHackathonSessionManagerOAuthFailure = "kHackathonSessionManagerOAuthFailure"

class SessionManager: NSObject {
    
    /// The default session for Hackathon
    static let sharedManager : SessionManager = SessionManager()
    
    private let keychain : Keychain = Keychain(service: "Hackathon")
    
    var currentUser: AppUser?
    var accessToken: String?
    
    override init() {
        
        super.init()
        
        self.restoreSession()
    }
    
    private func restoreSession()
    {
        if let token = self.keychain["accessToken"], userJSON = self.keychain["userJSON"]
        {
            //We have credentials, let's restore the session!
            self.accessToken = token
            self.currentUser = Mapper<AppUser>().map(userJSON)
        }
    }
    
    private func saveSession()
    {
        if self.currentUser != nil && self.accessToken != nil{
            
            //Let's save the session
            self.keychain["accessToken"] = self.accessToken
            self.keychain["userJSON"] = Mapper().toJSONString(self.currentUser!, prettyPrint: false)
        }
    }
    
    func isLoggedIn() -> Bool
    {
        if self.currentUser != nil && self.accessToken != nil
        {
            return true
        }
        
        return false
    }
    
    func logout()
    {
        self.keychain.remove("accessToken")
        self.keychain.remove("userJSON")
    }
    
    /**
    Begin an OAuth2 login flow for Github
    */
    func beginOAuthGithubLogin()
    {
        let oauthswift = OAuth2Swift(consumerKey: "b69ceba754b48d07f912", consumerSecret: "e7b783cd48f7d88903776a7f9616260583acbaaa", authorizeUrl: "https://github.com/login/oauth/authorize", accessTokenUrl: "https://github.com/login/oauth/access_token", responseType: "token")
        
        oauthswift.authorizeWithCallbackURL(NSURL(string: "weAreRootApp://oauth-callback/github")!, scope: "user,public_repo,repo,repo:status,notifications,read:repo_hook,write:repo_hook,admin:repo_hook,read:org", state: NSUUID().UUIDString, params: Dictionary<String,String>(), success: { (credential, response, parameters) -> Void in
            
            NSLog("OAuthSwift Success: %@", credential)
            NSLog("OAuthToken: %@", credential.oauth_token)
            
            //Exchange with server for local token
            var requestPOSTParams = ["token" : credential.oauth_token]
            
            var error: NSError?
            
            var requestBody = NSJSONSerialization.dataWithJSONObject(requestPOSTParams, options: .allZeros, error: &error)
            
            if error == nil
            {
                var request = NSMutableURLRequest(URL: APIClient.requestForPath("/account/"))
                request.HTTPMethod = "POST"
                request.HTTPBody = requestBody
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                APIClient.sendRequest(request, authorization: false, completion: { (success, error, response) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if success
                        {
                            if let userJSON = response
                            {
                                self.currentUser = Mapper<AppUser>().map(userJSON.dictionaryObject)
                                self.accessToken = userJSON["access_token"].string
                                
                                self.saveSession()
                                
                                NSNotificationCenter.defaultCenter().postNotificationName(kHackathonSessionManagerOAuthSuccess, object: nil)
                            }
                            else
                            {
                                NSNotificationCenter.defaultCenter().postNotificationName(kHackathonSessionManagerOAuthFailure, object: "The server returned an unexpected response.")
                            }
                        }
                        else
                        {
                            NSNotificationCenter.defaultCenter().postNotificationName(kHackathonSessionManagerOAuthFailure, object: error)
                        }
                    })
                })
            }
            else
            {
                NSNotificationCenter.defaultCenter().postNotificationName(kHackathonSessionManagerOAuthFailure, object: error?.localizedDescription)
            }
            
            }) { (error) -> Void in
                
                NSLog("OAuthSwift Error: %@", error)
                
                NSNotificationCenter.defaultCenter().postNotificationName(kHackathonSessionManagerOAuthFailure, object: nil)
        }
    }
    
    
}
