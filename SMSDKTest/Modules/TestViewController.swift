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

