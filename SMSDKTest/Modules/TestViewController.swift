import UIKit
import AdoComponent

class TestViewController: UIViewController {
    
    @IBOutlet weak var resultImage: UIImageView!
    var smManagerVC: SMManager?
    private var customLoader: UIActivityIndicatorView?

    @IBOutlet weak var urlInit: UITextField!
    @IBOutlet weak var textResult: UITextView!

    
    //MARK: Functions
    func callFaceViewController(documentType: String) {
        if let urlString = urlInit.text, !urlString.isEmpty {
            startSDKProcess(urlString: urlString)
        } else {
            showAlert(title: "Error", message: "Por favor ingrese una URL válida.")
        }
    }
    
    // Método avanzado con control de loader
    private func startSDKProcess(urlString: String) {
        // 1. Mostrar loader personalizado
        showCustomLoader()
        
        // 2. Configurar delegate para ocultar loader cuando esté listo
        SMManager.setWebReadyDelegate(self)
        
        // 3. Iniciar SDK
        let params = SMParams(urlInvitation: urlString)
        let smVC = SMManager.initWith(delegate: self, params: params)
        smVC.modalPresentationStyle = .fullScreen
        present(smVC, animated: true, completion: nil)
    }
    
    private func showCustomLoader() {
        if #available(iOS 13.0, *) {
            customLoader = UIActivityIndicatorView(style: .large)
        } else {
            customLoader = UIActivityIndicatorView(style: .whiteLarge)
        }
        if #available(iOS 13.0, *) {
            customLoader?.color = .systemBlue
        } else {
            customLoader?.color = .blue
        }
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

//MARK:- SMWebReadyDelegate
extension TestViewController: SMWebReadyDelegate {
    func webContentReady() {
        print("📱 Lanzador iOS: WebContent listo - Ocultando loader personalizado")
        hideCustomLoader()
    }
}

//MARK:- SMDelegate
extension TestViewController: SMDelegate {
    
    func completedWithResult(result: Bool, response: String?) {
        dismiss(animated: true) {
            self.showResponse(type: "SUCCESS", response: response)
        }
    }
    
    func completedWithPending(response: String?) {
        dismiss(animated: true) {
            self.showResponse(type: "PENDING", response: response)
        }
    }
    
    func completedWithFailure(response: String?) {
        dismiss(animated: true) {
            self.showResponse(type: "FAILURE", response: response)
        }
    }
    
    private func showResponse(type: String, response: String?) {
        // Limpiar campo URL después de cada proceso
        urlInit.text = ""
        
        let alert = UIAlertController(title: type, message: response ?? "Sin respuesta", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}

