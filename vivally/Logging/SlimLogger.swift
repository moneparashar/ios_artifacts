//
//  SlimLogger.swift
//  ilink
//
//  Created by sancsoft on 10/1/18.
//  Copyright © 2018 sancsoft. All rights reserved.
//

import Foundation

import Alamofire

enum SourceFilesThatShouldLog {
    case all
    case none
    case enabledSourceFiles([String])
}

public enum LogLevel: Int {
    
    case trace  = 100
    /*
    case debug  = 200
    case info   = 300
    case warn   = 400
    case error  = 500
    case fatal  = 600
    */
    
    case error = 0
    case warning = 1
    case info = 2
    case debug = 3
    case verbose = 4
    
    var numString:String{
        return String(self.rawValue)
    }
    
    var string:String {
        switch self {
        case .error: return "ERROR"
        case .warning: return "WARNING"
        case .info: return "INFO"
        case .debug: return "DEBUG"
        case .verbose: return "VERBOSE"
            
        case .trace:
            return "TRACE"
             /*
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO "
        case .warn:
            return "WARN "
        case .error:
            return "ERROR"
        case .fatal:
            return "FATAL"
            */
        }
    }
}

public protocol LogDestination {
    func log<T>( _ message: @autoclosure () -> T, level: LogLevel, category: [LogCategories], filename: String, line: Int)
}

private let slim = Slim()

open class Slim {
    
    var logDestinations: [LogDestination] = []
    var cleanedFilenamesCache: NSCache<AnyObject, AnyObject> = NSCache()
    
    init() {
        if SlimConfig.enableConsoleLogging {
            logDestinations.append(ConsoleDestination())
        }
    }
    
    open class func addLogDestination(_ destination: LogDestination) {
        slim.logDestinations.append(destination)
    }
    
    //overall log new
    open class func log<T>( level: LogLevel, category: [LogCategories], _ message: @autoclosure () -> T, filename: String = #file, line: Int = #line) {
        slim.logInternal(message(), level: level, cat: category, filename: filename, line: line)
    }
    
    open class func trace<T>( _ message: @autoclosure () -> T, filename: String = #file, line: Int = #line) {
        slim.logInternal(message(), level: LogLevel.trace, filename: filename, line: line)
    }
    
    open class func debug<T>( _ message: @autoclosure () -> T, filename: String = #file, line: Int = #line) {
        slim.logInternal(message(), level: LogLevel.debug, filename: filename, line: line)
    }
    
    open class func info<T>( _ message: @autoclosure () -> T, filename: String = #file, line: Int = #line) {
        slim.logInternal(message(), level: LogLevel.info, filename: filename, line: line)
    }
    /*
    open class func warn<T>( _ message: @autoclosure () -> T, filename: String = #file, line: Int = #line) {
        slim.logInternal(message(), level: LogLevel.warn, filename: filename, line: line)
    }
    */
    
    open class func error<T>( _ message: @autoclosure () -> T, filename: String = #file, line: Int = #line) {
        slim.logInternal(message(), level: LogLevel.error, filename: filename, line: line)
    }
    /*
    open class func fatal<T>( _ message: @autoclosure () -> T, filename: String = #file, line: Int = #line) {
        slim.logInternal(message(), level: LogLevel.fatal, filename: filename, line: line)
    }
    */
    
    open class func warning<T>( _ message: @autoclosure () -> T, filename: String = #file, line: Int = #line) {
        slim.logInternal(message(), level: LogLevel.warning, filename: filename, line: line)
    }
    
    open class func verbose<T>( _ message: @autoclosure () -> T, filename: String = #file, line: Int = #line) {
        slim.logInternal(message(), level: LogLevel.verbose, filename: filename, line: line)
    }
    
    
    fileprivate func logInternal<T>( _ message: @autoclosure () -> T, level: LogLevel, cat: [LogCategories] = [], filename: String, line: Int) {
        let cleanedfile = cleanedFilename(filename)
        if isSourceFileEnabled(cleanedfile) {
            for dest in logDestinations {
                dest.log(message(), level: level, category: cat, filename: cleanedfile, line: line)
            }
        }
    }
    
