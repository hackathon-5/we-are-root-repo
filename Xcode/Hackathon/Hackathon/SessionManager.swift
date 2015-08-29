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
    
    var selectedReposForStream: Array<String> = Array<String>() {
        didSet {
            self.saveSession()
        }
    }
    
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
            
            if let streamData = self.keychain["selectedReposForStream"], streamRecovery = NSJSONSerialization.JSONObjectWithData(streamData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, options: .allZeros, error: nil) as? Array<String>
            {
                self.selectedReposForStream = streamRecovery
            }
            else
            {
                self.selectedReposForStream = Array<String>()
            }
        }
    }
    
    private func saveSession()
    {
        if self.currentUser != nil && self.accessToken != nil{
            
            //Let's save the session
            self.keychain["accessToken"] = self.accessToken
            self.keychain["userJSON"] = Mapper().toJSONString(self.currentUser!, prettyPrint: false)
            self.keychain["selectedReposForStream"] = NSString(data: NSJSONSerialization.dataWithJSONObject(self.selectedReposForStream, options: .allZeros, error: nil)!, encoding: NSUTF8StringEncoding) as? String
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
        self.keychain.remove("selectedReposForStream")
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
    
    /**
    Retrieve a list of repositories and organizations for the current user
    
    :param: completion The completion block to call when done.
    */
    func loadListOfRepositories(completion: APIClientCompletionBlock?)
    {
        var request = NSMutableURLRequest(URL: APIClient.requestForPath("/repo/list_all"))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        APIClient.sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if success
                {
                    if let userJSON = response
                    {
                        var repoList = Mapper<RepositoryListResponse>().map(userJSON.dictionaryObject)
                        
                        completion?(success: true, error: nil, response: repoList)
                    }
                    else
                    {
                        completion?(success: false, error: "The server returned an unknown response.", response: nil)
                    }
                }
                else
                {
                    completion?(success: false, error: error, response: nil)
                }
            })
        })

    }
    
    func loadStreamForCurrentPreferences(completion: APIClientCompletionBlock?)
    {
        var requestPOSTParams = ["repos" : self.selectedReposForStream]
        
        var error: NSError?
        
        var requestBody = NSJSONSerialization.dataWithJSONObject(requestPOSTParams, options: .allZeros, error: &error)
        
        if error == nil
        {
            var request = NSMutableURLRequest(URL: APIClient.requestForPath("/stream/"))
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPMethod = "POST"
            request.HTTPBody = requestBody
            
            APIClient.sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if success
                    {
                        if let userJSON = response
                        {
                            var repoList = Mapper<StreamResponse>().map(userJSON.dictionaryObject)
                            
                            completion?(success: true, error: nil, response: repoList)
                        }
                        else
                        {
                            completion?(success: false, error: "The server returned an unknown response.", response: nil)
                        }
                    }
                    else
                    {
                        completion?(success: false, error: error, response: nil)
                    }
                })
            })
        }
        else
        {
            completion?(success: false, error: error?.localizedDescription, response: nil)
        }
    }
    
    func loadLabelsForRepo(repository:String, completion: APIClientCompletionBlock?)
    {
        var requestPOSTParams = ["repo" : repository]
        
        var error: NSError?
        
        var requestBody = NSJSONSerialization.dataWithJSONObject(requestPOSTParams, options: .allZeros, error: &error)
        
        if error == nil
        {
            var request = NSMutableURLRequest(URL: APIClient.requestForPath("/repo/labels"))
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPMethod = "POST"
            request.HTTPBody = requestBody
            
            APIClient.sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if success
                    {
                        if let userJSON = response
                        {
                            completion?(success: true, error: nil, response: userJSON["labels"].arrayObject)
                        }
                        else
                        {
                            completion?(success: false, error: "The server returned an unknown response.", response: nil)
                        }
                    }
                    else
                    {
                        completion?(success: false, error: error, response: nil)
                    }
                })
            })
        }
        else
        {
            completion?(success: false, error: error?.localizedDescription, response: nil)
        }
    }
    
    func loadCollaboratorsForRepo(repository:String, completion: APIClientCompletionBlock?)
    {
        var requestPOSTParams = ["repo" : repository]
        
        var error: NSError?
        
        var requestBody = NSJSONSerialization.dataWithJSONObject(requestPOSTParams, options: .allZeros, error: &error)
        
        if error == nil
        {
            var request = NSMutableURLRequest(URL: APIClient.requestForPath("/repo/collaborators"))
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPMethod = "POST"
            request.HTTPBody = requestBody
            
            APIClient.sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if success
                    {
                        if let userJSON = response
                        {
                            var collaborators = Mapper<CollaboratorsResponse>().map(userJSON.dictionaryObject)
                            
                            completion?(success: true, error: nil, response: collaborators)
                        }
                        else
                        {
                            completion?(success: false, error: "The server returned an unknown response.", response: nil)
                        }
                    }
                    else
                    {
                        completion?(success: false, error: error, response: nil)
                    }
                })
            })
        }
        else
        {
            completion?(success: false, error: error?.localizedDescription, response: nil)
        }
    }
    
    func loadMilestonesForRepo(repository:String, completion: APIClientCompletionBlock?)
    {
        var requestPOSTParams = ["repo" : repository]
        
        var error: NSError?
        
        var requestBody = NSJSONSerialization.dataWithJSONObject(requestPOSTParams, options: .allZeros, error: &error)
        
        if error == nil
        {
            var request = NSMutableURLRequest(URL: APIClient.requestForPath("/repo/milestones"))
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPMethod = "POST"
            request.HTTPBody = requestBody
            
            APIClient.sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if success
                    {
                        if let userJSON = response
                        {
                            var collaborators = Mapper<MilestoneResponse>().map(userJSON.dictionaryObject)
                            
                            completion?(success: true, error: nil, response: collaborators)
                        }
                        else
                        {
                            completion?(success: false, error: "The server returned an unknown response.", response: nil)
                        }
                    }
                    else
                    {
                        completion?(success: false, error: error, response: nil)
                    }
                })
            })
        }
        else
        {
            completion?(success: false, error: error?.localizedDescription, response: nil)
        }
    }
    
    func submitNewGithubIssue(title:String, body: String?, images: Array<UIImage>?, labels: Array<String>?, milestone:Int?, assignedTo:String?, repo: String, completion: APIClientCompletionBlock?)
    {
        var requestPOSTParams: Dictionary<String, AnyObject> = ["repo" : repo, "title" : title]
        
        if body != nil
        {
            requestPOSTParams["body"] = body
        }
        
        if images != nil{
            
            if count(images!) > 0
            {
                var base64Images = Array<String>()
                
                for image in images!
                {
                    var encoded = UIImageJPEGRepresentation(image, 0.5).base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
                    
                    base64Images.append(encoded)
                }
                
                requestPOSTParams["images"] = base64Images
            }
        }
        
        if labels != nil
        {
            if count(labels!) > 0
            {
                requestPOSTParams["label_names"] = labels!
            }
        }
        
        if milestone != nil
        {
            requestPOSTParams["milestone_number"] = milestone
        }
        
        if assignedTo != nil
        {
            requestPOSTParams["assigned_to"] = ["login" : assignedTo!]
        }
        
        var error: NSError?
        
        var requestBody = NSJSONSerialization.dataWithJSONObject(requestPOSTParams, options: .allZeros, error: &error)
        
        if error == nil
        {
            var request = NSMutableURLRequest(URL: APIClient.requestForPath("/issue/"))
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPMethod = "POST"
            request.HTTPBody = requestBody
            
            APIClient.sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if success
                    {
                        if let userJSON = response
                        {
                            var collaborators = Mapper<MilestoneResponse>().map(userJSON.dictionaryObject)
                            
                            completion?(success: true, error: nil, response: collaborators)
                        }
                        else
                        {
                            completion?(success: false, error: "The server returned an unknown response.", response: nil)
                        }
                    }
                    else
                    {
                        completion?(success: false, error: error, response: nil)
                    }
                })
            })
        }
        else
        {
            completion?(success: false, error: error?.localizedDescription, response: nil)
        }
    }
}
