//
//  ContentView.swift
//  AtrapaEstrela
//
//  Created by Guest User on 03/11/26.
//

import SwiftUI

struct ContentView: View {
    @State private var puntos = 0
    
    @State private var posX: CGFloat = 0.5
    @State private var posY: CGFloat = 0.5
    
    private let meta = 10
    private let tamañoEstrella: CGFloat = 60
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Atrapa la estrella")
                .font(.largeTitle)
                .bold()
            
            Text("Puntos: \(puntos) / \(meta)")
                .font(.title2)
            
            Text(
                puntos < meta
                ? "Toca la estrella! 🌟"
                : "Ganaste! 🎉"
            )
            .font(.headline)
            
            GeometryReader { espacio in
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue.opacity(0.12))
                    
                    if puntos < meta {
                        Button {
                            atraparEstrella()
                        } label: {
                            Image(systemName: "star.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.orange)
                                .padding(8)
                                .frame(
                                    width: tamañoEstrella,
                                    height: tamañoEstrella
                                )
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .position(
                            x: coordenada(
                                posX,
                                longitud: espacio.size.width
                            ),
                            y: coordenada(
                                posY,
                                longitud: espacio.size.height
                            )
                        )
                        .accessibilityLabel("Atrapar estrela")
                    } else {
                        Text("🌟")
                            .font(.system(size: 80))
                    }
                }
            }
            .frame(height: 350)
            Button("Reiniciar juego"){
                puntos = 0
                posX = 0.5
                posY = 0.5
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    func atraparEstrella() {
        puntos += 1
        
        posX = CGFloat.random(in: 0...1)
        posY = CGFloat.random(in: 0...1)
    }
    
    func coordenada(
        _ proporcion: CGFloat,
        longitud: CGFloat
    ) -> CGFloat {
        let margen = tamañoEstrella / 2
        let espacioDisponible = max(0, longitud - tamañoEstrella)
        
        return margen + proporcion * espacioDisponible
    }
}
