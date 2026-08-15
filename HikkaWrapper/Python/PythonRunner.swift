import Foundation
import PythonKit

class PythonRunner: ObservableObject {
    @Published var consoleOutput: String = ""
    private var isRunning = false
    
    func startHikka() {
        guard !isRunning else { return }
        isRunning = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Настройка окружения Python
            self.setupPythonEnvironment()
            
            // Инициализация Python
            Py_Initialize()
            
            // Проверка инициализации
            guard Py_IsInitialized() != 0 else {
                self.appendLog("❌ Failed to initialize Python interpreter")
                self.isRunning = false
                return
            }
            
            self.appendLog("✅ Python interpreter initialized")
            
            // Настройка переменных окружения
            self.setupEnvironmentVariables()
            
            // Запуск Hikka
            self.runHikka()
        }
    }
    
    private func setupPythonEnvironment() {
        let bundle = Bundle.main
        
        // Путь к Python.framework
        guard let frameworkPath = bundle.path(forResource: "Python", ofType: "framework", inDirectory: "Frameworks") else {
            appendLog("❌ Python.framework not found in Bundle")
            return
        }
        appendLog("📍 Python.framework: \(frameworkPath)")
        
        // Путь к стандартной библиотеке
        guard let stdLibPath = bundle.path(forResource: "python310", ofType: nil, inDirectory: "pythonlib") else {
            appendLog("❌ Python stdlib not found")
            return
        }
        appendLog("📍 Python stdlib: \(stdLibPath)")
        
        // Путь к site-packages (где лежит hikka)
        let sitePackagesPath = "\(stdLibPath)/site-packages"
        guard FileManager.default.fileExists(atPath: sitePackagesPath) else {
            appendLog("❌ site-packages not found at: \(sitePackagesPath)")
            return
        }
        appendLog("📍 site-packages: \(sitePackagesPath)")
        
        // Устанавливаем PYTHONHOME
        let pythonHome = "\(stdLibPath)/lib/python3.10"
        setenv("PYTHONHOME", pythonHome.cString(using: .utf8), 1)
        appendLog("🔧 PYTHONHOME: \(pythonHome)")
        
        // Устанавливаем PYTHONPATH
        let pythonPath = "\(pythonHome):\(sitePackagesPath)"
        setenv("PYTHONPATH", pythonPath.cString(using: .utf8), 1)
        appendLog("🔧 PYTHONPATH: \(pythonPath)")
        
        // Устанавливаем PYTHONOPTIMIZE для уменьшения размера
        setenv("PYTHONOPTIMIZE", "1", 1)
    }
    
    private func setupEnvironmentVariables() {
        // Директория для данных Hikka (в DocumentDirectory)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let hikkaDataDir = "\(documentsPath)/hikka_data"
        
        // Создаем директорию если её нет
        do {
            try FileManager.default.createDirectory(atPath: hikkaDataDir, withIntermediateDirectories: true, attributes: nil)
            appendLog("📁 Created data directory: \(hikkaDataDir)")
        } catch {
            appendLog("⚠️ Could not create data directory: \(error)")
        }
        
        setenv("HIKKA_DATA_DIR", hikkaDataDir.cString(using: .utf8), 1)
        appendLog("🔧 HIKKA_DATA_DIR: \(hikkaDataDir)")
        
        // Тоже самое для временной директории
        let tempDir = NSTemporaryDirectory()
        setenv("TEMP", tempDir.cString(using: .utf8), 1)
        appendLog("🔧 TEMP: \(tempDir)")
    }
    
    private func runHikka() {
        appendLog("🚀 Starting Hikka userbot...")
        
        do {
            // Импортируем модуль hikka.__main__
            appendLog("📦 Importing hikka.__main__...")
            let mainModule = try Python.attemptImport("hikka.__main__")
            appendLog("✅ Module imported successfully")
            
            // Вызываем функцию main()
            appendLog("🏃 Running main()...")
            let result = mainModule.main()
            
            appendLog("✅ Hikka started successfully")
            if let resultStr = String(describing: result) as String? {
                appendLog("📱 Output: \(resultStr)")
            }
        } catch {
            appendLog("❌ Error running Hikka: \(error.localizedDescription)")
            
            // Пытаемся получить детали ошибки из Python
            if let pyError = Python.exception {
                appendLog("🐍 Python error: \(pyError)")
                appendLog("🐍 Python error type: \(type(of: pyError))")
            }
            
            // Дополнительная диагностика
            let sys = Python.import("sys")
            appendLog("🔍 Python version: \(sys.version)")
            appendLog("🔍 Python path: \(sys.path)")
        }
        
        DispatchQueue.main.async {
            self.isRunning = false
        }
    }
    
    private func appendLog(_ message: String) {
        DispatchQueue.main.async {
            let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
            self.consoleOutput += "[\(timestamp)] \(message)\n"
            
            // Автоматическая прокрутка вниз
            if self.consoleOutput.count > 10000 {
                self.consoleOutput = String(self.consoleOutput.suffix(5000))
            }
        }
    }
}
