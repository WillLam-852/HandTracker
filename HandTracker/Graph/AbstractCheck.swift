//
//  AbstractCheck.swift
//  HandTracker
//
//  Created by hkuit155 on 22/8/2022.
//

import Foundation

protocol AbstractCheckDelegate: AnyObject {
    
    func didUpdateCountDelegate(_ count: Int)
    
    func didUpdateStateDelegate(_ state: String)
    
    func didUpdateCalibrationStateDelegate(_ state: String)
}

//----------------------------------------------------------------------------------------------------------------------------------//

class AbstractCheck {

    var landmarks: [Landmark]!
    var fingers: [[Landmark]]! = []
    var wrist = Landmark()
    
    weak var checkUpdateDelegate: AbstractCheckDelegate?

    var count:Float = 0
    var fingerSpreadAngleThreshold:[[Float]]
    var fingerClingeAngleThreshold:Float
    var handFrontThreshold:Float
    var handSideLowerThreshold:Float
    var handSideUpperThreshold:Float
    var cameraHorizontalThreshold:Float
    var upperCenterThreshold:Float
    var lowerCenterThreshold:Float
    var calibrationState = CalibrationState.perfect
    
    init() {
        fingerSpreadAngleThreshold = [[145, 145, 145], [100, 145, 145], [100, 145, 145], [100, 145, 145], [100, 145, 145]]
        fingerClingeAngleThreshold = 10
        handFrontThreshold = 0.1
        handSideUpperThreshold = 0.4
        handSideLowerThreshold = 0.2
        cameraHorizontalThreshold = 0.15
        upperCenterThreshold = 0.2
        lowerCenterThreshold = 0.65
    }
    
    enum CalibrationState {
        case perfect, center, spread, fold ,front, side, horizontal, clinge, thumb, pinky
    }
    
    func onChangeCalibrationState(_ state: CalibrationState) {
        if (calibrationState != state) {
            calibrationState = state
            
            switch(calibrationState) {
                
            case .perfect:
                self.checkUpdateDelegate?.didUpdateCalibrationStateDelegate("")
            case .center:
                self.checkUpdateDelegate?.didUpdateCalibrationStateDelegate("NOT IN CENTER")
            case .spread:
                self.checkUpdateDelegate?.didUpdateCalibrationStateDelegate("FINGERS NOT SPREAD")
            case .fold:
                self.checkUpdateDelegate?.didUpdateCalibrationStateDelegate("FINGER IS FOLD")
            case .front:
                self.checkUpdateDelegate?.didUpdateCalibrationStateDelegate("HAND IS TILT")
            case .clinge:
                self.checkUpdateDelegate?.didUpdateCalibrationStateDelegate("FINGERS ARE NOT CLINGING")
            case .side:
                self.checkUpdateDelegate?.didUpdateCalibrationStateDelegate("HAND IS TILT")
            case .thumb:
                self.checkUpdateDelegate?.didUpdateCalibrationStateDelegate("THUMB WRONG SIDE")
            case .pinky:
                self.checkUpdateDelegate?.didUpdateCalibrationStateDelegate("PINKY WRONG SIDE")
            case .horizontal:
                self.checkUpdateDelegate?.didUpdateCalibrationStateDelegate("ANGLE OF SHOT TOO LARGE")

            }
        }
    }

    
    func check(_ landmarks: [Landmark]!) {
        self.landmarks = landmarks

        wrist = landmarks[0]

        //finger elements: mcp, pip, dip, tip ** for thunb: cmc, mcp, ip, tip
        fingers = []
        let thumb = [landmarks[1], landmarks[2], landmarks[3], landmarks[4]]
        let index = [landmarks[5], landmarks[6], landmarks[7], landmarks[8]]
        let middle = [landmarks[9], landmarks[10], landmarks[11], landmarks[12]]
        let ring = [landmarks[13], landmarks[14], landmarks[15], landmarks[16]]
        let pinky = [landmarks[17], landmarks[18], landmarks[19], landmarks[20]]
        
        fingers.append(thumb)
        fingers.append(index)
        fingers.append(middle)
        fingers.append(ring)
        fingers.append(pinky)

    }
    
//----------------------------------------------------------------------------------------------------------------------------------//

    func isFingerSpread(_ from:Int = 0, _ til:Int = 4) -> Bool {
        
        for i in from...til {
            
            let finger_angle_1 = cal_angle(fingers[i][0], wrist, fingers[i][1])
            let finger_angle_2 = cal_angle(fingers[i][1], fingers[i][0], fingers[i][2])
            let finger_angle_3 = cal_angle(fingers[i][2], fingers[i][1], fingers[i][3])
            
            if (finger_angle_1 < fingerSpreadAngleThreshold[i][0] ||  finger_angle_2 < fingerSpreadAngleThreshold[i][1] ||  finger_angle_3 < fingerSpreadAngleThreshold[i][2]) {

                print("Not spread: \(i)")
                print(finger_angle_1)
                print(finger_angle_2)
                print(finger_angle_3)
                onChangeCalibrationState(.spread)
                return false
            }
        }
        onChangeCalibrationState(.perfect)
        print("All spread")
        return true
    }
    
    func isFingerUp(_ from:Int = 1, _ til:Int = 4) -> Bool {
        
        for i in from...til {
            if (fingers[i][3].y > fingers[i][2].y) {
                print("Not up: \(i)")
                return false
            }
        }
        
        print("All up")
        return true
    }
        
    
    func isFingerNOTFold(_ from:Int = 0, _ til:Int = 4) -> Bool {
        
        for i in from...til {
            
            if (i==0) {
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
                onChangeCalibrationState(.fold)
                return false
            }
            
        }
        onChangeCalibrationState(.perfect)
        print("is NOT fold")
        return true
        
    }
    
