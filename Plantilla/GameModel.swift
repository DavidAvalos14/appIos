//
//  GameModel.swift
//  SpaceInvaders0
//
//  Created by Guest User on 05/11/26.
//

import Foundation
import Combine
import CoreMotion

@MainActor
final class GameModel: ObservableObject {
    @Published var shipX: CGFloat = 0.5
    @Published var bullet: CGPoint?
    @Published var alive = Array(repeating: true, count: 5)
    @Published var score = 0
    @Published var paused = false
    @Published var useTild = false
    @Published var sensorAvailable = false
    @Published var audioWarning: String?
    
    private let motion = CMMotionManager()
    private let sound = SoundPlayer()
    private var active = false
    private var lastTime: Date?
    var won: Bool {alive.allSatisfy {!$0}}
    
    func enemyX(_ index: Int)->CGFloat {
        0.15 + CGFloat(index)*0.175
    }
    
    func start(){
        do {
            try sound.prepare()
            audioWarning = nil
        } catch { audioWarning = error.localizedDescription }
        active = true
        lastTime = nil
        sensorAvailable = motion.isAccelerometerAvailable
        if sensorAvailable && !motion.isAccelerometerActive {
            motion.deviceMotionUpdateInterval = 1.0 / 60.0
            motion.startAccelerometerUpdates()
        }
    }
    
    func stop() {
        active = false
        lastTime = nil
        motion.stopAccelerometerUpdates()
        sound.stop()
    }
    
    func move(to x: CGFloat){
        guard active, !paused, !won else{return}
        
        shipX = min(0.94, max(0.06,x))
    }
    
    func fire(){
        guard active, !paused, !won, bullet == nil else {return}
        bullet = CGPoint(x: shipX, y: 0.84)
        sound.play(.shot)
    }
    
    func reset(){
        shipX = 0.5
        bullet = nil
        alive = Array(repeating: true, count: 5)
        score = 0
        paused = false
        lastTime = nil
    }
    
    func togglePause(){
        paused.toggle()
        lastTime = nil
    }
    
}
