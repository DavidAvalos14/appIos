import Foundation
import AVFoundation

final class SoundPlayer {
    private var player: AVAudioPlayer?

    func play(frequency: Double) {
        let rate = 22050
        let count = rate / 8
        var data = Data()
        func text(_ value: String) {
            data.append(contentsOf: value.utf8)
        }
        func number(_ value: Int, bytes: Int) {
            for i in 0..<bytes {
                data.append(UInt8((value >> (8 * i)) & 255))
            }
        }
        // Cabecera WAV: PCM mono de 16 bits.
        text("RIFF"); number(36 + count * 2, bytes: 4)
        text("WAVEfmt "); number(16, bytes: 4)
        number(1, bytes: 2); number(1, bytes: 2)
        number(rate, bytes: 4); number(rate * 2, bytes: 4)
        number(2, bytes: 2); number(16, bytes: 2)
        text("data"); number(count * 2, bytes: 4)
        for i in 0..<count {
            let time = Double(i) / Double(rate)
            let fade = 1 - Double(i) / Double(count)
            let wave = sin(2 * Double.pi * frequency * time)
            let sample = Int16(wave * fade * 8000)
            number(Int(UInt16(bitPattern: sample)), bytes: 2)
        }
        do {
            try AVAudioSession.sharedInstance()
                .setCategory(.ambient)
            player = try AVAudioPlayer(data: data)
            player?.play()
        } catch {
            print("No se pudo reproducir el tono: \(error)")
        }
    }
    func stop() { player?.stop() }
}