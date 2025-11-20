# IdFactory iOS SDK - Guía de Integración

Guía técnica para desarrolladores que desean integrar el SDK de verificación de identidad de IdFactory en sus aplicaciones iOS.

## 🏗️ Configuración Inicial

### Requisitos del Sistema
- **iOS**: 12.0+
- **Swift**: 5.0+
- **Xcode**: 12.0+
- **Permisos**: Camera, Microphone
- **Hardware**: Cámara frontal y trasera

### Instalación del Framework
```swift
// 1. Agregar AdoComponent.xcframework al proyecto
// 2. En Build Phases > Embed Frameworks, agregar AdoComponent.xcframework
// 3. Configurar "Embed & Sign"

// 4. Importar en tu código
import AdoComponent
```

### Permisos en Info.plist
```xml
<key>NSCameraUsageDescription</key>
<string>Esta app necesita acceso a la cámara para verificación de identidad</string>
<key>NSMicrophoneUsageDescription</key>
<string>Esta app necesita acceso al micrófono para verificación de identidad</string>
```

## 🔧 Implementación del SDK

### 1. Inicialización Básica

#### Método `initWith()` - Integración Simple
```swift
class ViewController: UIViewController {
    
    private func startVerification(invitationUrl: String) {
        let params = SMParams(urlInvitation: invitationUrl)
        let sdkViewController = SMManager.initWith(delegate: self, params: params)
        sdkViewController.modalPresentationStyle = .fullScreen
        present(sdkViewController, animated: true)
    }
}
```

#### Método `startSDKProcess()` - Integración Avanzada con Loader
```swift
private func startSDKProcess(invitationUrl: String) {
    // 1. Mostrar tu loader personalizado
    showCustomLoader()
    
    // 2. Configurar delegate para ocultar loader cuando esté listo
    SMManager.setWebReadyDelegate(self)
    
    // 3. Iniciar SDK
    let params = SMParams(urlInvitation: invitationUrl)
    let sdkViewController = SMManager.initWith(delegate: self, params: params)
    sdkViewController.modalPresentationStyle = .fullScreen
    present(sdkViewController, animated: true)
}

private func showCustomLoader() {
    // Tu implementación de loader personalizado
    let loader = UIActivityIndicatorView(style: .large)
    loader.startAnimating()
    // Agregar a la vista...
}

private func hideCustomLoader() {
    // Ocultar tu loader personalizado
}
```

### 2. Implementar Delegates Obligatorios

#### SMDelegate - Callbacks de Resultado
```swift
extension ViewController: SMDelegate {
    func completedWithResult(result: Bool, response: String?) {
        // ✅ Verificación completada exitosamente
        let csid = parseCSID(response)
        showSuccessMessage("Verificación exitosa", csid: csid)
    }
    
    func completedWithPending(response: String?) {
        // ⏳ Requiere revisión manual
        let transactionId = parseTransactionId(response)
        let csid = parseCSID(response)
        showPendingMessage("Pendiente de revisión", transactionId: transactionId, csid: csid)
    }
    
    func completedWithFailure(response: String?) {
        // ❌ Error en el proceso
        let errorMessage = parseMessage(response)
        showErrorMessage("Error en verificación", error: errorMessage)
    }
}
```

#### SMWebReadyDelegate - Control de Loader
```swift
extension ViewController: SMWebReadyDelegate {
    func webContentReady() {
        print("🍎 iOS: WebContent listo - Ocultando loader personalizado")
        hideCustomLoader()
    }
}
```

### 3. Parsear Respuestas del SDK

```swift
private func parseCSID(_ response: String?) -> String {
    guard let response = response,
          let data = response.data(using: .utf8),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let csid = json["CSID"] as? String else {
        return "N/A"
    }
    return csid
}

private func parseTransactionId(_ response: String?) -> String {
    guard let response = response,
          let data = response.data(using: .utf8),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let transactionId = json["idTransaction"] as? String else {
        return "N/A"
    }
    return transactionId
}

private func parseMessage(_ response: String?) -> String {
    guard let response = response,
          let data = response.data(using: .utf8),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let message = json["message"] as? String else {
        return response ?? "Sin mensaje"
    }
    return message
}
```

## 🎯 Diferencias entre Métodos

### `initWith()` vs `startSDKProcess()`

| Aspecto | `initWith()` | `startSDKProcess()` |
|---------|--------------|---------------------|
| **Uso** | Integración básica | Integración con loader personalizado |
| **Loader** | No incluye | Incluye manejo de loader |
| **Complejidad** | Simple | Avanzado |
| **Control UX** | Limitado | Completo |
| **Recomendado para** | Pruebas rápidas | Producción |

### Cuándo usar cada método:

