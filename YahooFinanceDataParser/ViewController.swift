//
//  ViewController.swift
//  YahooFinanceDataParser
//
//  Created by Andrew on 2015-06-11.
//  Copyright (c) 2015 Andrew Cichocki. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var stockSymbolTextField: UITextField!
    @IBOutlet weak var recentPriceValueLabel: UILabel!
    @IBOutlet weak var startingDatePicker: UIDatePicker!
    @IBOutlet weak var startingDateClosingPriceLabel: UILabel!
    @IBOutlet weak var historicalPriceValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func getRecentDataButtonTouched(sender: AnyObject) {
        if (stockSymbolTextField.text != ""){
            self.recentPriceValueLabel.text = "Updating..."
            downloadIntradayData(stockSymbolTextField.text.uppercaseString)
        } else {
            println("Please enter a stock symbol")
        }
    }
    
    @IBAction func getHistoricalDataButtonTouched(sender: AnyObject) {
        if (stockSymbolTextField.text != ""){
            self.startingDateClosingPriceLabel.text = "Closing Price on..."
            self.historicalPriceValueLabel.text = "Updating..."
            var startingDate = startingDatePicker.date
            let lastWeek = NSDate(timeIntervalSinceNow: -604800)
            // Make sure starting date is at least a week ago because of trading holidays and rounding errors in the Date Picker
            if (startingDate.laterDate(lastWeek) == startingDate){
                startingDate = lastWeek
            }
            downloadHistoricalData(stockSymbolTextField.text.uppercaseString, date: startingDate)
        } else {
            println("Please enter a stock symbol")
        }
    }
    
    func downloadIntradayData(symbol: String) -> Void {
        let intradayURL = NSURL(string: "http://download.finance.yahoo.com/d/quotes.csv?s=\(symbol)&f=sl1d1t1c1ohgv&e=.csv")
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(intradayURL!, completionHandler: { (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                let dataObject = NSData(contentsOfURL: location)
                let output = parseIntradayCSV(dataObject!) as [String]
                // [0] - Symbol, [1] - Recent Price, [2] - Date, [3] - Time, [4] - One Day Price Change
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if (output[1] != "N/A"){
                        self.recentPriceValueLabel.text = "$" + output[1]
                    } else {
                        self.recentPriceValueLabel.text = "Invalid symbol"
                    }
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    println("Connectivity error in downloadIntradayData()")
                    self.recentPriceValueLabel.text = "Error"
                })
            }
        })
        downloadTask.resume()
    }
    
    func downloadHistoricalData(symbol: String, date: NSDate) -> Void {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let startDateString = dateFormatter.stringFromDate(date)
        let startDateArray = startDateString.componentsSeparatedByString("-")
        let todayString = dateFormatter.stringFromDate(NSDate())
        let todayArray = todayString.componentsSeparatedByString("-")
        
        //convert to Yahoo Finance style date (months = 0 to 11)
        let startMonth = (startDateArray[0].toInt()! - 1) as Int
        let startDay = startDateArray[1].toInt()! as Int
        let startYear = startDateArray[2].toInt()! as Int
        let endMonth = (todayArray[0].toInt()! - 1) as Int
        let endDay = todayArray[1].toInt()! as Int
        let endYear = todayArray[2].toInt()! as Int
        
        let historicalURL = NSURL(string: "http://real-chart.finance.yahoo.com/table.csv?s=\(symbol)&a=\(startMonth)&b=\(startDay)&c=\(startYear)&d=\(endMonth)&e=\(endDay)&f=\(endYear)&g=d&ignore=.csv")
        
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(historicalURL!, completionHandler: { (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                let dataObject = NSData(contentsOfURL: location)
                let output = parseHistoricalCSV(dataObject!)
                // [i][0] - Date, [i][1] - Open, [i][2] - High, [i][3] - Low, [i][4] - Close, [i][5] - Volume, [i][6] - Adj. Close
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if (output.count > 0){
                        let earliestDate = output[output.count - 1][0]
                        let earliestPriceString = output[output.count - 1][6] // Use Adjusted Close in case of stock splits
                        let earliestPriceDouble = (earliestPriceString as NSString).doubleValue
                        let earliestPriceRounded = Double(round(100*earliestPriceDouble)/100) // Round to 2 decimal places
                        self.startingDateClosingPriceLabel.text = "Closing Price on " + earliestDate
                        self.historicalPriceValueLabel.text = "$" + earliestPriceRounded.description
                    } else {
                        self.startingDateClosingPriceLabel.text = "Invalid Symbol"
                        self.historicalPriceValueLabel.text = ""
                    }
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    println("Connectivity error in downloadHistoricalData()")
                    self.startingDateClosingPriceLabel.text = "Invalid Symbol"
                    self.historicalPriceValueLabel.text = ""
                    })
            }
        })
        downloadTask.resume()
    }
}
