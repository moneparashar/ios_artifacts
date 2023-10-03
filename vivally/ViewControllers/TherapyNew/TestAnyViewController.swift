//
//  TestAnyViewController.swift
//  vivally
//
//  Created by Nadia Karina Camacho Cabrera on 12/20/22.
//

import UIKit
import Lottie

class TestAnyViewController: UIViewController {

    @IBOutlet weak var lottieView: UIView!
    
    
    var allAnimationViews:[AnimationView] = []
    let backanimationView = AnimationView()
    let trackFillView = AnimationView()
    let emgLabelAnimationView = AnimationView()
    let screeningEMGActiveView = AnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //datesformats()
        //lottiebah()
        //screeninglottiebah()
        // Do any additional setup after loading the view.
       //addSegment()
        addDrop()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func addDrop(){
        let bah = DropdownOriginView()
        bah.setup(title: "Schedule", options: ["Daily", "1 / Week", "3 / Week", "never"])
        bah.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(bah)
        NSLayoutConstraint.activate([
            bah.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            bah.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            bah.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
            
        ])
        
        let typicalTf = TextFieldStackView()
        typicalTf.setup(title: "Schedule", placeholder: "", toggle: false, dropDown: true, search: false)
        typicalTf.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(typicalTf)
        
        NSLayoutConstraint.activate([
            typicalTf.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            typicalTf.topAnchor.constraint(equalTo: bah.bottomAnchor),
            typicalTf.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    func addSegment(){
        let groupsegmentView = GroupedSegmentView(optionNum: 4)
        //groupsegmentView.setup(textArr: ["Daily", "Weekly", "Monthly"])
        let eveningImage = UIImage(named: "eveningLight")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        groupsegmentView.setup(imgArr: [eveningImage, eveningImage, eveningImage, eveningImage])
        groupsegmentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(groupsegmentView)
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            groupsegmentView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
            groupsegmentView.topAnchor.constraint(equalTo: safe.topAnchor),
            groupsegmentView.trailingAnchor.constraint(equalTo: safe.trailingAnchor)
        ])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            groupsegmentView.selectSegment(segment: 1)
        }
    }
    
    func datesformats(){
        if let date = Calendar.utcCal.date(bySettingHour: 1, minute: 0, second: 0, of: Date()){
            
            let oldDF = DateFormatter.iso8601Full
            let newDf = DateFormatter.iso8601WithOffset
            print("old: \(oldDF.string(from: date))")   //note don't even see timezone, just get passed Z
            print("new: \(newDf.string(from: date))")
            
        }
        
    }

    func lottiebah(){
        backanimationView.animation = Animation.named(AnimationLottieNames.screeningBackground.rawValue)
        backanimationView.frame.size = lottieView.frame.size
        //backanimationView.contentMode = .scaleToFill
        
        backanimationView.contentMode = .scaleAspectFit
        lottieView.addSubview(backanimationView)
        backanimationView.backgroundBehavior = .pauseAndRestore
        //animationView.loopMode = .loop
        //var endframes = animationView.animation?.endFrame
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            
        }
    }
    
    func screeninglottiebah(){
        backanimationView.animation = Animation.named(AnimationLottieNames.screeningBackground.rawValue)
        trackFillView.animation = Animation.named(AnimationLottieNames.screeningFillActive.rawValue)
        emgLabelAnimationView.animation = Animation.named(AnimationLottieNames.screeningEMGLabel.rawValue)
        screeningEMGActiveView.animation = Animation.named(AnimationLottieNames.screeningEMGActive.rawValue)
        
        //trackFillView.logHierarchyKeypaths()
        emgLabelAnimationView.logHierarchyKeypaths()
        
        if let colorWork = UIColor.macCheese?.lottieColorValue {
            let fillColorValueProvider = ColorValueProvider(colorWork)
            let trackFillKey = AnimationKeypath(keypath: "**.Stroke 1.Color")
            trackFillView.setValueProvider(fillColorValueProvider, keypath: trackFillKey)
            
        }
        
        allAnimationViews = [backanimationView, trackFillView, emgLabelAnimationView, screeningEMGActiveView]
        
        for av in allAnimationViews{
            
            av.contentMode = .scaleAspectFill
            av.translatesAutoresizingMaskIntoConstraints = false
            lottieView.addSubview(av)
        }
        
        /*
        backanimationView.animation = Animation.named(AnimationLottieNames.screeningBackground.rawValue)
        backanimationView.contentMode = .scaleAspectFill
        backanimationView.translatesAutoresizingMaskIntoConstraints = false
        lottieView.addSubview(backanimationView)
        backanimationView.backgroundBehavior
         
         NSLayoutConstraint.activate([
             backanimationView.centerXAnchor.constraint(equalTo: lottieView.centerXAnchor),
             backanimationView.centerYAnchor.constraint(equalTo: lottieView.centerYAnchor),
             backanimationView.topAnchor.constraint(greaterThanOrEqualTo: lottieView.topAnchor),
             backanimationView.leadingAnchor.constraint(greaterThanOrEqualTo: lottieView.leadingAnchor),
             
         ])
        */
        
        for av in allAnimationViews{
            NSLayoutConstraint.activate([
                av.centerXAnchor.constraint(equalTo: lottieView.centerXAnchor),
                av.centerYAnchor.constraint(equalTo: lottieView.centerYAnchor),
                av.topAnchor.constraint(greaterThanOrEqualTo: lottieView.topAnchor),
                av.leadingAnchor.constraint(greaterThanOrEqualTo: lottieView.leadingAnchor)
            ])
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.trackFillView.play()
            self.screeningEMGActiveView.play()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                let bahColor = UIColor.purple.lottieColorValue
                let fillColorValueProvider = ColorValueProvider(bahColor)
                let trackFillKey = AnimationKeypath(keypath: "**.Stroke 1.Color")
                self.trackFillView.setValueProvider(fillColorValueProvider, keypath: trackFillKey)
                
                
                
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
