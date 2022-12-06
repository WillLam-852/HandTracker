//
//  ThumAbductionCheck.swift
//  HandTracker
//
//  Created by hkuit155 on 23/8/2022.
//

import Foundation


/// - **Calibration **
///     - center
///     - fingers are straightly spread
///     - fingers are clinging
///     - hand rotate
///     - thumb is on camera side
/// - **Check**
///     - check angle between thumb and index

class ThumbAbductionCheck: AbstractCheck {

    var thumbOpenAngle: Float = 60
    var thumbCloseAngle: Float = 10
    var currentState = State.idle
    
    override init() {
        super.init()
        fingerSpreadAngleThreshold = [[145, 145, 145], [100, 145, 145], [100, 145, 145], [100, 145, 145], [100, 145, 145]]
        handSideUpperThreshold = 0.4
        handSideLowerThreshold = 0.2
    }
    
    enum State {
        case idle, ready, open, close
    }
    
    func onChangeCurrentState(_ state: State) {
        if (currentState != state) {
            currentState = state
            
            switch(currentState) {

            case .ready:
                self.checkUpdateDelegate?.didUpdateStateDelegate("READY")
            case .open:
                self.checkUpdateDelegate?.didUpdateStateDelegate("OPEND")
            case .close:
                self.checkUpdateDelegate?.didUpdateStateDelegate("CLOSED")
            case .idle:
                return
            }
        }
    }
    
    override func check(_ landmarks: [Landmark]!) {
        super.check(landmarks)
        
        let thumb_angle = cal_angle_by_4_points(fingers[0][1], fingers[0][2], fingers[1][0], fingers[1][3])
        //print("thumb index angle: \(thumb_angle)")

        
        if (isHandAtCenter()) {

            if (currentState == .idle) {
                if (isHandSide() && isThumbCloser() && isCameraHorizontal()) {
                    onChangeCurrentState(.ready)
                }
            }
            else if (isFingerClinging(0) && isFingerSpread(1,4)) {
                
                switch(currentState) {
                    
                case .idle:
                    return
                case .ready:
                    print("state: ^ready")
                    if(thumb_angle < thumbCloseAngle) {
                        onChangeCurrentState(.close)
                    }
                    else if(thumb_angle > thumbOpenAngle) {
                        onChangeCurrentState(.open)
                    }
                case .close:
                    print("state: ^clossed")
                    if(thumb_angle > thumbOpenAngle) {
                        onChangeCurrentState(.open)
                    }
                case .open:
                    print("state: ^opened")
                    if(thumb_angle < thumbCloseAngle) {
                        onChangeCurrentState(.close)
                        count += 1
                        self.checkUpdateDelegate?.didUpdateCountDelegate(Int(count))
                    }
                }
                
                print("count: \(count)")
            }
        }
    }

}
