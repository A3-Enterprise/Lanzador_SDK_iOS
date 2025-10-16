# Lanzador de ejemplo para integración de AdoComponent.xcframework

El lanzador es un ejemplo de implementación de las librerías necesarias para iniciar el proceso de validación.

## Requisitos

- **iOS**: 12.0+
- **Xcode**: 16.2+
- **Swift**: 5.10+

## Instalación

Primero, añadir la librería "AdoComponent.xcframework" dentro de la configuración general del Target, en la sección denominada como "Frameworks, Libraries and Embedded Content".

Asi mismo se podrán importar las siguientes librerías:

`import UIKit` y
`import AdoComponent`

La librería responde el resultado de la transacción en el delegate SMDelegate.

### Versión mínima del SDK iOS

Cambiar la versión mínima del SDK iOS a iOS 12.0 en la ruta general del Target `Build Settings -> Deployment -> iOS Deployment Target`

## Compatibilidad

### Versión Actual: v2.0
- **Swift**: 5.10 (compatible con Xcode 16.2)
- **Framework**: AdoComponent v2.0
- **Fecha**: Octubre 2024

## Funcionalidades

### Modal de Respuesta
El lanzador incluye un modal que se muestra al recibir la respuesta del SDK con las siguientes opciones:
- **Nueva Invitación**: Limpia los campos y permite lanzar otra invitación
- **Cerrar App**: Cierra completamente la aplicación
- **Cancelar**: Solo cierra el modal

## Ejemplo de Uso

La librería se lanza a partir del método initWith de la clase SMManager, este método recibe un delegate y un objeto SMParams el cual contiene los parámetros de lanzamiento, con una extensión de la clase SMDelegate que va a ser la encargada de recibir la respuesta del SDK:

```swift
func callFaceViewController() {
    let urlString = "https://sandbox.idfactory.me/EnrollSandbox/enroll?SubCustomer=BancoOccidenteSTG&key=9f2c2cbc7f7847f7806678314ed1160b&CallBack=www.cosa.com"
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
            self.showResponseModal(result: result, response: response)
        }
    }
    
    func showResponseModal(result: Bool, response: String?) {
        let title = result ? "✅ Éxito" : "❌ Error"
        let message = response ?? "Sin respuesta del SDK"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Botón para nueva invitación
        alert.addAction(UIAlertAction(title: "Nueva Invitación", style: .default) { _ in
            // Limpiar campos y permitir nueva invitación
            self.textResult.text = ""
            self.resultImage.image = nil
        })
        
        // Botón para cerrar app
        alert.addAction(UIAlertAction(title: "Cerrar App", style: .destructive) { _ in
            exit(0)
        })
        
        // Botón para solo cerrar modal
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
}
```

