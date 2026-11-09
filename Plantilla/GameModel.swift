//
//  GameModel.swift
//  SpaceInvaders0
//
//  Created by Lina Arias on 05/11/26.
//

import SwiftUI
import Combine
import CoreMotion

@MainActor
final class GameModel: ObservableObject {
    @Published var shipX: CGFloat = 0.5
    @Published var bullet: CGPoint?
    @Published var alive = Array(repeating: true, count: 5)
    @Published var score = 0
    @Published var paused = false
    @Published var useTilt = false
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
        sensorAvailable = motion.isAccelerometerActive
        if sensorAvailable && !motion.isAccelerometerActive {
            motion.accelerometerUpdateInterval = 1.0 / 60.0
            motion.startAccelerometerUpdates()
        }
    }
    
    func stop(){
        active = false
        lastTime = nil
        motion.stopAccelerometerUpdates()
        sound.stop()
    }
    
    func move(to x: CGFloat){
        guard active, !paused, !won else {return}
        
        shipX = min(0.94,max(0.06,x))
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
    
    /* actualizar la bala y resolver impactos
     dt: tiempo transcurrido, limitado a 0.05 segundos
     bullet: sube 0.9 en la altura del campo por segundo
     path: cubre su trayecto entre actualizaciones para detectar impactos
     cada enemigo aporta 10 puntos una sola vez
     Si la bala sale del campo, se cambia a nil y se permite disparar otra vez.
     */
    func tick(_ now: Date){
        guard active, !paused, !won else {
            lastTime = nil
            return
        }
        let elapsed = now.timeIntervalSince(lastTime ?? now)
        let dt = CGFloat(min(0.05,max(0,elapsed)))
        lastTime = now
        if useTilt, let data = motion.accelerometerData {
            move(to: 0.5 + CGFloat(data.acceleration.x)*1.5)
        }
        guard var point = bullet else { return }
        let oldY = point.y
        point.y = 0.9*dt
        let path = CGRect(x: point.x - 0.01,
                          y:point.y - 0.02,
                          width: 0.02,
                          height: oldY - point.y + 0.04)
        for i in alive.indices where alive[i]{
            let target = CGRect(x: enemyX(i) - 0.05,
                                y:0.105,
                                width: 0.10,
                                height: 0.07)
            if path.intersects(target) {
                alive[i] = false
                score += 10
                bullet = nil
                sound.play(.explosion)
                return
            }
        }
        bullet = point.y < -0.02 ? nil : point
    }
}
