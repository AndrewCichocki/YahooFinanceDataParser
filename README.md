# YahooFinanceDataParser

A simple iOS app, written in Swift, for downloading and parsing intraday and historical stock price data from Yahoo Finance.

It can be useful for developers who need:

• recent or historical stock price data for an iOS app

• an example of downloading a remote file with Swift

• an example of parsing comma-seperated (CSV) data with Swift

To use it enter the symbol of a stock which you want to get a recent price for, include a starting date to get a historical price. Stocks traded on non-US exchanges need a suffix after the symbol (TSX = ".TO," TSX Venture = ".V", LSE = ".L"), those traded on US exchanges (NYSE, NASDAQ, AMEX) don't need a suffix. For example: Google is traded on the NASDAQ (US) as "GOOGL" so you only need to enter "GOOGL"; BlackBerry is traded on the TSX (Canada) as "BB" so need to enter "BB.TO".

I built a barebones UI for demonstrating the functions, feel free use a different UI. All the action goes in in ViewController.swift and ParseData.swift.
