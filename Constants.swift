//
//  Constants.swift
//  Breakfast Burrito Friday
//
//  Created by Mackenzie Fernandez on 3/8/16.
//  Copyright © 2016 Mackenzie Fernandez. All rights reserved.
//

import Foundation
import Firebase
import SwiftDate

struct Constants {
    static let fireRef = Firebase(url:"https://breakfastburritos.firebaseio.com/")
}

func thisFriday(referenceDate:NSDate) -> NSDate {
    if (referenceDate.weekday == 6) {
        return referenceDate
    }
    else {
        return thisFriday(referenceDate + 1.days)
    }
}

func formatDateToString(date:NSDate) -> String {
    return ""
}