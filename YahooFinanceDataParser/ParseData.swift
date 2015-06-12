//
//  ParseData.swift
//  YahooFinanceDataParser
//
//  Created by Andrew on 2015-06-11.
//  Copyright (c) 2015 Andrew Cichocki. All rights reserved.
//

import Foundation

func parseIntradayCSV(CSV: NSData) -> [String] {
    var output = [String]()
    let dataString = NSString(data: CSV, encoding: NSUTF8StringEncoding) as! String
    let intradayArray = dataString.componentsSeparatedByString(",") as [String]
    if (intradayArray.count > 0) {
        output = [intradayArray[0],intradayArray[1],intradayArray[2],intradayArray[3],intradayArray[4]]
        // [0] - Symbol, [1] - Recent Price, [2] - Date, [3] - Time, [4] - One Day Price Change
    } else {
        println("Error in parseIntradayCSV()")
    }
    return output
}

func parseHistoricalCSV(CSV: NSData) -> [[String]] {
    var output = [[String]]()
    let dataString = NSString(data: CSV, encoding: NSUTF8StringEncoding) as! String
    let intermediateArray = dataString.componentsSeparatedByString("\n") as [String] // Last index is blank
    if (!intermediateArray[0].hasPrefix("<!doctype")) {
        for var i = 1; i < intermediateArray.count - 1; ++i {
            let intermediateString = intermediateArray[i] as String
            let historicalArray = intermediateString.componentsSeparatedByString(",") as [String]
            let date = historicalArray[0] as String
            let open = historicalArray[1] as String
            let high = historicalArray[2] as String
            let low = historicalArray[3] as String
            let close = historicalArray[4] as String
            let volume = historicalArray[5] as String
            let adjClose = historicalArray[6] as String
            output.append([date,open,high,low,close,volume,adjClose])
            // [i][0] - Date, [i][1] - Open, [i][2] - High, [i][3] - Low, [i][4] - Close, [i][5] - Volume, [i][6] - Adj. Close
        }
    } else {
        println("Error in parseHistoricalCSV()")
    }
    return output
}