import UIKit
import AdoComponent

// IMPLEMENTACIÓN CORREGIDA DEL DELEGATE
extension YourViewController: SMDelegate {
    
    // ✅ SUCCESS - Este funciona correctamente
    func completedWithResult(result: Bool, response: String?) {
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                print("✅ SUCCESS: \(response ?? "Sin respuesta")")
                self.handleSuccess(response: response)
            }
        }
    }
    
    // ⚠️ PENDING - Implementación forzada (no opcional)
    func completedWithPending(response: String?) {
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                print("⏳ PENDING: \(response ?? "Sin respuesta")")
                self.handlePending(response: response)
            }
        }
    }
    
    // ❌ FAILURE - Implementación forzada (no opcional)  
    func completedWithFailure(response: String?) {
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                print("❌ FAILURE: \(response ?? "Sin respuesta")")
                self.handleFailure(response: response)
            }
        }
    }
}

// WORKAROUND ADICIONAL - Implementar también con @objc
extension YourViewController {
    
    @objc func completedWithPending(_ response: String?) {
        completedWithPending(response: response)
    }
    
    @objc func completedWithFailure(_ response: String?) {
        completedWithFailure(response: response)
    }
}