    /*
    fileprivate func logInternal<T>( _ message: @autoclosure () -> T, levels: [LogLevel], filename: String, line: Int) {
        //check if log level is allowed before adding log
        //if let currentLogConfig = LogManager.sharedInstance.userLogConfig{
            
            
            let cleanedfile = cleanedFilename(filename)
            if isSourceFileEnabled(cleanedfile) {
                for dest in logDestinations {
                    dest.log(message(), level: level, filename: cleanedfile, line: line)
                }
            }
        //}
    }
    */
    
    fileprivate func cleanedFilename(_ filename: String) -> String {
        if let cleanedfile:String = cleanedFilenamesCache.object(forKey: filename as AnyObject) as? String {
            return cleanedfile
        } else {
            var retval = ""
            let items = filename.split{$0 == "/"}.map(String.init)
            
            if items.count > 0 {
                retval = items.last!
            }
            cleanedFilenamesCache.setObject(retval as AnyObject, forKey: filename as AnyObject)
            return retval
        }
    }
    
    fileprivate func isSourceFileEnabled(_ cleanedFile: String) -> Bool {
        switch SlimConfig.sourceFilesThatShouldLog {
        case .all:
            return true
        case .none:
            return false
        case .enabledSourceFiles(let enabledFiles):
            if enabledFiles.contains(cleanedFile) {
                return true
            } else {
                return false
            }
        }
    }
}

class ConsoleDestination: LogDestination {
    
    let dateFormatter = DateFormatter()
    let serialLogQueue: DispatchQueue = DispatchQueue(label: "ConsoleDestinationQueue")
    
    init() {
        dateFormatter.dateFormat = "HH:mm:ss:SSS"
    }
    
    func log<T>( _ message: @autoclosure () -> T, level: LogLevel, category: [LogCategories], filename: String, line: Int) {
        if level.rawValue <= SlimConfig.consoleLogLevel.rawValue {
            let msg = message()
            self.serialLogQueue.async {
                print("\(self.dateFormatter.string(from: Date())):\(level.string):\(filename):\(line) - \(msg)")
            }
        }
    }
}

//should probably make this separate file
private let awsQueue:DispatchQueue = DispatchQueue(label: "awslog")
class AWSDestination: LogDestination{
    
    var maxSizeInBuffer = 50 //was it 10 MB?
    
#if STAGING
    //let awsURLString = "https://elk.preprod.avation.com"
    let awsURLString = "https://elk.preprod.avation.com/v1/elk/bulk"
#elseif PRODUCTION
    let awsURLString = "https://elk.vivally.com"
    #endif
    
    fileprivate var buffer: [String] = []
    fileprivate var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    
    /*
    func log<T>(_ message: @autoclosure () -> T, level: LogLevel, category: [LogCategories], filename: String, line: Int) {
        if let ms = message() as? String{
            let df = DateFormatter.iso8601Full
            let dateStr = df.string(from: Date())
            var cateStr = ""
            var ind = 0
            for cat in category{
                ind == category.count - 1 ? cateStr.append(cat.rawValue) : cateStr.append("\(cat.rawValue), ")
                ind += 1
            }
            
            var fullMessage = "\"level\":\"\(level.numString)\", \"category\":\"\(cateStr)\", \"message\":\"\(ms)\", \"source\":\"\(filename)\", \"timestamp\":\"\(dateStr)\" "
            //var fullMessage = "\"level\":\"\(level.numString)\", \"message\":\"\(ms)\", \"source\":\"\(filename)\", \"timestamp\":\"\(dateStr)\" "
            fullMessage.insert("{", at: fullMessage.startIndex)
            fullMessage.append("}")
            addLogMsgToBuffer(msg: fullMessage)
        }
    }
    */
    
    private func addLogMsgToBuffer(msg: String){
        awsQueue.async {
            self.buffer.append(msg)
            if self.buffer.count > 0{   //for testing if individual log works
            //if self.buffer.count > SlimLogglyConfig.maxEntriesInBuffer{
                let tmpbuffer = self.buffer
                self.buffer = [String]()
                self.sendLogsInBuffer(stringbuffer: tmpbuffer)
            }
        }
    }
    
