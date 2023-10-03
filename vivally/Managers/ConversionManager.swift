/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

class ConversionManager{
    static let sharedInstance = ConversionManager()
    var fluidUnit:FluidUnits = .ounces
    let fluidDefaultUnit: FluidUnits = .ounces
    
    func loadFluidUnit(){
        let unitNum = UserDefaults.standard.integer(forKey: "JournalUnit")
        fluidUnit = FluidUnits(rawValue: unitNum) ?? fluidDefaultUnit
    }
    
    func saveFluidUnit(){
        UserDefaults.standard.set(fluidUnit.rawValue, forKey: "JournalUnit")
    }
    
    func clearFluidUnit(){
        UserDefaults.standard.removeObject(forKey: "JournalUnit")
        fluidUnit = fluidDefaultUnit
    }
    
    
    //pass milli to cloud
    //change the value as mentioned at ticket
    let millisInCup = 240
    let millisInOunce = 30
    //Change value to double for decimal value
    func getCups(milli: Double) -> Double{
        
        return Double(milli) / Double(millisInCup)
    }
    //Change value to double for decimal value
    func getOunces(milli: Double) -> Double{
        return Double(milli) / Double(millisInOunce)
    }
    //Change value to double for decimal value
    func getMilli(amt: Double, ounces: Bool = true) -> Double{
        return ounces ? amt * Double(millisInOunce): amt * Double(millisInCup)
    }
}
