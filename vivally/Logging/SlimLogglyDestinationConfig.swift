//
//  SlimLogglyDestinationConfig.swift
//  ilink
//
//  Created by sancsoft on 10/1/18.
//  Copyright © 2018 sancsoft. All rights reserved.
//

struct SlimLogglyConfig {
    // Replace your-loggly-api-key below with a "Customer Token" (you can create a customer token in the Loggly UI)
    // Replace your-app-name below with a short name for your app (no spaces or crazy characters). You can use this
    // tag in the Loggly UI to create Source Group for each app you have in Loggly.
    static let logglyUrlString = "https://logs-01.loggly.com/bulk/e389d7b0-a4a6-4c9e-92f6-b5d8fadb0215/Avation/"
    
    //if want to just test on our end
    //static let logglyUrlString = "https://logs-01.loggly.com/bulk/ebb77400-40ea-4bd5-b097-98f3161daff6/Avation/"
    
    // Number of log entries in buffer before posting entries to Loggly. Entries will also be posted when the user
    // exits the app.
    static let maxEntriesInBuffer = 50
    
    // Loglevel for the Loggly destination. Can be set to another level during runtime
    static var logglyLogLevel = LogLevel.info
    
}
