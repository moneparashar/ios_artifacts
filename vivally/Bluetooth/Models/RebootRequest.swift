/*
 * Copyright 2021, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import UIKit
//sectorSize = 4 * 1024 = 

class RebootRequest: NSObject {
    var bootMode:UInt8
    var sectorIndex:UInt8
    var numberofSectorsToErase:UInt8
    
    override init(){
        bootMode = 0
        sectorIndex = 0
        numberofSectorsToErase = 0
    }
    
    func getOTAReboot(sizeInBytes: Int){
        if sizeInBytes == 0 {
            bootMode = 1    //bootmodeapplication
            sectorIndex = 7
            numberofSectorsToErase = 127
        }
        else{
            bootMode = 1
            sectorIndex = 7 //application_sector_index
            numberofSectorsToErase = UInt8((sizeInBytes / 4096) + 1)
        }
    }
    
    func toDataModel() -> Data {
        var data = Data()
        data.append(Data(from: bootMode))
        data.append(Data(from: sectorIndex))
        data.append(Data(from: numberofSectorsToErase))
        
        return data
    }
    
    
    //things to recall
    //if size in bytes nonexistant
    // do reboot_into_ota
    //1, 7, 127 to byte
    
    
    //else
    //do get ota reboot
    //1, 7, (sizeinbytes / sector_size) + 1 to byte
}
