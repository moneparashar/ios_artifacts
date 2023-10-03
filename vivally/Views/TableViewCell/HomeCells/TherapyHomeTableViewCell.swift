//
//  TherapyHomeTableViewCell.swift
//  vivally
//
//  Created by Joe Sarkauskas on 6/2/21.
//

import UIKit

protocol TherapyHomeTableViewCellDelegate{
    func pairSystemTherapyButtonTapped()
    func quickStartTherapyButtonTapped()
    func therapyLinkButtonTapped()
    func statusLinkButtonTapped()
}

class TherapyHomeTableViewCell: ShadowTableViewCell {

    var delegate:TherapyHomeTableViewCellDelegate?
    var blinkTimer:Timer?
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var therapyRunAllView: UIView!
    @IBOutlet weak var therapyRunCircleView: UIView!
    @IBOutlet weak var circleProgressView: CircularProgressBar!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    @IBOutlet weak var therapyImage: UIImageView!
    
    @IBOutlet weak var bluetoothLEDImage: UIImageView!
    @IBOutlet weak var bluetoothStatusLabel: UILabel!
    
    @IBOutlet weak var sessionStatusLabel: UILabel!
    @IBOutlet weak var lastSessionDateLabel: UILabel!
    @IBOutlet weak var batteryStatusLEDImage: UIImageView!
    @IBOutlet weak var batteryPercentageLabel: UILabel!
    @IBOutlet weak var batteryStatusMessageLabel: UILabel!
    
    @IBOutlet weak var stimDisconnectLabel: UILabel!
    @IBOutlet weak var checkStatusButton: UIButton!
    
    
    @IBOutlet weak var pairSystemButton: UIButton!
    @IBOutlet weak var quickStartButton: UIButton!
    
    var isBlinkOn:Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backView.layer.borderWidth = 1
        backView.layer.cornerRadius = 15
        backView.layer.borderColor = UIColor.clear.cgColor
        backView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    /*
    @objc func fireTimer() {
        //print("Timer fired!")
       
        
        if isBlinkOn{
            bluetoothLEDImage.image = UIImage(named: "bluetooth_led_on")
        }
        else{
            bluetoothLEDImage.image = nil
        }
        
        isBlinkOn = !isBlinkOn
    }
    
    func startTimer(){
        stopTimer()
        blinkTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    func stopTimer(){
        if blinkTimer != nil{
            blinkTimer?.invalidate()
        }
        blinkTimer = nil
    }
    */
    
    func setCircles(){
        therapyRunCircleView.layer.cornerRadius = therapyRunCircleView.bounds.size.height / 2
        quickStartButton.layer.cornerRadius = quickStartButton.bounds.size.height / 2
        pairSystemButton.layer.cornerRadius = pairSystemButton.bounds.size.height / 2
    }
    
    func setupView(isBluetoothConnected:Bool, batterySOC:BatteryStateOfCharge, lastTherapy:String, therapyRunning: Bool = false, paired: Bool = true){
        therapyRunAllView.isHidden = true
        
        setCircles()
        addShadow()
        therapyImage.image = UIImage(named: "ic_sessions_off")!.withRenderingMode(.alwaysTemplate)
        lastSessionDateLabel.text = lastTherapy
        //stopTimer()
        
        if isBluetoothConnected{
            stimDisconnectLabel.isHidden = true
            checkStatusButton.isHidden = true
            
            batteryStatusLEDImage.image = UIImage(named: "battery_led_red")
            if batterySOC.isBatteryGreen(){
                batteryStatusLEDImage.image = UIImage(named: "battery_led_green")
            }
            
            let batteryPercent = String(batterySOC.level)
            batteryPercentageLabel.text = "Device battery " + batteryPercent + "%:"
            if batterySOC.level < 60 {
                batteryStatusLEDImage.image = UIImage(named: "battery_led_yellow")
                batteryStatusMessageLabel.text = "Think about charging"
            }
            else{
                batteryStatusMessageLabel.text = ""
            }
            
            batteryStatusLEDImage.isHidden = false
            batteryPercentageLabel.isHidden = false
            batteryStatusMessageLabel.isHidden = false
        }
        else{
            batteryStatusLEDImage.isHidden = true
            batteryPercentageLabel.isHidden = true
            batteryStatusMessageLabel.isHidden = true
            stimDisconnectLabel.isHidden = false
            checkStatusButton.isHidden = false
        }
        
        if therapyRunning && isBluetoothConnected{
            therapyRunAllView.isHidden = false
            
            sessionStatusLabel.text = "Therapy session in progress"
            lastSessionDateLabel.isHidden = true
            
            let timePass = TherapyManager.sharedInstance.timeSession - Double(BluetoothManager.sharedInstance.informationServiceData.stimStatus.timeRemaining)
            let percent = timePass / TherapyManager.sharedInstance.timeSession
            if percent > 0 && !percent.isNaN{
                circleProgressView.updateView(currentPercent: percent, darkGreen: true)
            }
        }
        else{
            therapyRunAllView.isHidden = true
            sessionStatusLabel.text = "Last completed session on"
            lastSessionDateLabel.isHidden = false
            
            pairSystemButton.titleLabel?.textAlignment = .center
            quickStartButton.isHidden = !paired
            
            
        }
    }
    
    func addShadow(){
        therapyRunCircleView.layer.masksToBounds = false
        therapyRunCircleView.layer.shadowColor = UIColor(named: "avationShadow")?.cgColor
        therapyRunCircleView.layer.shadowOpacity = 1
        therapyRunCircleView.layer.shadowOffset = CGSize.init(width: 0, height: 4)
        therapyRunCircleView.layer.shadowRadius = 4
        
        quickStartButton.layer.masksToBounds = false
        quickStartButton.layer.shadowColor = UIColor(named: "avationShadow")?.cgColor
        quickStartButton.layer.shadowOpacity = 1
        quickStartButton.layer.shadowOffset = CGSize.init(width: 0, height: 4)
        quickStartButton.layer.shadowRadius = 4
        
        pairSystemButton.layer.masksToBounds = false
        pairSystemButton.layer.shadowColor = UIColor(named: "avationShadow")?.cgColor
        pairSystemButton.layer.shadowOpacity = 1
        pairSystemButton.layer.shadowOffset = CGSize.init(width: 0, height: 4)
        pairSystemButton.layer.shadowRadius = 4
    }
    
    @IBAction func pairSystemTherapyButtonTapped(_ sender: Any) {
        delegate?.pairSystemTherapyButtonTapped()
    }
    
    @IBAction func quickStartTherapyButtonTapped(_ sender: Any) {
        delegate?.quickStartTherapyButtonTapped()
    }
    
    @IBAction func runningTherapyButtonTapped(_ sender: Any) {
        delegate?.quickStartTherapyButtonTapped()
    }
    
    
    @IBAction func therapyLinkButtonTapped(_ sender: Any) {
        delegate?.therapyLinkButtonTapped()
    }
    
    @IBAction func statusLinkButtonTapped(_ sender: Any) {
        delegate?.statusLinkButtonTapped()
    }
    
}
