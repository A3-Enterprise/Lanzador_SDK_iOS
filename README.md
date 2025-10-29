# SDK iOS - Guía de Integración

Guía completa para integrar el SDK iOS de ID Factory en tu aplicación para procesos de verificación de identidad y enrollment.

## 📋 Requisitos

- **iOS**: 12.0+
- **Xcode**: 16.2+
- **Swift**: 6.0

## 🚀 Instalación

1. Añadir `AdoComponent.xcframework` en "Frameworks, Libraries and Embedded Content"
2. Configurar como "Embed & Sign"
3. Importar en tu código:

```swift
import UIKit
import AdoComponent
```

## 📦 Implementación

### 1. Configurar el Delegate

Implementa el protocol `SMDelegate` con los 3 handlers:

```swift
extension YourViewController: SMDelegate {
    
    // Handler para Success
    func completedWithResult(result: Bool, response: String?) {
        dismiss(animated: true) {
            print("✅ Success: Proceso completado")
            self.handleSuccess(response: response)
        }
    }
    
    // Handler para Pending
    func completedWithPending(response: String?) {
        dismiss(animated: true) {
            print("⏳ Pending: Requiere aprobación manual")
            self.handlePending(response: response)
        }
    }
    
    // Handler para Failure
    func completedWithFailure(response: String?) {
        dismiss(animated: true) {
            print("❌ Failure: Error en el proceso")
            self.handleFailure(response: response)
        }
    }
}
```

### 2. Iniciar el SDK

```swift
func startVerification() {
    let urlInvitation = "https://enrolldev.idfactory.me/enroll?SubCustomer=TestCustomer&key=abc123"
    let params = SMParams(urlInvitation: urlInvitation)
    
    if let smVC = SMManager.initWith(delegate: self, params: params) as? UIViewController {
        smVC.modalPresentationStyle = .fullScreen
        present(smVC, animated: true, completion: nil)
    }
}
```

### 3. Parsear Respuestas

```swift
private func parseResponse(_ response: String?) -> [String: Any] {
    guard let response = response,
          let data = response.data(using: .utf8),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        return [:]
    }
    return json
}

private func handleSuccess(response: String?) {
    let data = parseResponse(response)
    let csid = data["CSID"] as? String ?? "N/A"
    
    print("CSID: \(csid)")
    // Guardar CSID en tu base de datos
    // Redirigir a pantalla de éxito
}

private func handlePending(response: String?) {
    let data = parseResponse(response)
    let idTransaction = data["idTransaction"] as? String ?? "N/A"
    let csid = data["CSID"] as? String ?? "N/A"
    
    print("Transaction ID: \(idTransaction)")
    // Implementar polling para verificar estado
    // Mostrar mensaje al usuario
}

private func handleFailure(response: String?) {
    let data = parseResponse(response)
    let message = data["message"] as? String ?? "Error desconocido"
    
    print("Error: \(message)")
    
    // Manejar errores específicos
    if message == "Unauthorized" {
        // Token expirado - renovar y reintentar
    } else if message.contains("Invitation key") {
        // Key inválida - generar nueva
    }
}
```

## 📡 Estructura de Respuesta

### Success
```json
{
  "status": "Success",
  "message": "Process completed successfully",
  "CSID": "abc123-def456-ghi789",
  "callback": "https://your-callback-url.com"
}
```

### Pending
```json
{
  "status": "Pending",
  "message": "Manual review required",
  "CSID": "abc123-def456-ghi789",
  "idTransaction": "txn-123456",
  "callback": "https://your-callback-url.com"
}
```

### Failure
```json
{
  "status": "Failure",
  "message": "Unauthorized",
  "CSID": ""
}
```

## 🚨 Mensajes de Error Comunes

| Mensaje | Causa | Solución |
|---------|-------|----------|
| `"Unauthorized"` | Token expirado | Renovar token y reintentar |
| `"Invitation key isn't valid"` | Key inválida/usada | Generar nueva key |
| `"Deny consent"` | Usuario rechazó | Usuario debe aceptar |

## 💡 Ejemplo Completo

```swift
import UIKit
import AdoComponent

class VerificationViewController: UIViewController {
    
    func startVerification(url: String) {
        let params = SMParams(urlInvitation: url)
        
        if let smVC = SMManager.initWith(delegate: self, params: params) as? UIViewController {
            smVC.modalPresentationStyle = .fullScreen
            present(smVC, animated: true)
        }
    }
}

extension VerificationViewController: SMDelegate {
    
    func completedWithResult(result: Bool, response: String?) {
        dismiss(animated: true) {
            let data = self.parseResponse(response)
            let csid = data["CSID"] as? String ?? ""
            
            // Guardar en base de datos
            self.saveVerification(csid: csid)
            
            // Mostrar éxito
            self.showSuccessAlert(csid: csid)
        }
    }
    
    func completedWithPending(response: String?) {
        dismiss(animated: true) {
            let data = self.parseResponse(response)
            let idTransaction = data["idTransaction"] as? String ?? ""
            
            // Iniciar polling
            self.startPolling(transactionId: idTransaction)
            
            // Mostrar mensaje
            self.showPendingAlert(transactionId: idTransaction)
        }
    }
    
    func completedWithFailure(response: String?) {
        dismiss(animated: true) {
            let data = self.parseResponse(response)
            let message = data["message"] as? String ?? "Error"
            
            // Mostrar error
            self.showErrorAlert(message: message)
        }
    }
    
    private func parseResponse(_ response: String?) -> [String: Any] {
        guard let response = response,
              let data = response.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return [:]
        }
        return json
    }
}
```

## 🔄 Polling para Pending

```swift
func startPolling(transactionId: String) {
    Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { timer in
        self.checkTransactionStatus(transactionId: transactionId) { status in
            if status == "Success" {
                timer.invalidate()
                self.showSuccessAlert(csid: "...")
            } else if status == "Failure" {
                timer.invalidate()
                self.showErrorAlert(message: "Proceso rechazado")
            }
        }
    }
}
```

## 📝 Notas Importantes

1. **Todos los handlers son obligatorios** - Debes implementar los 3 métodos
2. **Dismiss automático** - El SDK no cierra la vista, hazlo en el handler
3. **Thread safety** - Los handlers se ejecutan en MainActor (Swift 6)
4. **Parsing** - Siempre valida el JSON antes de usar los datos

## 🔧 Troubleshooting

### SDK no compila
1. Verificar Xcode 16.2+
2. Limpiar proyecto: ⌘ + Shift + K
3. Verificar "Embed & Sign" en el framework

### No se reciben eventos
1. Verificar que implementas los 3 handlers
2. Revisar logs en consola (buscar "📱 iOS SDK:")
3. Verificar URL de invitación válida

## 📞 Soporte

- **Email**: support@idfactory.me
- **Documentación**: https://docs.idfactory.me

---

**Versión SDK**: 2.1  
**Última actualización**: Enero 2025
