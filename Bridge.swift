//
//  Bridge.swift
//  LABridgeDataImporter
//
//  Created by James on 10/10/15.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

public class Bridge
{

var bin: String?
var weightStraight: Double?
var weightCombo: Double?
var weightDouble: Double?
var height: Double?
var locationDescription: String?
var city: String?
var state: String?
var zip: String?
var country: String?
var isRPosted: Bool?

var latitude: Double?
var longitude: Double?

var featureCarried: String?
var featureCrossed: String?
var county: String?
var otherPosting: String?
var numVotes: Int = 0
var isLocked: Bool = false

init()
{
    bin = ""
    weightStraight = 0
    weightCombo = 0
    weightDouble = 0
    height = 99
    isRPosted = false
    latitude = nil
    longitude = nil
    numVotes = 0
    isLocked = false
    
}


}
    