#### Usar `initWith()` cuando:
- Necesitas una integración rápida
- No requieres loader personalizado
- Estás en fase de pruebas

#### Usar `startSDKProcess()` cuando:
- Quieres controlar la experiencia de usuario
- Necesitas mostrar un loader mientras carga el contenido
- Implementación para producción

## 🔄 Flujo Completo de Integración

### 1. Verificar Permisos
```swift
import AVFoundation

private func hasRequiredPermissions() -> Bool {
    let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
    return cameraStatus == .authorized
}

private func requestCameraPermissions() {
    AVCaptureDevice.requestAccess(for: .video) { granted in
        DispatchQueue.main.async {
            if granted {
                self.startSDKProcess(invitationUrl: self.invitationUrl)
            } else {
                self.showPermissionError()
            }
        }
    }
}
```

### 2. Implementación Completa
```swift
class ViewController: UIViewController {
    private var customLoader: UIActivityIndicatorView?
    private var invitationUrl: String = ""
    
    func initiateVerification(invitationUrl: String) {
        self.invitationUrl = invitationUrl
        
        if !hasRequiredPermissions() {
            requestCameraPermissions()
            return
        }
        startSDKProcess(invitationUrl: invitationUrl)
    }
    
    private func showCustomLoader() {
        customLoader = UIActivityIndicatorView(style: .large)
        customLoader?.color = .systemBlue
        customLoader?.translatesAutoresizingMaskIntoConstraints = false
        
        if let loader = customLoader {
            view.addSubview(loader)
            NSLayoutConstraint.activate([
                loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                loader.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            loader.startAnimating()
        }
    }
    
    private func hideCustomLoader() {
        customLoader?.stopAnimating()
        customLoader?.removeFromSuperview()
        customLoader = nil
    }
}
```

## 📋 Estructura de Respuestas

### Formato de Eventos
Todos los callbacks reciben un JSON con esta estructura:
```json
{
  "status": "Success|Pending|Failure",
  "message": "Descripción del resultado",
  "CSID": "ID único del proceso",
  "idTransaction": "ID de transacción (solo en Pending)"
}
```

### Estados de Respuesta

#### ✅ Success
- **Significado**: Verificación completada y aprobada
- **Acción**: Mostrar mensaje de éxito al usuario
- **Datos**: Incluye CSID para referencia

#### ⏳ Pending
- **Significado**: Requiere revisión manual
- **Acción**: Informar al usuario sobre el tiempo de espera
- **Datos**: Incluye CSID e idTransaction

#### ❌ Failure
- **Significado**: Error en el proceso
- **Acción**: Mostrar error específico y permitir reintento
- **Datos**: Incluye mensaje de error detallado

## ⚠️ Manejo de Errores

### Errores Comunes y Soluciones

| Error | Causa | Solución |
|-------|-------|----------|
| `"Unauthorized"` | Token inválido/expirado | Renovar token de invitación |
| `"Invitation key isn't valid"` | URL inválida/usada/expirada | Generar nueva URL |
| `"Deny consent"` | Usuario rechazó consentimiento | Usuario debe aceptar términos |
| `"No internet connection"` | Pérdida de conectividad | Verificar conexión a internet |
| `"Internal Server Error Liveness"` | Error en detección de vida | Reintentar proceso |

### Manejo de Errores de Permisos
```swift
// Los errores de permisos NO emiten eventos del SDK
// Deben manejarse a nivel de aplicación
if !hasRequiredPermissions() {
    showPermissionAlert()
    return
}
```

## 🔍 Debugging y Testing

### Logs del SDK
En modo debug, el SDK emite logs detallados:
```swift
// Logs automáticos en desarrollo
print("🍎 iOS SDK: Evento recibido: \(eventData)")
```

### URLs de Testing
- **Sandbox**: `https://sandbox.idfactory.com/invitation/...`
- **Producción**: `https://app.idfactory.com/invitation/...`

### Safari Web Inspector
1. Conecta dispositivo iOS
2. Abre Safari > Develop > [Device] > [App]
3. Inspecciona contenido web del SDK

## 📞 Soporte Técnico

### Información para Soporte
Cuando contactes soporte, incluye:
- **CSID**: ID único del proceso
- **idTransaction**: ID de transacción (si aplica)
- **Logs**: Logs del SDK en modo debug
- **URL**: URL de invitación utilizada
- **iOS Version**: Versión del sistema operativo

### Contacto
- **Email Técnico**: dev-support@idfactory.com
- **Documentación**: [docs.idfactory.com](https://docs.idfactory.com)
- **Status Page**: [status.idfactory.com](https://status.idfactory.com)

---

**SDK Versión**: 1.0.49  
**Guía Versión**: 3.0  
**Última actualización**: Noviembre 2024  
**Compatibilidad**: iOS 12.0+ (iPhone 6s+)