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
    @Published var useTilt = false
    @Published var sensorAvailable = false
    @Published var audioWarning: String?

    private let motion = CMMotionManager()
    private let sound = SoundPlayer()
    private var active = false
    private var lastTime: Date?
    @Published private(set) var enemyOffset: CGFloat = 0
    private var enemyDirection: CGFloat = 1
    @Published private var enemyY: CGFloat = 0.14

    var won: Bool { alive.allSatisfy { !$0 } }
    @Published private(set) var gameOver = false
    var finished: Bool { won || gameOver }
    var enemyVerticalPosition: CGFloat { enemyY }

    func enemyX(_ index: Int) -> CGFloat {
        0.15 + CGFloat(index) * 0.175 + enemyOffset
    }

    func start() {
        do {
            try sound.prepare()
            audioWarning = nil
        } catch { audioWarning = error.localizedDescription }
        active = true
        lastTime = nil
        sensorAvailable = motion.isAccelerometerAvailable
        if sensorAvailable && !motion.isAccelerometerActive {
            motion.accelerometerUpdateInterval = 1.0 / 60.0
            motion.startAccelerometerUpdates()
        }
    }

    func stop() {
        active = false
        lastTime = nil
        motion.stopAccelerometerUpdates()
        sound.stop()
    }

    func move(to x: CGFloat) {
        guard active, !paused, !finished else { return }
        shipX = min(0.94, max(0.06, x))
    }

    func fire() {
        guard active, !paused, !finished, bullet == nil else { return }
        bullet = CGPoint(x: shipX, y: 0.84)
        sound.play(.shot)
    }

    func reset() {
        shipX = 0.5
        bullet = nil
        alive = Array(repeating: true, count: 5)
        score = 0
        paused = false
        gameOver = false
        enemyOffset = 0
        enemyDirection = 1
        enemyY = 0.14
        lastTime = nil
    }

    func togglePause() {
        guard active, !finished else { return }
        paused.toggle()
        lastTime = nil
    }

    func tick(_ date: Date) {
        guard active, !paused, !finished else {
            lastTime = date
            return
        }

        guard let lastTime else {
            self.lastTime = date
            return
        }
        let delta = min(date.timeIntervalSince(lastTime), 0.1)
        self.lastTime = date
        guard delta > 0 else { return }

        if useTilt, let acceleration = motion.accelerometerData?.acceleration.x {
            shipX = min(0.94, max(0.06, shipX + CGFloat(acceleration) * CGFloat(delta)))
        }

        moveEnemies(delta: CGFloat(delta))
        moveBullet(delta: CGFloat(delta))
    }

    private func moveEnemies(delta: CGFloat) {
        guard alive.contains(true) else { return }

        let nextOffset = enemyOffset + enemyDirection * 0.12 * delta
        if nextOffset >= 0.08 {
            enemyOffset = 0.08
            enemyDirection = -1
            enemyY += 0.035
        } else if nextOffset <= -0.08 {
            enemyOffset = -0.08
            enemyDirection = 1
            enemyY += 0.035
        } else {
            enemyOffset = nextOffset
        }

        if enemyY >= 0.78 {
            gameOver = true
        }
    }

    private func moveBullet(delta: CGFloat) {
        guard var bullet else { return }
        bullet.y -= 0.7 * delta

        for index in alive.indices where alive[index] {
            if abs(bullet.x - enemyX(index)) <= 0.055,
               abs(bullet.y - enemyY) <= 0.06 {
                alive[index] = false
                score += 10
                self.bullet = nil
                sound.play(.explosion)
                return
            }
        }

        if bullet.y <= 0 {
            self.bullet = nil
        } else {
            self.bullet = bullet
        }
    }
}
