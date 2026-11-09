//
//  ContentView.swift
//  SpaceInvaders0
//
//  Created by Lina Arias on 05/11/26.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var game = GameModel()
    @Environment(\.scenePhase) private var phase
    private let clock = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack (spacing: 12){
            Text("SPACE INVADERS")
                .font(.title2.bold())
            Text("Score: \(game.score)")
            Toggle("Motion by tilt",isOn: $game.useTilt)
                .disabled(!game.sensorAvailable)
            board
            HStack {
                Button("Fire") { game.fire() }
                    .disabled(game.paused || game.won)
                Button(game.paused ? "Continue" : "Pause") {
                    game.togglePause()
                }.disabled(game.won)
                Button("Reboot") { game.reset() }
            }.buttonStyle(.bordered)
            Text(game.useTilt && game.sensorAvailable
                 ? "Tilt the iPhone and touch Fire."
                 : "Drag for move and touch for fire.")
                .font(.caption)
            if let warning = game.audioWarning {
                Text(warning)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding()
        .background(Color.black)
        .foregroundStyle(.white)
        .preferredColorScheme(.dark)
        .onAppear { if phase == .active { game.start() } }
        .onDisappear { game.stop() }
        .onChange(of: phase) { newPhase in
            if newPhase == .active { game.start() }
            else { game.stop() }
        }
        .onReceive(clock) { game.tick($0) }
    }
    private var board: some View {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                ZStack {
                    Image("universe2")
                        .resizable().scaledToFit()
                        .frame(width: w, height: h)
                    ForEach(0..<5,id: \.self){ i in
                        if game.alive[i]{
                            Image("badship2")
                                .resizable().scaledToFit()
                                .frame(width: w * 0.10,
                                       height: h * 0.07)
                                .position(x: game.enemyX(i) * w,
                                          y: h * 0.14)
                        }
                    }
                    Image("spaceship2")
                        .resizable().scaledToFit()
                        .frame(width: w * 0.12,
                               height: h * 0.08)
                        .position(x: game.shipX * w,
                              y: h * 0.90)
                        
                    if let bullet = game.bullet {
                        Image("shot").resizable().scaledToFit()
                            .frame(width: w * 0.02,
                                   height: h * 0.04)
                            .position(x: bullet.x * w,
                                      y: bullet.y * h)
                    }
                    if game.won || game.paused {
                        Text(game.won ? "¡You win!" : "Paused")
                            .font(.largeTitle.bold())
                            .padding().background(Color.black.opacity(0.8))
                    }
                }
                .clipped()
                .contentShape(Rectangle())
                .onTapGesture { game.fire() }
                .gesture(DragGesture(minimumDistance: 8)
                    .onChanged { value in
                        if !game.useTilt || !game.sensorAvailable {
                            game.move(to: value.location.x / w)
                        }
                    })
            }
        }
    }
    
#Preview {
    ContentView()
}
