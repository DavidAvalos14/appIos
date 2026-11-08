//
//  SoundPlayer.swift
//  SpaceInvaders0
//
//  Created by Guest User on 05/11/26.
//

import Foundation
import AVFoundation

final class SoundPlayer {
    enum Effect {case shot, explosion}
    private var shotPlayer: AVAudioPlayer?
    private var explosionPlayer: AVAudioPlayer?
    
    func prepare() throws {
        try AVAudioSession.sharedInstance().setCategory(.ambient)
        if shotPlayer == nil {
            shotPlayer = try load("disparo", ext: "wav")
        }
        if explosionPlayer == nil {
            explosionPlayer = try load("explosion", ext:"mp3")
        }
    }
    private func load(_ name: String, ext: String) throws -> AVAudioPlayer {
        guard let url = Bundle.main.url(
            forResource: name,
            withExtension: ext
        ) else {
            throw NSError(domain: "SpaceInvadersAudio", code: 1, userInfo: [NSLocalizedDescriptionKey: "No se encontró \(name).\(ext) en la app"])
        }
        let player = try AVAudioPlayer(contentsOf: url)
        player.volume = 0.7
        player.prepareToPlay()
        return player
    }
    func play (_ effect: Effect){
        let player: AVAudioPlayer?
        switch effect {
        case .shot: player = shotPlayer
        case .explosion: player = explosionPlayer
        }
        player?.stop()
        player?.currentTime = 0
        player?.play()
    }
    func stop(){
        shotPlayer?.stop()
        explosionPlayer?.stop()
    }
}
