/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
import Foundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let date = Date()
        let dateFormatter = ISO8601DateFormatter()
        
        let baseClass = AppDevice()
        baseClass.timestamp = Date()
        baseClass.id = 938
        baseClass.appIdentifier = "AppIdentifier"
        baseClass.awsSubscriptionArnList = "Test"
        
        let jsonEncoder = JSONEncoder()
        var jsonData = Data()
        do {
            jsonData = try jsonEncoder.encode(baseClass)
            let jsonString = String(data: jsonData, encoding: .utf8)
            print("JSON String : " + jsonString!)
        }
        catch {
        }
        
        do {
            // Decode data to object
            
            let jsonDecoder = JSONDecoder()
            let decodeBaseClass = try jsonDecoder.decode(AppDevice.self, from: jsonData)
            print("Guid : \(decodeBaseClass.guid)")
            print("Id : \(decodeBaseClass.id )")
            print("timestamp : \(decodeBaseClass.timestamp)")
            print("modified : \(decodeBaseClass.modified ?? Date())")
            print("appIdentifier : \(decodeBaseClass.appIdentifier)")
            print("awsSubscriptionArnList : \(decodeBaseClass.awsSubscriptionArnList ?? "")")
            
        }
        catch {
        }
    }


}

