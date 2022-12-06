//
//  FingerExerciseCheck.swift
//  HandTracker
//
//  Created by hkuit155 on 29/8/2022.
//

import Foundation

/// - **Calibration **
///     - center
///     - fingers are folded

/// - **Check**
///     - specific fingers are rised veritcally

class FingerExerciseCheck: AbstractCheck {

    var currentState = State.idle
    var fingerRaisedThreshold:Float = 0.6
    var fingerFoldThreshold:Float = 0.3
    
    override init() {
        super.init()
        handSideUpperThreshold = 0.7
        handSideLowerThreshold = 0.6
        fingerSpreadAngleThreshold = [[145, 145, 145], [100, 145, 145], [100, 145, 145], [100, 145, 145], [100, 145, 145]]
    }
    
    enum State {
        case idle, ready, fold_init, index, middle, ring, pinky, thumb, fold, ok
    }
    
    
    func onChangeCurrentState(_ state: State) {
        if (currentState != state) {
            currentState = state
            
            switch(currentState) {
        
            case .idle:
                return
            case .ready:
                self.checkUpdateDelegate?.didUpdateStateDelegate("READY")
            case .fold_init:
                self.checkUpdateDelegate?.didUpdateStateDelegate("INIT FOLD")
            case .index:
                self.checkUpdateDelegate?.didUpdateStateDelegate("INDEX")
            case .middle:
                self.checkUpdateDelegate?.didUpdateStateDelegate("MIDDLE")
            case .ring:
                self.checkUpdateDelegate?.didUpdateStateDelegate("RING")
            case .pinky:
                self.checkUpdateDelegate?.didUpdateStateDelegate("PINKY")
            case .thumb:
                self.checkUpdateDelegate?.didUpdateStateDelegate("THUMB")
            case .fold:
                self.checkUpdateDelegate?.didUpdateStateDelegate("FOLD")
            case .ok:
                self.checkUpdateDelegate?.didUpdateStateDelegate("OK")
            }
        }
    }
    
    override func check(_ landmarks: [Landmark]!) {
        super.check(landmarks)
        
        let index_ratio_y = cal_ratio_y(fingers[1][0], fingers[1][3])
        let middle_ratio_y = cal_ratio_y(fingers[2][0], fingers[2][3])
        let ring_ratio_y = cal_ratio_y(fingers[3][0], fingers[3][3])
        let pinky_ratio_y = cal_ratio_y(fingers[4][0], fingers[4][3])
        
        print(index_ratio_y)
        print(middle_ratio_y)
        print(ring_ratio_y)
        print (pinky_ratio_y)
        
        if (isHandAtCenter()) {
            
            switch(currentState) {
                
            case .idle:
                if (isHandSide(3,4) && isPinkyCloser()) {
                    onChangeCurrentState(.ready)
                }
            case .ready:
                if (isFingerFold(0,4)) {
                    onChangeCurrentState(.fold_init)
                    print("state: ^ready")
                }
            case .fold_init:
                if (isFingerSpread(1,1) && isFingerFold(2,4)) {
                    onChangeCurrentState(.index)
                    print("state: ^ready")
                }
            case .index:
                if (isFingerSpread(1,2) && isFingerFold(3,4)) {
                    onChangeCurrentState(.middle)
                    print("state: ^index")
                }
            case .middle:
                if (isFingerSpread(1,3) && isFingerFold(4,4)) {
                    onChangeCurrentState(.ring)
                    print("state: ^middle")
                }
            case .ring:
                if (isFingerSpread(1,4)) {
                    onChangeCurrentState(.pinky)
                    print("state: ^ring")
                }
            case .pinky:
                if (isFingerSpread(0,4)) {
                    onChangeCurrentState(.thumb)
                    print("state: ^pinky")
                }
            case .thumb:
                if (isFingerFold(0,4)) {
                    onChangeCurrentState(.fold)
                    print("state: ^thumb")
                }
            case .fold:
                if (isFingerSpread(2,4) && isFingerFold(0,1)) {
                    onChangeCurrentState(.ok)
                    print("state: ^fold")
                }
            case .ok:
                if (isFingerFold(0,4)) {
                    onChangeCurrentState(.ready)
                    count += 1
                    self.checkUpdateDelegate?.didUpdateCountDelegate(Int(count))
                    print("state: ^ok")
                }
            }
        }
    }
                    
    override func isFingerSpread(_ from:Int = 0, _ til:Int = 4) -> Bool {

        for i in from...til {
            
            let finger_angle_1 = cal_angle(fingers[i][0], wrist, fingers[i][1])
            let finger_angle_2 = cal_angle(fingers[i][1], fingers[i][0], fingers[i][2])
            let finger_angle_3 = cal_angle(fingers[i][2], fingers[i][1], fingers[i][3])
            
            if (finger_angle_1 < fingerSpreadAngleThreshold[i][0] ||  finger_angle_2 < fingerSpreadAngleThreshold[i][1] ||  finger_angle_3 < fingerSpreadAngleThreshold[i][2] || fingers[i][3].y > fingers[i][2].y) {

                print("Not spread: \(i)")
                print(finger_angle_1)
                print(finger_angle_2)
                print(finger_angle_3)
                return false
            }
        }
        print("All spread")
        return true
    }
    
    func isFingerFold(_ from:Int = 0, _ til:Int = 4) -> Bool {
        
        for i in from...til {
            // THUMB
            if (i == 0 ) {
                continue
            }
            // PINKY
            else if (i == 4) {
                if (fingers[i][1].y > fingers[i][3].y) {
                    print("Should fold: \(i)")
                    print(fingers[i][0].y)
                    print(fingers[i][3].y)
                    return false
                }
            }
            // OTHERS
            else {
                if (fingers[i][0].y > fingers[i][3].y) {
                    
                        print("Should fold: \(i)")
                        print(fingers[i][0].y)
                        print(fingers[i][3].y)
                        return false
                }
            }
        }
        
        print("is fold")
        return true
    }
}
