/*
 * Copyright 2023, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import Foundation

class AnimationManager{
    static let sharedInstance = AnimationManager()
    func lerp(startValue: Float, endValue: Float, progress: Float) -> Float{
        return startValue + (endValue - startValue) * progress
    }
    
    //for values where x increases
    func easeInOut(val: Float) -> Float{
        return lerp(startValue: easeIn(val: val), endValue: easeOut(outVal: val), progress: val)
    }
    
    func easeOut(outVal: Float) -> Float{
        return flip(f: powf(flip(f: outVal), 2))
    }
    
    func easeIn(val: Float) -> Float{
        return val * val
    }
    
    func flip(f: Float) -> Float{
        return 1 - f
    }
    
    //new attempt to fix anmations where x decreases
    func easeInNeg(val: Float) -> Float{
        return flip(f: powf(val, 2))
    }
    
    func easeOutNeg(val: Float) -> Float{
        return powf(flip(f: val), 2)
    }
    
    func easeInOutNeg(val: Float) -> Float{
        return lerp(startValue: easeInNeg(val: val), endValue: easeOutNeg(val: val), progress: val)
    }
}
