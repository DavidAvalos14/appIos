//
//  ContentView.swift
//  ContadorPasos
//
//  Created by Guest User on 27/10/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var contador = AdministradorPasos()
    @State private var longitudPasosText : String = "70"
    @FocusState private var capturandoLongitud: Bool
    
    // Convertimos el texto a numero
    private var longitudPaso : Double? {
        let texto = longitudPasosText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard let valor = Double(texto),
              valor.isFinite,
              valor > 0,
              valor <= 200
        else {
            return nil
        }
        return valor
    }
    
    // Calcular la distancia en kilometros
    private var distanciaKilometros : Double {
        guard let longitud = longitudPaso else {
            return 0
        }
        
        return Double(contador.pasos) * longitud / 100_000
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 65))
                        .foregroundStyle(.blue)
                    
                    Text("Registra tus pasos")
                        .font(.title2)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    
                    // Captura de la longitud de paso
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Longitud de un paso")
                            .font(.headline)
                        HStack {
                            TextField("Ejemplo: 70", text: $longitudPasosText)
                                .keyboardType(.decimalPad)
                                .focused($capturandoLongitud)
                                .textFieldStyle(.roundedBorder)
                            
                            Text("cm")
                                .fontWeight(.medium)
                        }
                        Text("Captura un valor mayor que 0 y de hasta 200")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        if longitudPaso == nil {
                            Text("Introduce una longitud válida")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                    .padding()
                    .background(
                        Color.gray.opacity(0.12),
                        in: RoundedRectangle(cornerRadius: 12))
                    // Resultados
                    VStack(spacing: 8) {
                        Text("Resultados de la caminata")
                            .font(.headline)
                        HStack {
                            Text("Pasos:")
                            Spacer()
                            Text("\(contador.pasos)")
                                .font(.title2)
                                .fontWeight(.bold)
                        }

                        HStack {
                            Text("Distancia estimada")
                            Spacer()
                            if longitudPaso != nil {
                                Text(
                                    distanciaKilometros,
                                    format: .number
                                        .precision(.fractionLength(3))
                                )
                                .fontWeight(.bold)
                                Text("km")
                            } else {
                                Text("--")
                            }
                        }
                        Text(contador.mensaje)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))

                    // Botones
                    HStack(spacing: 12) {
                        Button("Iniciar") {
                            capturandoLongitud = false
                            contador.iniciarCaminata()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(contador.caminataActiva || longitudPaso == nil)

                        Button("Detener") {
                            contador.detenerCaminata()
                        }
                        .buttonStyle(.bordered)
                        .disabled(!contador.caminataActiva)

                        Button("Reiniciar") {
                            contador.reiniciar()
                        }
                        .buttonStyle(.bordered)
                    }

                    Text("La distancia se estima con los pasos y la longitud capturada")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            .navigationTitle("Mis pasos")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Listo") {
                        capturandoLongitud = false
                    }
                }
            }
        }
    }
}
