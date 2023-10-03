/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */
import UIKit

class Revision: NSObject {
    var major:UInt8
    var minor:UInt8
    var patch:UInt8
    var bootloaderMajor:UInt8
    var bootloaderMinor:UInt8
    var bootloaderPatch:UInt8
    var rev:String
    var bootRev:String
    
    override init(){
        major = 0
        minor = 0
        patch = 0
        bootloaderMajor = 0
        bootloaderMinor = 0
        bootloaderPatch = 0
        rev = ""
        bootRev = ""
    }
    
    func parse(data:Data) -> Bool{
        if data.count != 6{
            return false
        }
        
        major = data[0]
        minor = data[1]
        patch = data[2]
        bootloaderMajor = data[3]
        bootloaderMinor = data[4]
        bootloaderPatch = data[5]
        
        return true
    }
    
    func revisionStr(data: Data){
        rev =  String(Character(UnicodeScalar(major))) + "." +  String(Int(minor) - 0x30) + "." + String(Int(patch) - 0x30)
        bootRev = String(Character(UnicodeScalar(bootloaderMajor))) + "." +  String(Int(bootloaderMinor) - 0x30) + "." + String(Int(bootloaderPatch) - 0x30)
    }
    
    func checkIfNewer(upcomingFirmware:String) -> Bool{
        var newerFirmware = false
        
        if rev != ""{
            let upcomingFirmwareArray = upcomingFirmware.components(separatedBy: ".")
            if upcomingFirmwareArray.count == 3{
                let upcomingMajor = UInt8(upcomingFirmwareArray[0]) ?? 0
                let upcomingMinor = UInt8(upcomingFirmwareArray[1]) ?? 0
                let upcomingPatch = UInt8(upcomingFirmwareArray[2]) ?? 0
                
                let currentFirmwareArray = rev.components(separatedBy: ".")
                if currentFirmwareArray.count == 3{
                    let devMajor = UInt8(currentFirmwareArray[0]) ?? 0
                    let devMinor = UInt8(currentFirmwareArray[1]) ?? 0
                    let devPatch = UInt8(currentFirmwareArray[2]) ?? 0
                    
                    if bootRev.first == "M"{
                        if upcomingMajor >= devMajor{
                            newerFirmware = true
                        }
                        else if upcomingMajor == devMajor{
                            if upcomingMinor >= devMinor{
                                newerFirmware = true
                            }
                            else if upcomingMinor == devMinor{
                                newerFirmware = upcomingPatch >= devPatch
                            }
                        }
                    }
                    else{
                        if upcomingMajor > devMajor{
                            newerFirmware = true
                        }
                        else if upcomingMajor == devMajor{
                            if upcomingMinor > devMinor{
                                newerFirmware = true
                            }
                            else if upcomingMinor == devMinor{
                                newerFirmware = upcomingPatch > devPatch
                            }
                        }
                    }
                }
            }
        }
        
        return newerFirmware
    }
}
