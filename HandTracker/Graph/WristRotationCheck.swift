//
//  WristRotationCheck.swift
//  HandTracker
//
//  Created by hkuit155 on 22/8/2022.
//

import Foundation

/// - **Calibration **
///     - center
///     - angle of shot not too large
///     - hand front
///     - fingers are not folded
///     - **assume initially thumb is pointing inward**

/// - **Check**
///     - left hand or right hand
///     - thumb is on the right or left of wrist
///     - rotate angle of hand
///     - **when potining inward, also check whether hand is tilt**

class WristRotationCheck: AbstractCheck {

    var handRotateInwardThreshold:Float = 0.3
    var handRotateOutwardThreshold:Float = 0.3
    var currentState = State.idle
    var hand = Hand.right
    
    override init() {
        super.init()
    }
    
    enum State {
        case idle, ready, inward, outward
    }
    
    enum Hand {
        case left, right
    }
    
    
    func onChangeCurrentState(_ state: State) {
        if (currentState != state) {
            currentState = state
            
            switch(currentState) {

            case .ready:
                self.checkUpdateDelegate?.didUpdateStateDelegate("READY")
            case .inward:
                self.checkUpdateDelegate?.didUpdateStateDelegate("INWARD")
            case .outward:
                self.checkUpdateDelegate?.didUpdateStateDelegate("OUTWARD")
            case .idle:
                return
            }
        }
    }
    
    override func check(_ landmarks: [Landmark]!) {
        super.check(landmarks)
        
        let vertical_angle = cal_ratio_y(fingers[1][1], fingers[2][1])
        print(vertical_angle)

        if (isHandAtCenter()) {
            if (currentState == .idle) {
                if (isHandFront() && isCameraHorizontal()) {
                    onChangeCurrentState(.ready)
                }
            }
            else if (isFingerNOTFold()) {
            
                switch (currentState) {
                case .idle:
                    return
                case .ready:
                    print("state: ^ready")
                    if (isThumbRHS() && vertical_angle < handRotateOutwardThreshold) {
                        hand = .left
                        onChangeCurrentState(.inward)
                    }
                    else if (isThumbLHS() && vertical_angle < handRotateInwardThreshold) {
                        hand = .right
                        onChangeCurrentState(.inward)
                    }
                    
                case .inward:
                    if (hand == .left && isThumbLHS() && vertical_angle < handRotateOutwardThreshold) {
                        onChangeCurrentState(.outward)
                        count += 0.5
                        self.checkUpdateDelegate?.didUpdateCountDelegate(Int(count))
                    }
                    else if (hand == .right && isThumbRHS() && vertical_angle < handRotateOutwardThreshold) {
                        onChangeCurrentState(.outward)
                        count += 0.5
                        self.checkUpdateDelegate?.didUpdateCountDelegate(Int(count))
                    }
                    print("state: ^inward")

                case .outward:
                    if (hand == .left && isThumbRHS() && vertical_angle < handRotateInwardThreshold) {
                        if (isHandFront()) {
                            onChangeCurrentState(.inward)
                            count += 0.5
                            self.checkUpdateDelegate?.didUpdateCountDelegate(Int(count))
                        }
                    }
                    else if (hand == .right && isThumbLHS() && vertical_angle < handRotateInwardThreshold) {
                        if (isHandFront()) {
                            onChangeCurrentState(.inward)
                            count += 0.5
                            self.checkUpdateDelegate?.didUpdateCountDelegate(Int(count))
                        }
                    }
                    print("state: ^outward")
                }
            }
            
            print("count: \(count)")
        }
    }
    
    func isThumbLHS() -> Bool {
        if (fingers[0][3].x > wrist.x) {
            return true
        }
        else {
            return false
        }
    }
    
    func isThumbRHS() -> Bool {
        if (fingers[0][3].x < wrist.x) {
            return true
        }
        else {
            return false
        }
    }
}
