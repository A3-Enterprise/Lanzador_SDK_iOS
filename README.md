# Lanzador de ejemplo para integración de la libreria SMSDK.framework

El lanzador es un ejemplo de implementación de las librerias necesarias para iniciar el proceso de validación.

## Instalación

Primero, añadir la librería "SMSDK.xcframework" dentro de la configuración general del Target, en la seccion de nominada como "Frameworks, Libraries and Embedded Content".


Asi mismo se podrán importar las siguientes librerías.

`import UIKit` y
`import AdoComponent`


La librería responde el resultado de la transacción en un objeto llamado TransactionResponse

### Version minima del SDK iOS

Cambiar la versión minima del SDK iOS a iOS 11.0 en la ruta general del Target `Build Settings -> Deployment -> iOS Deployment Target`

### Ejemplo

La libreria se lanza a partir del metodo initWith de la clase SMmanager, este metodo recibe un delegate y un objeto SMParams el cual contiene los parametros de lanzamiento, con una extension de la clase SMDelegate que va a ser la encargada de recibir la respuesta del SDK como se puede ver en el siguiente ejemplo

            let params = SMParams(
                                urlInvitation: "https://sandbox.idfactory.me/EnrollSandbox/enroll?SubCustomer=BancoOccidenteSTG&key=9f2c2cbc7f7847f7806678314ed1160b&CallBack=www.cosa.com",
            let smManagerVC = SMManager.initWith(delegate: self, params: params)
                smManagerVC.modalPresentationStyle = .fullScreen
                present(smManagerVC, animated: true, completion: nil)


    //MARK:- SMDelegate
    extension ViewController: SMDelegate {
        func completedWithResult(result: Bool, response: String?) {
            dismiss(animated: true) {

                //Respuesta las salidas del SDK
            }
        }
    }

