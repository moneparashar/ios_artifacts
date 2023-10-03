/*
 * Copyright 2022, Avation Medical. All rights reserved.
 *
 * This code is proprietary and confidential information of Avation Medical. Any use, reproduction, modification
 * or distribution of the code without the express prior written consent of Avation Medical is strictly prohibited.
 */

import MetricKit

class MetricManager: NSObject, MXMetricManagerSubscriber{
    override init() {
        super.init()
        MXMetricManager.shared.add(self)
    }
    
    deinit {
        MXMetricManager.shared.remove(self)
    }
    
    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            if let exitData = payload.applicationExitMetrics?.backgroundExitData{
                Slim.info("background normal app exit: \(exitData.cumulativeNormalAppExitCount)")
                if exitData.cumulativeAbnormalExitCount > 0{
                    Slim.info("background cumulative Abnormal Count: \(exitData.cumulativeAbnormalExitCount)")
                }
                if exitData.cumulativeAppWatchdogExitCount > 0{
                    Slim.info("background total watchdog exits: \(exitData.cumulativeAppWatchdogExitCount)")
                }
                if exitData.cumulativeCPUResourceLimitExitCount > 0{
                    Slim.info("background total cpu limit exits: \(exitData.cumulativeCPUResourceLimitExitCount)")
                }
                if exitData.cumulativeMemoryResourceLimitExitCount > 0{
                    Slim.info("background memory limit exits: \(exitData.cumulativeMemoryResourceLimitExitCount)")
                }
                if exitData.cumulativeMemoryPressureExitCount > 0{
                    Slim.info("background memory pressurse exits: \(exitData.cumulativeMemoryPressureExitCount)")
                }
                if exitData.cumulativeSuspendedWithLockedFileExitCount > 0{
                    Slim.info("background suspended exits: \(exitData.cumulativeSuspendedWithLockedFileExitCount)")
                }
                //crash
                if exitData.cumulativeBadAccessExitCount > 0{
                    Slim.info("background bad acesses count: \(exitData.cumulativeBadAccessExitCount)")
                }
                if exitData.cumulativeIllegalInstructionExitCount > 0{
                    Slim.info("background illegal exits: \(exitData.cumulativeIllegalInstructionExitCount)")
                }
                //timeout
                if exitData.cumulativeBackgroundTaskAssertionTimeoutExitCount > 0{
                    Slim.info("background timeout exits: \(exitData.cumulativeBackgroundTaskAssertionTimeoutExitCount)")
                }
                
            }
        }
    }
}
