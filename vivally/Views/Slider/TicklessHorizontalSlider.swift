//
//  TicklessHorizontalSlider.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 12/22/22.
//

import UIKit

protocol HorizontalSliderDelegate{
    func didChangeValue()
}
class TicklessHorizontalSlider: UIView {

    var delegate:HorizontalSliderDelegate?
    
    var labelTicks = 5
    var tickLabelInterval = 2.0
    var lowestRange = 0.0
    var highestRange = 8.0
    
    var numStack = UIStackView()
    var numArray:[Double] = []
    var numLabels:[UILabel] = []
    
    var sliderOuterView = UIView()
    
    var slidingView = UIView()
    let tipImage = UIImageView(image: UIImage(named: "tooltipNotch"))
    var roundSlideView = UIView()
    var slidingLabel = UILabel()
    
    var slider = CustomSliderAttempt()
    
    var plusButton = UIButton()
    var minusButton = UIButton()
    var sliderStackView = UIStackView()
    
    var fullStack = UIStackView()
    
    var isDiscrete = true
    
    var slidingLeadingConstraint: NSLayoutConstraint = NSLayoutConstraint()
    
    var updatingDisplay = false
    var slideTimer: Timer?
    
    var intervalUniqueSet:Double? = nil
    
    required init(ticksNum: Int = 5, low: Double = 0.0, high: Double = 8.0, discrete: Bool = true){
        labelTicks = ticksNum
        lowestRange = low
        highestRange = high
        isDiscrete = discrete
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func getTickInterval(){
        tickLabelInterval = highestRange / Double(labelTicks - 1)
    }
    
    private func configure() {
        getTickInterval()
        
        configureSlider()
        
        var tickNum = 0.0
        var innerLabels:[UILabel] = []
        for t in 0 ..< labelTicks{
            numArray.append(tickNum)
            
            let intervalLabel = UILabel()
            intervalLabel.textAlignment = .center
            intervalLabel.font = UIFont.bodySm
            intervalLabel.textColor = UIColor.fontBlue
            intervalLabel.text = String(Int(tickNum))
            
            numLabels.append(intervalLabel)
            
            if (t != 0) && (t != labelTicks - 1){
                innerLabels.append(intervalLabel)
            }
            tickNum += tickLabelInterval
        }
        
        numStack = UIStackView(arrangedSubviews: numLabels)   //stick with numLabels for now, maybe later switch to innerLabels for specific padding
        numStack.distribution = .equalCentering
        numStack.alignment = .fill
        
        numStack.isLayoutMarginsRelativeArrangement = true
        numStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: CGFloat(slider.thumbWidth / 2), bottom: 0, trailing: CGFloat(slider.thumbWidth / 2))
        
        sliderStackView = UIStackView(arrangedSubviews: [slider, numStack])
        sliderStackView.distribution = .equalSpacing
        sliderStackView.alignment = .fill
        sliderStackView.axis = .vertical
        
        minusButton.setImage(UIImage(named: "minus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        plusButton.setImage(UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        minusButton.tintColor = UIColor.regalBlue
        plusButton.tintColor = UIColor.regalBlue
        
        fullStack = UIStackView(arrangedSubviews: [minusButton, sliderStackView, plusButton])
        fullStack.alignment = .top
        fullStack.distribution = .fill
        
        fullStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(fullStack)
        
        slidingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(slidingView)
        
        tipImage.translatesAutoresizingMaskIntoConstraints = false
        slidingView.addSubview(tipImage)
        
        roundSlideView.layer.cornerRadius = 6
        roundSlideView.backgroundColor = UIColor.wedgewoodBlue
        roundSlideView.translatesAutoresizingMaskIntoConstraints = false
        slidingView.addSubview(roundSlideView)
        
        slidingLabel.font = UIFont.h6
        slidingLabel.textColor = UIColor.white
        slidingLabel.translatesAutoresizingMaskIntoConstraints = false
        roundSlideView.addSubview(slidingLabel)
        
        slidingLeadingConstraint = slidingView.centerXAnchor.constraint(equalTo: fullStack.arrangedSubviews[1].leadingAnchor, constant: CGFloat(slider.thumbWidth) / 2)
        NSLayoutConstraint.activate([
            slidingLabel.centerXAnchor.constraint(equalTo: roundSlideView.centerXAnchor),
            slidingLabel.leadingAnchor.constraint(equalTo: roundSlideView.leadingAnchor, constant: 8),
            slidingLabel.centerYAnchor.constraint(equalTo: roundSlideView.centerYAnchor),
            slidingLabel.topAnchor.constraint(equalTo: roundSlideView.topAnchor, constant: 4),
            
            roundSlideView.leadingAnchor.constraint(equalTo: slidingView.leadingAnchor),
            roundSlideView.centerXAnchor.constraint(equalTo: slidingView.centerXAnchor),
            roundSlideView.topAnchor.constraint(equalTo: slidingView.topAnchor),
            roundSlideView.bottomAnchor.constraint(equalTo: tipImage.topAnchor, constant: 1),
            slidingLeadingConstraint,
            
            tipImage.bottomAnchor.constraint(equalTo: slidingView.bottomAnchor),
            tipImage.centerXAnchor.constraint(equalTo: slidingView.centerXAnchor),
            tipImage.leadingAnchor.constraint(greaterThanOrEqualTo: slidingView.leadingAnchor),
            tipImage.heightAnchor.constraint(equalToConstant: 6),
            
            slidingView.bottomAnchor.constraint(equalTo: fullStack.topAnchor)
        ])
        
        
        fullStack.arrangedSubviews[1].setContentHuggingPriority(UILayoutPriority(200), for: .horizontal)
        fullStack.arrangedSubviews[0].setContentHuggingPriority(UILayoutPriority(300), for: .horizontal)
        fullStack.arrangedSubviews[1].setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        NSLayoutConstraint.activate([
            fullStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            fullStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            fullStack.topAnchor.constraint(equalTo: self.topAnchor),
            fullStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            fullStack.arrangedSubviews[0].widthAnchor.constraint(equalTo: fullStack.arrangedSubviews[2].widthAnchor)
        ])
        
        minusButton.addTarget(self,
                           action: #selector(didTapMinus),
                              for: .touchDown)
        plusButton.addTarget(self,
                           action: #selector(didTapPlus),
                           for: .touchDown)
        
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
       
        slidingView.isHidden = true
    }
    
    func configureSlider(){
        slider.maximumValue = Float(highestRange)
        slider.minimumValue = Float(lowestRange)
        slider.tintColor = UIColor.regalBlue
        
        slider.setThumbImage(UIImage(named: "sliderThumbControl"), for: .normal)
    }
    
    
    func updateSlidingView(manual: Bool = false){
        let fullRange = slider.maximumValue - slider.minimumValue
        if fullRange != 0{
            let percentage = slider.value / fullRange
            let trackWid = slider.bounds.width - (3 * CGFloat(slider.thumbWidth) / 2)
            let slideConstant = CGFloat(percentage) * trackWid
            slidingLeadingConstraint.constant = slideConstant + (CGFloat(slider.thumbWidth) / 2)
            if manual{
                UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.0, animations: {
                    self.layoutIfNeeded()
                })
            }
                        
            if isDiscrete{
                slidingLabel.text = String(Int(slider.value))
            }
            else{
                let val = Double((slider.value * 100).rounded(.up) / 100)
                slidingLabel.text = String(format: "%.02f", val)
            }
        }
    }
    
    @objc func sliderValueChanged(_ slider: UISlider, event: UIEvent){
        var ended = false
        var callChange = false
        var newValToSet:Float = 0
        if let touchEvent = event.allTouches?.first{
            switch touchEvent.phase{
            case .began, .moved:
                slidingView.isHidden = false
            case .ended, .cancelled:
                ended = true
                slidingView.isHidden = true
                if isDiscrete{
                    newValToSet = slider.value.rounded(.down)
                    callChange = true
                }
            default:
                break
            }
        }
        if intervalUniqueSet != nil{
            if floor(intervalUniqueSet!) == intervalUniqueSet{
                let rem = Int(slider.value) % Int(intervalUniqueSet!)
                if  rem != 0{
                    let goUp =  rem > Int(intervalUniqueSet!) / 2
                    let newVal = goUp ? Int(slider.value) + (Int(intervalUniqueSet!) - rem) : Int(slider.value) - rem
                    newValToSet = Float(newVal)
                    callChange = true
                }
            }
            else{
                let rem = Double(slider.value).truncatingRemainder(dividingBy: intervalUniqueSet!)
                if rem != 0{
                    let goUp = rem > Double(intervalUniqueSet!) / 2
                    let newVal = goUp ? Double(slider.value) + (intervalUniqueSet! - rem) : Double(slider.value) - rem
                    newValToSet = Float(newVal)
                    callChange = true
                }
            }
        }
        
        if callChange{
            slider.setValue(newValToSet, animated: false)
        }
        
        
        updateSlidingView()
        if ended{
            delegate?.didChangeValue()
        }
        checkButtonEnabling()
    }
    
    func stopTimer(){
        if slideTimer != nil {
            slideTimer?.invalidate()
        }
        slideTimer = nil
    }
    
    @objc func hideSlider(){
        slidingView.isHidden = true
    }
    
    @objc func didTapPlus(){
        slidingView.isHidden = false
        slider.setValue(slider.value + (Float(tickLabelInterval)), animated: true)
        startTimer()
        
        updateSlidingView(manual: true)
        checkButtonEnabling()
        delegate?.didChangeValue()
    }
    
    @objc func didTapMinus(){
        slidingView.isHidden = false
        slider.setValue(slider.value - (Float(tickLabelInterval)), animated: true)
        
        startTimer()
        
        updateSlidingView(manual: true)
        checkButtonEnabling()
        delegate?.didChangeValue()
       
    }
    
    func startTimer(){
        stopTimer()
        slideTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.hideSlider), userInfo: nil, repeats: false)
    }
    
    
    func checkButtonEnabling(){
        plusButton.isEnabled = slider.value != slider.maximumValue
        minusButton.isEnabled = slider.value != slider.minimumValue
    }
}

class CustomSliderAttempt: UISlider {

    private let trackHeight: CGFloat = 8

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let shiftPoint = CGPoint(x: bounds.minX + (CGFloat(thumbWidth) / 2), y: bounds.midY)
        return CGRect(origin: shiftPoint, size: CGSize(width: bounds.width - CGFloat(thumbWidth), height: trackHeight))
    }

    let thumbWidth: Float = 24
    lazy var startingOffset: Float = 0 - (thumbWidth / 4) - 1
    lazy var endingOffset: Float = (thumbWidth / 4) - 1

    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let xTranslation =  startingOffset + (minimumValue + endingOffset) / maximumValue * value
        return super.thumbRect(forBounds: bounds, trackRect: rect.applying(CGAffineTransform(translationX: CGFloat(xTranslation), y: 0)), value: value)
    }
}