    //new imp
    func log<T>(_ message: @autoclosure () -> T, level: LogLevel, category: [LogCategories], filename: String, line: Int) {
        if let ms = message() as? String{
            awsQueue.async {
                let logMess = LogMessage()
                logMess.level = level.rawValue
                logMess.message = ms
                logMess.source = filename
                logMess.json = self.genJson(filename: filename, line: String(line))
                
                self.createLogRequest(logMessage: logMess)
            }
        }
    }
    
    func genJson(filename: String, line:
    String) -> String{
        var jsonStr = ""
        
        jsonStr = "{"
        var jsonFields:[String:String] = [:]
        jsonFields["ApplicationName"] = "Vivally.iOS"
        
        #if STAGING
        jsonFields["EnvironmentName"] = "Pre-Prod"
        #elseif PRODUCTION
        jsonFields["EnvironmentName"] = "production"
        #endif
        
        jsonFields["deviceConfigurationGuid"] = ""
        jsonFields["stackTrace"] = "\(filename) \(line)"
        jsonFields["UserId"] = String(KeychainManager.sharedInstance.accountData?.userModel?.id ?? 0)
                
        var ind = 0
        for jf in jsonFields{
            var lstr = "\"" + jf.key + "\":\"" + jf.value + "\""
            if ind < jsonFields.count - 1{
                lstr.append(",")
            }
            jsonStr.append(lstr)
            ind += 1
        }
        
        jsonStr.append("}")
        return jsonStr
    }
    //end of new
    
    private func addLogMsgToBuffer2(msg: String){
        awsQueue.async {
            self.buffer.append(msg)
            if self.buffer.count > 0{   //for testing if individual log works
            //if self.buffer.count > SlimLogglyConfig.maxEntriesInBuffer{
                let tmpbuffer = self.buffer
                self.buffer = [String]()
                self.sendLogsInBuffer(stringbuffer: tmpbuffer)
            }
        }
    }
    
    
    
    static var customLogHeaders: HTTPHeaders = ["Content-type":"application/json"]
    
    
    private func sendLogsInBuffer(stringbuffer: [String]){
        
        let allMessagesString = stringbuffer.joined(separator: "\n")
        if URL(string: awsURLString) != nil{
            
            let logAWS = LogAWS()
            KeychainManager.sharedInstance.loadAccountData()
            let strId = KeychainManager.sharedInstance.accountData == nil ? "" : String(KeychainManager.sharedInstance.accountData?.userModel?.id ?? 0)
            logAWS.metadata.user_id = strId
            let encodedStr = allMessagesString.data(using: .utf8)?.base64EncodedString()
            logAWS.data = encodedStr
            
            let params = try? logAWS.asDictionary()
            
            AF.request(awsURLString, method: .post, parameters: params, encoding: JSONEncoding.prettyPrinted, headers: AWSDestination.customLogHeaders).responseJSON { (response) in
                debugPrint(response)
            }
        }
        
    }
    
    
    
    
    //new
    func createLogRequest(logMessage: LogMessage){
        let lmr = LogMessageRequest()
        KeychainManager.sharedInstance.loadAccountData()
        lmr.metadata.user_id = String(KeychainManager.sharedInstance.accountData?.userModel?.id ?? 0)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Full)
        
        do{
            let data = try encoder.encode(logMessage)
            let str = String(decoding: data, as: UTF8.self)
            if let data2 = str.data(using: .utf8) {
                lmr.data = data2.base64EncodedString()
                sendLogRequest(logMessageRequest: lmr)
            }
        } catch{
            print("failed to create log Request")
        }
    }
    
    private func sendLogRequest(logMessageRequest: LogMessageRequest){
        if URL(string: awsURLString) != nil{
            let params = try? logMessageRequest.asDictionary()
            AF.request(awsURLString, method: .post, parameters: params, encoding: JSONEncoding.prettyPrinted, headers: AWSDestination.customLogHeaders).responseJSON { (response) in
                debugPrint(response)
            }
        }
    }
    //end of new
    
    private func endBackgroundTask() {
        if self.backgroundTaskIdentifier != UIBackgroundTaskIdentifier.invalid {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier)
            self.backgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
            print("Ending background task")
        }
    }
    
}
