//
//  AdministradorPasos.swift
//  ContadorPasos
//
//  Created by Guest User on 27/10/26.
//

import Foundation
import Combine
import CoreMotion

class AdministradorPasos: ObservableObject {
    // Propiedades
    @Published var pasos : Int = 0
    @Published var caminataActiva : Bool = false
    @Published var mensaje : String = "La caminata aún no inicia"
    
    // Objeto para el conteo de pasos
    private let podometro = CMPedometer()
    
    // Para identificar la caminata actual
    private var idCaminata = UUID()
    
    // Funcion iniciar caminata
    func iniciarCaminata() {
        guard !caminataActiva else {
            return
        }
        
        guard CMPedometer.isStepCountingAvailable() else {
            mensaje = "El conteo de pasos no está disponible en este dispositivo"
            return
        }
        
        pasos = 0
        caminataActiva = true
        mensaje = "Esperando el registro de pasos..."
        
        idCaminata = UUID()
        let idActual = idCaminata
        let inicio = Date()
        
        podometro.startUpdates(from: inicio) {
            [weak self] datos, error in
            DispatchQueue.main.async {
                guard let self = self,
                        self.caminataActiva,
                      self.idCaminata == idActual
                else {
                    return
                }
                
                if let error = error {
                    self.mensaje = "No fue posible obtener los pasos " +
                    error.localizedDescription
                    return
                }
                
                if let datos = datos {
                    self.pasos = datos.numberOfSteps.intValue
                    self.mensaje = "Conteo de pasos activo"
                }
            }
        }
    }
    
    // Función detener caminata
    func detenerCaminata() {
        guard caminataActiva else {
            return
        }
    
        caminataActiva = false
        idCaminata = UUID()
        podometro.stopUpdates()
        mensaje = "Caminata detenida"
    }
    
    // Función reiniciar
    func reiniciar()
    {
        detenerCaminata()
        pasos = 0
        mensaje = "La caminata aún no inicia"
    }
}
