//
//  ContentView.swift
//  Plantilla
//
//  Created by Guest User on 03/11/26.
//

// App Space Invaders

import SwiftUI
import Combine

@MainActor
struct ContentView: View {
    @StateObject private var game = GameModel()
    @Environment(\.scenePhase) private var phase
    private let clock = Timer.publish(every: 1.0 / 60.0,
        on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 12) {
            Text("SPACE INVADERS").font(.title2.bold())
            Text("Puntos: \(game.score)")
            Toggle("Mover por inclinación", isOn: $game.useTilt)
                .disabled(!game.sensorAvailable)
            if let warning = game.audioWarning {
                Text("Audio: \(warning)")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            board
            HStack {
                Button("Disparar") { game.fire() }
                    .disabled(game.paused || game.finished)
                Button(game.paused ? "Continuar" : "Pausa") {
                    game.togglePause()
                }.disabled(game.finished)
                Button("Reiniciar") { game.reset() }
            }.buttonStyle(.bordered)
            Text(game.useTilt && game.sensorAvailable
                 ? "Inclina el iPhone y toca para disparar."
                 : "Arrastra para moverte y toca para disparar.")
                .font(.caption)
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
                        .resizable()
                        .scaledToFill()
                        .frame(width: w, height: h)
                    ForEach(0..<5, id: \.self) { i in
                        if game.alive[i] {
                            Image("badship2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: w * 0.12,
                                       height: h * 0.08)
                                .position(x: game.enemyX(i) * w,
                                          y: game.enemyVerticalPosition * h)
                        }
                    }
                    Image("spaceship2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: w * 0.18, height: h * 0.10)
                        .position(x: game.shipX * w, y: h * 0.90)
                    if let bullet = game.bullet {
                        Image("shot")
                            .resizable()
                            .scaledToFit()
                            .frame(width: w * 0.025,
                                   height: h * 0.07)
                            .position(x: bullet.x * w,
                                      y: bullet.y * h)
                    }
                    if game.finished || game.paused {
                        Text(game.won ? "¡Ganaste!" : game.gameOver ? "¡Perdiste!" : "En pausa")
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
