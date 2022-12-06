//
//  WristRaiseExtension.swift
//  HandTracker
//
//  Created by hkuit155 on 22/8/2022.
//

import Foundation

/// - **Calibration **
///     - center
///     - camera is filming at some angle
///     - fingers are spread
/// - **Check**
///     - check ratio-y of middle mcp to wrist


class WristExtensionCheck: AbstractCheck {

    var raiseThreshold:Float = 0.5
    var dropThreshold:Float = 0.5
    var currentState = State.idle
    
    override init() {
        super.init()
        fingerSpreadAngleThreshold = [[145, 145, 145], [100, 145, 145], [100, 145, 145], [100, 145, 145], [100, 145, 145]]
        handSideUpperThreshold = 0.45
        handSideLowerThreshold = 0.2
    }
    
    enum State {
        case idle, ready, raised, dropped
    }
    
    func onChangeCurrentState(_ state: State) {
        if (currentState != state) {
            currentState = state
            
            switch(currentState) {

            case .ready:
                self.checkUpdateDelegate?.didUpdateStateDelegate("READY")
            case .raised:
                self.checkUpdateDelegate?.didUpdateStateDelegate("RAISED")
            case .dropped:
                self.checkUpdateDelegate?.didUpdateStateDelegate("DROPPED")
            case .idle:
                return
            }
        }
    }
    
    
    override func check(_ landmarks: [Landmark]!) {
        super.check(landmarks)
        
        let wrist_to_middle_mcp_ratio_y = cal_ratio_y(wrist, fingers[2][0])
        print("wrist to middle ratio-y: \(wrist_to_middle_mcp_ratio_y)")
        
        
        if (isHandAtCenter()) {
            if (currentState == .idle) {
                if (isHandSide()) {
                    onChangeCurrentState(.ready)
                }
            }
            else if (isFingerSpread(1, 4)) {
                switch(currentState) {
                    
                case .ready:
                    print("state: ^ready")
                    if(!isWristRaised() && wrist_to_middle_mcp_ratio_y > dropThreshold) {
                        onChangeCurrentState(.dropped)
                    }
                    else if(isWristRaised() && wrist_to_middle_mcp_ratio_y > raiseThreshold) {
                        onChangeCurrentState(.raised)
                    }
                case .dropped:
                    print("state: ^dropped")
                    if(isWristRaised() && wrist_to_middle_mcp_ratio_y > raiseThreshold) {
                        onChangeCurrentState(.raised)
                        count += 0.5
                        self.checkUpdateDelegate?.didUpdateCountDelegate(Int(count))
                    }
                case .raised:
                    print("state: ^raised")
                    if(!isWristRaised() && wrist_to_middle_mcp_ratio_y < dropThreshold) {
                        onChangeCurrentState(.dropped)
                        count += 0.5
                        self.checkUpdateDelegate?.didUpdateCountDelegate(Int(count))
                    }
                case .idle:
                    return
                }
                
                print("count: \(count)")
            }
        }
    }
    
    func isWristRaised() -> Bool {
        
        if (fingers[2][0].y < wrist.y) {
            return true
        }
        else {
            return false
        }
    }

}
