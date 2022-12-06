//
//  FingerExtensionCheck.swift
//  HandTracker
//
//  Created by hkuit155 on 26/8/2022.
//

import Foundation

/// - **Calibration **
///     - hand side is shown to camera
///     - pinky should on camera side

/// - **Check**
///     - check fingers are fold or not
///     - final state: check fingers are straightly spread


class FingerExtensionCheck: AbstractCheck {
    
    var currentState = State.idle
    
    override init() {
        super.init()
    }
    
    enum State {
        case idle, ready, fold, thumb, index, middle, ring, pinky, flat
    }
        
    
    func onChangeCurrentState(_ state: State) {
        if (currentState != state) {
            currentState = state
            
            switch(currentState) {

            case .idle:
                return
            case .ready:
                self.checkUpdateDelegate?.didUpdateStateDelegate("READY")
            case .fold:
                self.checkUpdateDelegate?.didUpdateStateDelegate("FOLD")
            case .thumb:
                self.checkUpdateDelegate?.didUpdateStateDelegate("THUMB")
            case .index:
                self.checkUpdateDelegate?.didUpdateStateDelegate("INDEX")
            case .middle:
                self.checkUpdateDelegate?.didUpdateStateDelegate("MIDDLE")
            case .ring:
                self.checkUpdateDelegate?.didUpdateStateDelegate("RING")
            case .pinky:
                self.checkUpdateDelegate?.didUpdateStateDelegate("PINKY")
            case .flat:
                self.checkUpdateDelegate?.didUpdateStateDelegate("FLAT")
            }
        }
    }
    
    override func check(_ landmarks: [Landmark]!) {
        super.check(landmarks)

        if (isHandAtCenter()) {
            
            if (currentState == .idle) {
                if (/*isPinkyCloser() && */isCameraHorizontal() && isHandSide()) {
                    onChangeCurrentState(.ready)
                }
            }
            else {
                switch(currentState) {
                    
                case .idle:
                    return
                case .ready:
                    if (isFingerFold()) {
                        onChangeCurrentState(.fold)
                    }
                    print("state: ^ready")
                case .fold:
                    if (isFingerNOTFold(0,0) && isFingerFold(1,4)) {
                        onChangeCurrentState(.thumb)
                    }
                    print("state: ^fold")
                case .thumb:
                    if (isFingerNOTFold(0,1) && isFingerFold(2,4)) {
                        onChangeCurrentState(.index)
                    }
                    print("state: one")
                case .index:
                    if (isFingerNOTFold(0,2) && isFingerFold(3,4)) {
                        onChangeCurrentState(.middle)
                    }
                    print("state: ^two")
                case .middle:
                    if (isFingerNOTFold(0,3) && isFingerFold(4,4)) {
                        onChangeCurrentState(.ring)
                    }
                    print("state: ^three")
                case .ring:
                    if (isFingerNOTFold(0,4)) {
                        onChangeCurrentState(.pinky)
                    }
                    print("state: ^four")
                case .pinky:
                    if (isFingerSpread(1,4)) {
                        onChangeCurrentState(.flat)
                        count += 1
                        self.checkUpdateDelegate?.didUpdateCountDelegate(Int(count))
                    }
                    print("state: ^five")
                case .flat:
                    if (isFingerFold()) {
                        onChangeCurrentState(.fold)
                    }
                    print("state: ^flat")
                }
            }
            
            print("count: \(count)")
        }
    }
    
    func isFingerFold(_ from:Int = 0, _ til:Int = 4) -> Bool {
        
        for i in from...til {
            
            if (i==0) {
                let thumb_angle_1 = cal_angle(fingers[0][1], fingers[0][2], wrist)
                let thumb_angle_2 = cal_angle(fingers[0][2], fingers[0][1], fingers[0][3])
                if (thumb_angle_1 > 135.0 || thumb_angle_2 > 160.0) {
                    
                    print("Should fold: \(i)")
                    print(thumb_angle_1)
                    print(thumb_angle_2)
                    return false
                }
                continue
            }
            
            let finger_depth_1 = fingers[i][1].z
            let finger_depth_2 = fingers[i][2].z
            let finger_depth_3 = fingers[i][3].z
            
            if (finger_depth_1 > finger_depth_2 || finger_depth_2 > finger_depth_3 ) {
                
                print("Should fold: \(i)")
                print(finger_depth_1)
                print(finger_depth_2)
                print(finger_depth_3)
                return false
            }
        }
        
        print("is fold")
        return true
    }
    
    override func isFingerNOTFold(_ from:Int = 0, _ til:Int = 4) -> Bool {
        
        for i in from...til {
            
            if (i==0) {
                let thumb_angle_1 = cal_angle(fingers[0][1], fingers[0][2], wrist)
                let thumb_angle_2 = cal_angle(fingers[0][2], fingers[0][1], fingers[0][3])
                if (thumb_angle_1 < 140.0 || thumb_angle_2 < 170.0) {
                    
                    print("Should not fold: \(i)")
                    print(thumb_angle_1)
                    print(thumb_angle_2)
                    return false
                }
                continue
            }
            
            let finger_depth_1 = fingers[i][1].z
            let finger_depth_2 = fingers[i][2].z
            let finger_depth_3 = fingers[i][3].z
            
            if (finger_depth_1 < finger_depth_2 || finger_depth_2 < finger_depth_3 ) {
                
                print("Should not fold: \(i)")
                print(finger_depth_1)
                print(finger_depth_2)
                print(finger_depth_3)
                return false
            }
            
        }
        print("is NOT fold")
        return true
    }
}
