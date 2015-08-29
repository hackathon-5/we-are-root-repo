//
//  APIClient.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/28/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias APIClientCompletionBlock = ((success:Bool, error:String?, response:AnyObject?) -> Void)
typealias APIClientJSONCompletionBlock = ((success:Bool, error:String?, response:JSON?) -> Void)

class APIClient: NSObject {
    
    private static let HackathonServerAPIBase = NSURL(string: "http://52.21.30.201:8000/")! //This will be SSL eventually
 
    /**
    Send an API request to the Hackathon server.
    
    :param: request       The request to send
    :param: authorization Whether or not we should add an authorization header
    :param: completion    The completion block to call when done
    */
    static func sendRequest(request: NSURLRequest, authorization: Bool, completion: APIClientJSONCompletionBlock?)
    {
        let mutableRequest: NSMutableURLRequest = request.mutableCopy() as! NSMutableURLRequest
    
        if authorization
        {
            if SessionManager.sharedManager.isLoggedIn()
            {
                mutableRequest.addValue(SessionManager.sharedManager.accessToken, forHTTPHeaderField: "Authorization")
            }
            else
            {
                completion?(success: false, error: "Unable to complete request: You're not currently logged in.", response: nil)
                return;
            }
        }
        
        NSURLSession.sharedSession().dataTaskWithRequest(mutableRequest, completionHandler: { (data, response, error) -> Void in
            
            if error == nil
            {
                let parsedJSON = JSON(data: data)
                
                if let errorMessage = parsedJSON["error"].string
                {
                    //Oh, no! An error occurred. Report it to the caller
                    completion?(success: false, error: errorMessage, response: nil)
                }
                else
                {
                    //No error 4 us! Woo!
                    completion?(success: true, error: nil, response: parsedJSON)
                }
            }
            else
            {
                completion?(success: false, error: error.localizedDescription, response: nil)
            }
        }).resume()
    }
    
    /**
    Convenience method for generating a URL to the Hackathon API service
    
    :param: path The relative path
    
    :returns: An NSURL representing the full URL of the API.
    */
    static func requestForPath(path: String) -> NSURL
    {
        return NSURL(string: path, relativeToURL: self.HackathonServerAPIBase)!
    }
}
