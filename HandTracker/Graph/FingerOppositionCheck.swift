//
//  FingerOppositionCheck.swift
//  HandTracker
//
//  Created by hkuit155 on 29/8/2022.
//

import Foundation

/// - **Calibration **
///     - center
///     - hand side
///     - fingers are not folded

/// - **Check**
///     - specific finger is folded, while others are not
///     - finger tips are touched (close enough)

class FingerOppositionCheck: AbstractCheck {

    var handRotateInwardThreshold:Float = 0.1
    var handRotateOutwardThreshold:Float = 0.4
    var currentState = State.idle
    
    override init() {
        super.init()
        handSideUpperThreshold = 0.7
        handSideLowerThreshold = 0.6
    }
    
    enum State {
        case idle, ready, index, middle, ring, pinky
    }
    
    
    func onChangeCurrentState(_ state: State) {
        if (currentState != state) {
            currentState = state
            
            switch(currentState) {
        
            case .idle:
                return
            case .ready:
                self.checkUpdateDelegate?.didUpdateStateDelegate("READY")
            case .index:
                self.checkUpdateDelegate?.didUpdateStateDelegate("INDEX")
            case .middle:
                self.checkUpdateDelegate?.didUpdateStateDelegate("MIDDLE")
            case .ring:
                self.checkUpdateDelegate?.didUpdateStateDelegate("RING")
            case .pinky:
                self.checkUpdateDelegate?.didUpdateStateDelegate("PINKY")
            }
        }
    }
    
    override func check(_ landmarks: [Landmark]!) {
        super.check(landmarks)
        
        let index_dip_to_tip = cal_dist(fingers[0][2], fingers[0][3])
        let middle_dip_to_tip = cal_dist(fingers[1][2], fingers[1][3])
        let ring_dip_to_tip = cal_dist(fingers[2][2], fingers[2][3])
        let pinky_dip_to_tip = cal_dist(fingers[3][2], fingers[3][3])
        
        if (isHandAtCenter())  {
            
            switch(currentState) {
                
            case .idle:
                if (isFingerNOTFold() && isHandSide()) {
                    onChangeCurrentState(.ready)
                }
            case .ready:
                if (isFingerNOTFold(2,4) && cal_dist(fingers[0][3], fingers[1][3]) < index_dip_to_tip) {
                    onChangeCurrentState(.index)
                }
                print("state: ^ready")
            case .index:
                if (isFingerNOTFold(1,1) && isFingerNOTFold(3,4) && cal_dist(fingers[0][3], fingers[2][3]) < middle_dip_to_tip) {
                    onChangeCurrentState(.middle)
                }
                print("state: ^index")
            case .middle:
                if (isFingerNOTFold(1,2) && isFingerNOTFold(4,4) && cal_dist(fingers[0][3], fingers[3][3]) < ring_dip_to_tip) {
                    onChangeCurrentState(.ring)
                }
                print("state: ^middle")
            case .ring:
                if (isFingerNOTFold(1, 3) && cal_dist(fingers[0][3], fingers[4][3]) < pinky_dip_to_tip) {
                    onChangeCurrentState(.pinky)
                }
                print("state: ^ring")
            case .pinky:
                if (isFingerNOTFold() && isHandSide()) {
                    onChangeCurrentState(.ready)
                    count += 1
                    self.checkUpdateDelegate?.didUpdateCountDelegate(Int(count))
                }
                print("state: ^pinky")
            }
            
            print("count: \(count)")
        }
    }
    
    override func cal_dist (_ pt1: Landmark!, _ pt2: Landmark!) -> Float {
        
        let dist = pow(pt1.x-pt2.x, 2) + pow(pt1.y-pt2.y, 2)
        
        return sqrt(dist)
    }
}
