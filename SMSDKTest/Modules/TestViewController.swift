import UIKit
import AdoComponent

class TestViewController: UIViewController {
    
    @IBOutlet weak var resultImage: UIImageView!
    var smManagerVC: SMManager?
    private var customLoader: UIActivityIndicatorView?
    private var sdkViewController: UIViewController?
    private var loaderWindow: UIWindow?

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
        // 1. Mostrar loader en ventana separada
        showLoaderWindow()
        
        // 2. Configurar delegate
        SMManager.setWebReadyDelegate(self)
        
        // 3. Crear y presentar SDK
        let params = SMParams(urlInvitation: urlString)
        let smVC = SMManager.initWith(delegate: self, params: params)
        smVC.modalPresentationStyle = .fullScreen
        sdkViewController = smVC
        
        // 4. Presentar SDK (loader permanece visible)
        present(smVC, animated: true, completion: nil)
    }
    
    private func showLoaderWindow() {
        // Crear ventana separada para el loader
        if #available(iOS 13.0, *) {
            if let windowScene = view.window?.windowScene {
                loaderWindow = UIWindow(windowScene: windowScene)
            } else {
                loaderWindow = UIWindow(frame: UIScreen.main.bounds)
            }
        } else {
            loaderWindow = UIWindow(frame: UIScreen.main.bounds)
        }
        
        loaderWindow?.windowLevel = UIWindow.Level.alert + 1
        loaderWindow?.backgroundColor = view.backgroundColor ?? .white
        
        // Crear vista contenedora
        let containerView = UIView()
        containerView.backgroundColor = view.backgroundColor ?? .white
        
        // Crear loader
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
        
        if let window = loaderWindow, let loader = customLoader {
            containerView.addSubview(loader)
            window.rootViewController = UIViewController()
            window.rootViewController?.view = containerView
            
            NSLayoutConstraint.activate([
                loader.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                loader.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ])
            
            loader.startAnimating()
            window.makeKeyAndVisible()
        }
    }
    
    private func hideCustomLoader() {
        UIView.animate(withDuration: 0.3, animations: {
            self.loaderWindow?.alpha = 0.0
        }) { _ in
            self.customLoader?.stopAnimating()
            self.loaderWindow?.isHidden = true
            self.loaderWindow = nil
            self.customLoader = nil
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

//MARK:- SMWebReadyDelegate
extension TestViewController: SMWebReadyDelegate {
    func webContentReady() {
        print("📱 Lanzador iOS: WebContent listo - Ocultando loader personalizado")
        
        // Ocultar overlay para revelar SDK que está por debajo
        DispatchQueue.main.async {
            self.hideCustomLoader()
        }
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

