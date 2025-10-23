# SDK iOS - Aplicación de Ejemplo

## Descripción
Aplicación de ejemplo que demuestra la integración del SDK iOS de AdoComponent para procesos de verificación de identidad y enrollment.

## Características del SDK

### ✅ Comunicación Dual
- **Eventos JavaScript**: Comunicación en tiempo real via `genieEventGeneral`
- **URL Redirect**: Fallback automático para compatibilidad

### ✅ Métodos de Respuesta
- **`completedWithResult(result: Bool, response: String?)`**: Método principal
  - `result: true` → Success y Pending
  - `result: false` → Failure (solo si no implementa completedWithFailure)
- **`completedWithFailure(response: String?)`**: Método moderno para errores
  - Maneja Failure y Failure-liveness

### ✅ Status Soportados
- **`Success`**: Proceso completado exitosamente
- **`Pending`**: Proceso pendiente de aprobación (requiere polling)
- **`Failure`**: Error general en el proceso
- **`Failure-liveness`**: Error específico de liveness

## Requisitos

- **iOS**: 12.0+
- **Xcode**: 16.2+
- **Swift**: 6.0

## Instalación

1. Añadir la librería "AdoComponent.xcframework" en "Frameworks, Libraries and Embedded Content"
2. Importar las librerías necesarias:
```swift
import UIKit
import AdoComponent
```

## Implementación

### Configuración del Delegate

```swift
// MARK: - SMDelegate
extension TestViewController: SMDelegate {
    
    // Método principal - Success y Pending
    func completedWithResult(result: Bool, response: String?) {
        if result {
            // Success o Pending
            handleSuccessResponse(response: response)
        } else {
            // Failure (fallback legacy)
            handleFailureResponse(response: response)
        }
    }
    
    // Método moderno - Failure y Failure-liveness
    func completedWithFailure(response: String?) {
        handleFailureResponse(response: response)
    }
}
```

### Parseo de Respuesta

```swift
private func parseResponse(_ response: String?) -> [String: Any] {
    guard let response = response,
          let data = response.data(using: .utf8),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        return [:]
    }
    return json
}
```

### Manejo por Status

```swift
let status = responseData["status"] as? String ?? "Success"

switch status {
case "Success":
    // Proceso completado exitosamente
    break
case "Pending":
    // Proceso pendiente - implementar polling
    break
case "Failure":
    // Error general
    break
case "Failure-liveness":
    // Error específico de liveness
    break
}
```

## Uso

1. **Configurar URL**: Ingresa la URL de invitación en el campo de texto
2. **Iniciar Proceso**: Presiona el botón para iniciar la verificación
3. **Manejar Respuesta**: El SDK llamará automáticamente al método apropiado

### Ejemplos de URL

**Enrollment:**
```
https://enrolldev.idfactory.me/enroll?SubCustomer=TestCustomer&key=abc123
```

**Verificación:**
```
https://enrolldev.idfactory.me/verify?SubCustomer=TestCustomer&key=xyz789
```

## Estructura de Respuesta

```json
{
  "status": "Success|Pending|Failure|Failure-liveness",
  "message": "Mensaje descriptivo",
  "CSID": "ID de la sesión",
  "token": "Token actualizado",
  "callback": "URL de callback (opcional)",
  "idTransaction": "ID de transacción (para Pending)"
}
```

## Logs de Debug

El SDK incluye logs detallados para debugging:

```
📱 iOS SDK: Respuesta obtenida via JavaScript Event
📱 iOS SDK: Status SUCCESS/PENDING detectado - Status: Success
📱 iOS SDK: Usando completedWithResult(true) - Método principal
```

## Compatibilidad

### Versión Actual: v2.1 ✅
- **Swift**: 6.0 (Xcode 16.2+)
- **Framework**: AdoComponent v2.1 (Swift 6.0)
- **Concurrency**: Compatible con @MainActor (SMDelegate)
- **Estado**: Compilado y funcionando correctamente
- **Fecha**: Enero 2025

### Características de Compatibilidad
- ✅ **Retrocompatible**: Funciona con implementaciones existentes
- ✅ **Dual Communication**: JavaScript events + URL redirect fallback
- ✅ **Flexible**: Implementa solo `completedWithResult` o ambos métodos

## Funcionalidades del Lanzador

### Modal de Respuesta Mejorado
- **Ver Respuesta Completa**: Muestra el JSON completo del SDK
- **Nueva Invitación**: Limpia los campos para otra prueba
- **Cerrar**: Cierra el modal

### Swift 6 Concurrency
```swift
extension TestViewController: SMDelegate {
    // Método automáticamente ejecutado en MainActor
    func completedWithResult(result: Bool, response: String?) {
        // Seguro actualizar UI directamente
    }
}
```

## Ejemplo Completo

```swift
func callFaceViewController() {
    let urlString = "https://enrolldev.idfactory.me/enroll?SubCustomer=TestCustomer&key=abc123"
    let params = SMParams(urlInvitation: urlString)
    
    if let smVC = SMManager.initWith(delegate: self, params: params) as? UIViewController {
        smVC.modalPresentationStyle = .fullScreen
        present(smVC, animated: true, completion: nil)
    }
}

// MARK: - SMDelegate
extension TestViewController: SMDelegate {
    
    func completedWithResult(result: Bool, response: String?) {
        dismiss(animated: true) {
            print("📱 iOS Lanzador: completedWithResult - result: \(result)")
            
            if result {
                self.handleSuccessResponse(response: response)
            } else {
                self.handleFailureResponse(response: response, source: "Legacy Method")
            }
        }
    }
    
    func completedWithFailure(response: String?) {
        dismiss(animated: true) {
            print("📱 iOS Lanzador: completedWithFailure llamado")
            self.handleFailureResponse(response: response, source: "Modern Method")
        }
    }
}
```

## Notas Importantes

- El método `completedWithFailure` es **opcional**
- Si no se implementa, los errores van por `completedWithResult(result: false)`
- El SDK detecta automáticamente qué métodos están implementados
- Los logs ayudan a identificar el origen de cada respuesta

### Dependencias
- **NO instalar** Alamofire o SocketIO por separado
- Las dependencias están embebidas en AdoComponent.xcframework
- Usar solo "Embed & Sign" para el framework

## Troubleshooting

### Error de Compilación
1. Verificar Xcode 16.2+
2. Limpiar proyecto: ⌘ + Shift + K
3. Eliminar DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData`
4. Verificar "Embed & Sign" en el framework

### Verificar Integración
```swift
import AdoComponent

class TestClass {
    func test() {
        let params = SMParams(urlInvitation: "test")
        print("SDK integrado correctamente")
    }
}
```

## Soporte

Para más información, consultar el README del SDK en `/SDK_iOS/README.md`