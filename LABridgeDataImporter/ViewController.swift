//
//  ViewController.swift
//  LABridgeDataImporter
//
//  Created by James on 10/10/15.
//  Copyright © 2015 James. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController
{
    
    var bridges: [Bridge] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()

        getLaAll()
        
    }
    
    /* http://api.geonames.org for reverse geocode with county */
    
    
    func addBridge(bridge: Bridge)
    {
        let baseUrlAsString = "http://192.168.1.9/Bware"
   
        let urlAsString = "\(baseUrlAsString)/Api/Bridge/Create"
        
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        formatter.timeZone = NSTimeZone(abbreviation: "UTC")
        let utcTimeZoneStr = formatter.stringFromDate(date)
        // "2014-07-23 18:01:41 +0000" in UTC
        
        let lat = bridge.latitude
        let lon = bridge.longitude
        
        if bridge.height == 99 { bridge.height = 0 }
        if bridge.otherPosting == nil { bridge.otherPosting = "" }
        
        var params = ["BridgeId" : 100, "Latitude": lat!, "Longitude": lon!,
            "DateCreated": utcTimeZoneStr,
            "DateModified": utcTimeZoneStr,
            "UserCreated" : "jdsv650@yahoo.com",
            "UserModified" : "jdsv650@yahoo.com",
            "NumberOfVotes" : 0,
            "isLocked" : true] as [String: AnyObject]
        
        if let carried = bridge.featureCarried
        {
            params["FeatureCarried"] = "\(carried)"
        }
        if let crossed = bridge.featureCrossed
        {
            params["FeatureCrossed"] = "\(crossed)"
        }
        if let description = bridge.locationDescription
        {
            params["LocationDescription"] = "\(description)"
        }
        if let state = bridge.state
        {
            params["State"] = "\(state)"
        }
        if let county = bridge.county
        {
            params["County"] = "\(county)"
        }
        if let town = bridge.city
        {
            params["Township"] = "\(town)"
        }
        if let zip = bridge.zip
        {
            params["Zip"] = "\(zip)"
        }
        if let country = bridge.country
        {
            params["Country"] = "\(country)"
        }
        if let straight = bridge.weightStraight
        {
            params["WeightStraight"] = "\(straight)"
        }
        if let double = bridge.weightDouble
        {
            params["WeightDouble"] = "\(double)"
        }
        if let combination = bridge.weightCombo
        {
            params["WeightCombination"] = "\(combination)"
        }
        if let height = bridge.height
        {
            params["Height"] = "\(height)"
        }
        if let other = bridge.otherPosting
        {
            params["OtherPosting"] = "\(other)"
        }
        if let rPosted = bridge.isRPosted
        {
            params["isRposted"] = "\(rPosted)"
        }
        
        let URL = NSURL(string: urlAsString)
        var mutableURLRequest = NSMutableURLRequest(URL: URL!)
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        mutableURLRequest.HTTPMethod =  Method.POST.rawValue
        
        let encoding = ParameterEncoding.JSON
        (mutableURLRequest, _) = encoding.encode(mutableURLRequest, parameters: params)
        
        let manager = Manager.sharedInstance
        let myRequest = manager.request(mutableURLRequest)
        
        myRequest.responseJSON()
            { Response in
                print(Response.request)
                print("")
                print(Response.response)
                print("")
                print(Response.data)
                
                var resultAsJSON: NSDictionary
                
                switch Response.result {
                case .Success(let JSON):
                    print("Success with JSON: \(JSON)")
                    resultAsJSON = JSON as! NSDictionary
                    
                    if Response.response?.statusCode == 200 || Response.response?.statusCode == 204
                    {
                        print("Create returned OK examine results for isSuccess and/or error message")
                        if let success = resultAsJSON["isSuccess"] as? Bool
                        {
                            if success != true
                            {
                                if let message = resultAsJSON["message"] as? String
                                {
                                    print("Create FAILED with message = \(message)")
                                }
                                else
                                {
                                    print("Create FAILED")
                                }
                                return
                            }
                            else // success
                            {    // ok display message
                                print("BRIDGE ADDED")
                            }
                        }
                        
                    }
                    else
                    {
                        print("Error creating bridge")
                    }
                    
                    
                    //self.parseData(JSON as! NSDictionary)
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
                
                
        }
    }
    

    func parseDataReverseGeo(data: NSDictionary, bridge: Bridge)
    {
        
        let bridgeResult = data["address"] as! NSDictionary
        
        
        if let zip = bridgeResult["postalcode"] as? NSString
        {
            bridge.zip = zip as String
            print(zip)
        }
        
        if let county = bridgeResult["adminName2"] as? NSString
        {
            bridge.county = (county as String).uppercaseString
            print(county)
        }
        
        //Add to database now - check for county == nil?
    
        addBridge(bridge)
        
    }
    
    
    func reverseLookupGeoNames()
    {
      for (var i=0; i<bridges.count-1; i++)
      {
        if  bridges[i].latitude != nil && bridges[i].longitude != nil
        {
            bridges[i].otherPosting = ""
            
            var theBridge = bridges[i]
            
            let urlAsString = "http://api.geonames.org/"
            
            let URL = NSURL(string: urlAsString)
            let mutableURLRequest = NSMutableURLRequest(URL: URL!)
            mutableURLRequest.HTTPMethod = Method.GET.rawValue
            
            //  mutableURLRequest.setValue("identity", forHTTPHeaderField: "accept-encoding")
            
            let manager = Manager.sharedInstance
            let myRequest = manager.request(mutableURLRequest)
            
            myRequest.responseJSON()
            { Response in
                print(Response.request)
                print("")
                print(Response.response)
                print("")
                // print(Response.data)
                
                switch Response.result {
                case .Success(let JSON):
                    print("Success with JSON: \(JSON)")
                    self.parseDataReverseGeo(JSON as! NSDictionary, bridge: theBridge)
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
            }
            
        } // end if
      } // end for
    }  // end func
    
    func parseData(data: NSDictionary)
    {
        let results = data["results"] as! NSArray
        
        for bridge in results
        {
            let b = Bridge()
            b.country = "US"
            b.state = "LA"
            b.zip = ""
            
            if b.weightStraight == nil
            {
                b.weightStraight = 0
            }
            if b.weightDouble == nil
            {
                b.weightDouble = 0
            }
            if b.weightCombo == nil
            {
                b.weightCombo = 0
            }
            if b.height == nil
            {
                b.height = 0
            }
            
            b.isLocked = false
            b.numVotes = 0

            print(b)
            
            if let attributes = bridge["attributes"] as? NSDictionary
            {
                if let bin = attributes["STRUCTURE_NUMBER"] as? NSString
                {
                   // print("BIN = \(bin)")
                    b.bin = bin as String
                }
                
                if let carried = attributes["CARRIED"] as? NSString
                {
                  //  print("Feature Carried = \(carried)")
                    b.featureCarried = carried as? String
                }
                
                if let crossed = attributes["I06A_CROSSING_DESC"] as? NSString
                {
                  //  print("Feature Crossed = \(crossed)")
                    b.featureCrossed = crossed as? String
                }
                
                if let location = attributes["LOCATION"] as? NSString
                {
                   // print("Location = \(location)")
                    b.locationDescription = location as? String
                }
                
                if let posted = attributes["POST_LOAD_LIMIT"] as? NSString
                {
                    print("Posted Load Tons = \(posted)")
                    
                    
                    if posted.containsString("CL") { b.otherPosting = "CLOSED" }
                    
                    // check 3 first
                    else if posted.containsString("---")
                    {
                        let p = posted.componentsSeparatedByString("---")
                        if p.count > 0
                        {
                            b.weightStraight = (p[0] as NSString).doubleValue
                            b.weightCombo   = (p[0] as NSString).doubleValue
                            b.weightDouble = (p[0] as NSString).doubleValue
                        }
                    }
                    
                    else if posted.containsString("-")
                    {
                        var weights = posted.componentsSeparatedByString("-")
                        
                        if weights.count > 0
                        {
                            b.weightStraight = (weights[0] as NSString).doubleValue
                        }
                        if weights.count > 1
                        {
                            b.weightCombo = (weights[1] as NSString).doubleValue
                        }
                    }
                    
                    
                    
                }
                
                if let lat = attributes["CSLM_LATITUDE"] as? NSString
                {
                    print("lat = \(lat)")
                    b.latitude = lat.doubleValue
                    print("b.latitude = \(b.latitude)")
                }
                
                if let lon = attributes["CSLM_LONGITUDE"] as? NSString
                {
                    print("lon = \(lon)")
                    b.longitude = lon.doubleValue
                }
                // some bridges returned with 0  for lat and/or lon so skip them!!!!!
                if b.latitude == nil || b.longitude == nil || b.latitude == 0 || b.longitude == 0
                {
                    
                }
                else
                {
                    bridges.append(b)
                }
            
           }
            
        
        } // end for
        
        for b in bridges
        {
            print("\n")
            print(b.latitude)
            print(b.longitude)
            print(b.locationDescription)
            print(b.featureCrossed)
            print(b.country)
            print(b.county)
            print(b.city)
            print(b.bin)
            print(b.state)
            print(b.weightStraight)
            print(b.weightCombo)
            print(b.weightDouble)
            print("other posting \(b.otherPosting)")
        }
        
        self.reverseLookupGeoNames()

    }  // end function
    
    func getLaAll()
    {
        // can't get all 507 breaks on parse to JSON !!!!!
        // oops -- set geometry = false -- this was breaking the returned data
        
        let urlAsString = "http://"
        
            let URL = NSURL(string: urlAsString)
            let mutableURLRequest = NSMutableURLRequest(URL: URL!)
            mutableURLRequest.HTTPMethod = Method.GET.rawValue
    
            let manager = Manager.sharedInstance
            let myRequest = manager.request(mutableURLRequest)
       
            myRequest.responseJSON()
            { Response in
                print(Response.request)
                print("")
                print(Response.response)
                print("")
               // print(Response.data)
                
                switch Response.result
                {
                    case .Success(let JSON):
                    print("Success with JSON: \(JSON)")
                    self.parseData(JSON as! NSDictionary)
                    case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        
            } // End response() trailing closure
        
    } // end getLaAll()
    
        
    
} // end class

// enable calling toString on a double
extension Double {
    func toString() -> String {
        return String(format: "%.2f",self)
    }
}
