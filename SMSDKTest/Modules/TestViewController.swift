import UIKit
import AdoComponent

class TestViewController: UIViewController {
    
    @IBOutlet weak var resultImage: UIImageView!
    var smManagerVC: SMManager?

    @IBOutlet weak var urlInit: UITextField!
    @IBOutlet weak var textResult: UITextView!

    
    //MARK: Functions
    func callFaceViewController(documentType: String) {

        if let urlString = urlInit.text, !urlString.isEmpty {
            let params = SMParams(urlInvitation: urlString)

            let smVC = SMManager.initWith(delegate: self, params: params)
            smVC.modalPresentationStyle = .fullScreen
            present(smVC, animated: true, completion: nil)
        } else {
            showAlert(title: "Error", message: "Por favor ingrese una URL válida.")
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    //MARK: Actions
    @IBAction func citizenshipIDAction(_ sender: UIButton) {
        callFaceViewController(documentType: "1")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Reinitialize the camera if SMManager instance already exists
        if smManagerVC != nil {
            callFaceViewController(documentType: "1")
        }
    }
}

//MARK:- SMDelegate
extension TestViewController: SMDelegate {
    
    // MÉTODO PRINCIPAL - Para Success y Pending (también legacy)
    func completedWithResult(result: Bool, response: String?) {
        dismiss(animated: true) {
            print("📱 iOS Lanzador: completedWithResult llamado - result: \(result)")
            
            if result {
                // Success o Pending
                self.handleSuccessResponse(response: response)
            } else {
                // Failure (solo si no implementa completedWithFailure)
                self.handleFailureResponse(response: response, source: "Legacy Method")
            }
        }
    }
    
    // NUEVO MÉTODO - Para Failure y Failure-liveness
    func completedWithFailure(response: String?) {
        dismiss(animated: true) {
            print("📱 iOS Lanzador: completedWithFailure llamado")
            self.handleFailureResponse(response: response, source: "Modern Method")
        }
    }
    
    // MARK: - Response Handlers
    
    private func handleSuccessResponse(response: String?) {
        let responseData = parseResponse(response)
        let status = responseData["status"] as? String ?? "Success"
        
        print("📱 iOS Lanzador: Procesando respuesta exitosa - Status: \(status)")
        
        let title: String
        let message: String
        
        switch status {
        case "Success":
            title = "✅ Proceso Completado"
            message = "El proceso de verificación se completó exitosamente."
        case "Pending":
            title = "⏳ Proceso Pendiente"
            message = "El proceso está pendiente de aprobación. Se requiere revisión manual."
        default:
            title = "✅ Éxito"
            message = "Proceso completado."
        }
        
        showResponseModal(title: title, message: message, response: response, isSuccess: true)
    }
    
    private func handleFailureResponse(response: String?, source: String) {
        let responseData = parseResponse(response)
        let status = responseData["status"] as? String ?? "Failure"
        let errorMessage = responseData["message"] as? String ?? "Error desconocido"
        
        print("📱 iOS Lanzador: Procesando respuesta de error - Status: \(status) - Source: \(source)")
        
        let title: String
        let message: String
        
        switch status {
        case "Failure-liveness":
            title = "❌ Error de Liveness"
            message = "Error en la detección de vida: \(errorMessage)"
        case "Failure":
            title = "❌ Error en el Proceso"
            message = "Error: \(errorMessage)"
        default:
            title = "❌ Error"
            message = errorMessage
        }
        
        showResponseModal(title: title, message: message, response: response, isSuccess: false)
    }
    
    private func parseResponse(_ response: String?) -> [String: Any] {
        guard let response = response,
              let data = response.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return [:]
        }
        return json
    }
    
    private func showResponseModal(title: String, message: String, response: String?, isSuccess: Bool) {
        // Mostrar respuesta completa en el TextView
        textResult.text = response ?? "Sin respuesta"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Botón para ver respuesta completa
        alert.addAction(UIAlertAction(title: "Ver Respuesta Completa", style: .default) { _ in
            self.showFullResponse(response: response)
        })
        
        // Botón para nueva invitación
        alert.addAction(UIAlertAction(title: "Nueva Invitación", style: .default) { _ in
            self.textResult.text = ""
            self.resultImage.image = nil
        })
        
        // Botón para cerrar
        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    private func showFullResponse(response: String?) {
        let alert = UIAlertController(title: "Respuesta Completa del SDK", message: response ?? "Sin respuesta", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}