    func isFingerClinging(_ remove:Int = 5) -> Bool {

        for i in 0...3 where i != remove{
            let thumb_index_angle = cal_angle_by_4_points(fingers[i][1], fingers[i][3], fingers[i+1][0], fingers[i][3])
            let fingers_angle = cal_angle_by_4_points(fingers[i][0], fingers[i][2], fingers[i+1][0], fingers[i+1][2])
            
            if (i == 0) {
                if ( thumb_index_angle > fingerClingeAngleThreshold) {
                    print("Not clinged: \(i), \(i+1)")
                    return false
                }
            }
            else if ( fingers_angle > fingerClingeAngleThreshold) {
                print("Not clinged: \(i), \(i+1): \(fingers_angle)")
                onChangeCalibrationState(.clinge)
                return false
            }
        }
        
        onChangeCalibrationState(.perfect)
        print("Clinged")
        return true
    }
    
    func isHandFront() -> Bool {
        
        let slope = abs(cal_slope(fingers[1][0], fingers[2][0]))
        if ( slope <= handFrontThreshold) {
            print("Front")
            onChangeCalibrationState(.perfect)
            return true
        }
        else {
            print("Tilt: \(slope)")
            onChangeCalibrationState(.front)
            return false
        }
    }
    
    func isHandSide(_ pt1:Int = 1, _ pt2:Int = 2) -> Bool {
        
        let slope = abs(cal_slope(fingers[pt1][0], fingers[pt2][0]))
        if (slope >= handSideLowerThreshold && slope <= handSideUpperThreshold) {
            print("Side")
            onChangeCalibrationState(.perfect)
            return true
        }
        else {
            print("Tilt: \(slope)")
            onChangeCalibrationState(.front)
            return false
        }
    }
    
    func isCameraHorizontal() -> Bool {
        print(abs(fingers[2][3].z))
        if (abs(fingers[2][3].z) < cameraHorizontalThreshold) {
            onChangeCalibrationState(.horizontal)
            return false
        }
        else {
            onChangeCalibrationState(.perfect)
            return true
        }
    }
    
    func isHandAtCenter() -> Bool {
        if (wrist.y < upperCenterThreshold || wrist.y > lowerCenterThreshold) {
            print("Not at center: \(wrist.y)")
            onChangeCalibrationState(.center)
            return false
        }
        else {
            onChangeCalibrationState(.perfect)
            print("Center")
            return true
        }
    }
    
    func isThumbCloser() -> Bool {
        if (fingers[0][1].z > fingers[4][0].z) {
            print("Thumb should be closer to camera")
            onChangeCalibrationState(.thumb)
            return false
        }
        
        onChangeCalibrationState(.perfect)
        print("Thumb position right")
        return true
    }
    
    func isPinkyCloser() -> Bool {
        if (fingers[0][1].z < fingers[4][0].z) {
            print("Pinky should be closer to camera")
            onChangeCalibrationState(.pinky)
            return false
        }
        
        onChangeCalibrationState(.perfect)
        print("Pinky position right")
        return true
    }
    
//----------------------------------------------------------------------------------------------------------------------------------//
    
    func cal_dist (_ pt1: Landmark!, _ pt2: Landmark!) -> Float {
        
        let dist = pow(pt1.x-pt2.x, 2) + pow(pt1.y-pt2.y, 2) + pow(pt1.z-pt2.z, 2)
        
        return sqrt(dist)
    }
    

    func cal_ratio_x(_ pt1: Landmark!, _ pt2: Landmark!) -> Float {

        let dist = cal_dist(pt1, pt2)
        let dist_x = abs(pt1.x - pt2.x)

        return dist_x / dist
    }
    
    func cal_ratio_y(_ pt1: Landmark!, _ pt2: Landmark!) -> Float {

        let dist = cal_dist(pt1, pt2)
        let dist_y = abs(pt1.y - pt2.y)

        return dist_y / dist
    }
    
    func cal_ratio_z(_ pt1: Landmark!, _ pt2: Landmark!) -> Float {

        let dist = cal_dist(pt1, pt2)
        let dist_z = abs(pt1.z - pt2.z)

        return dist_z / dist
    }
    
    func cal_slope(_ pt1: Landmark!, _ pt2: Landmark!) -> Float {
        
        return (pt1.y-pt2.y) / (pt1.x-pt2.x)
    }
    
    func cal_angle(_ center: Landmark!, _ pt1: Landmark!, _ pt2: Landmark!, _ minus: Bool = true) -> Float {
        
        let dist_a = cal_dist(pt1, center)
        let dist_b = cal_dist(pt2, center)
        let dist_c = cal_dist(pt1, pt2)
        
        let heron = (pow(dist_c, 2)-pow(dist_a, 2)-pow(dist_b, 2)) / (2*dist_a*dist_b)
        
        //print("angle: \(acos(heron) * (180/Float.pi))")
        if (minus) {
            return 180-acos(heron) * (180/Float.pi)
        }
        else {
            return acos(heron) * (180/Float.pi)
        }
    }
    
    func cal_angle_by_4_points(_ pt1: Landmark!, _ pt2: Landmark!, _ pt3: Landmark!, _ pt4: Landmark!) -> Float {
        
            let slope_1 = cal_slope(pt1, pt2)
            let slope_2 = cal_slope(pt3, pt4)

    //        print("slope 1: \(slope_1)")
    //        print("slope 2: \(slope_2)")

            let tan = (slope_1-slope_2) / (1+slope_1*slope_2)
            
            return abs(atan(tan) * (180/Float.pi))
    }
    
}


