//
//  TestCheck.swift
//  HandTracker
//
//  Created by hkuit155 on 29/8/2022.
//

import Foundation

class TestCheck: AbstractCheck {
    
    var threshold:[Float] = [0.65, 0.6, 0.5]
    var currentState = State.idle

    override init() {
        super.init()
    }
    
    enum State {
        case idle, ready, up, notUp
    }
    
    func onChangeCurrentState(_ state: State) {
        if (currentState != state) {
            currentState = state
            
            switch(currentState) {
        
            case .idle:
                return
            case .ready:
                self.checkUpdateDelegate?.didUpdateStateDelegate("READY")
            case .up:
                self.checkUpdateDelegate?.didUpdateStateDelegate("UP")
            case .notUp:
                self.checkUpdateDelegate?.didUpdateStateDelegate("NOT UP")

            }
        }
    }
    
    override func check(_ landmarks: [Landmark]!) {
        super.check(landmarks)
        
        switch(currentState) {
            
        case .idle:
            onChangeCurrentState(.ready)
        case .ready:
            if(isFingerUp(1,1)) {
                onChangeCurrentState(.up)
            }
            else {
                onChangeCurrentState(.notUp)
            }
        case .up:
            if (!isFingerUp(1,1)) {
                onChangeCurrentState(.notUp)
            }
        case .notUp:
            if(isFingerUp(1,1)) {
                onChangeCurrentState(.up)
            }
        }
        
        
//        if (isFingerFold(3,3)) {
//            return
//        }
//        let i = 2
//        let pip_dip_ratio_z = cal_ratio_z(fingers[i][1], fingers[i][2])
//        let dip_tip_ratio_z = cal_ratio_z(fingers[i][2], fingers[i][3])
//
//        print("Index_PIP_z: \(fingers[i][1].z)")
//        print("Index_DIP_z: \(fingers[i][2].z)")
//        print("Index_TIP_z: \(fingers[i][3].z)")
//        print("PIP_DIP_Ratio_z: \(pip_dip_ratio_z)")
//        print("DIP_TIP_Ratio_z: \(dip_tip_ratio_z)")
    }
    
    func isFingerFold(_ from:Int = 0, _ til:Int = 4) -> Bool {
        
        for i in from...til {
            
            if (i==0) {
                
                continue
            }
            
            let finger_ratio_z_1 = cal_ratio_z(fingers[i][0], fingers[i][1])
            let finger_ratio_z_2 = cal_ratio_z(fingers[i][1], fingers[i][2])
            let finger_ratio_z_3 = cal_ratio_z(fingers[i][2], fingers[i][3])
            
            if (finger_ratio_z_1 > threshold[0] || finger_ratio_z_2 > threshold[1] || finger_ratio_z_3 > threshold[2] ) {
                
                print("Should not fold: \(i)")
                print(finger_ratio_z_1)
                print(finger_ratio_z_2)
                print(finger_ratio_z_3)
                return false
            }
        }
        
        print("is spread")
        return true
    }
    
    func isHorizontalView() -> Bool {
        print(fingers[0][3].z)
        print(wrist.z)
        return true
    }
}
