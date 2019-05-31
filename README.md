#  iOS Push Notifications

## ¿Qué es este proyecto?

En ocasiones nuestras apps requieren de un servicio que nos permita enviar notificaciones push a los usuarios. Actualmente existen numerosas alternativas como Firebase o OneSignal, pero la mayoría de las ocasiones necesitamos algo mucho más sencillo y sin necesidad de utilizar frameworks de terceros en nuestros proyectos.

Este repositorio contiene el proyecto de Vapor para el servidor que almacenará los dispositivos que han autorizado las notificaciones push, una aplicación de consola para Mac que permite enviar rápidamente notificaciones push a todos los dispositivos, y código de ejemplo de como integrarlo en una app para iOS. Todo desarrollado en Swift. Además, podrás utilizar el mismo servidor para todas tus aplicaciones.

## ¿Cómo funciona?

El funcionamiento es bastante simple, cuando un nuevo usuario de nuestra app acepta las notificaciones push, se registra en la base de datos del servidor el token del dispositivo junto con el identificador de la aplicación a través de una simple llamada POST que requiere como cuerpo un JSON cuyos parámetros sean appIdentifier (String), token (String), y debug (bool):

```
{
"appIdentifier": "com.rubenfernandez.MiApp",
"token": "00000000abcdefghijk",
"debug": true
}
```

Cuando se quiere enviar una notificación, se utiliza la aplicación de consola que utiliza [Swift NIO APNS](https://github.com/kylebrowning/swift-nio-apns/)

## ¿Cómo ejecutar el servidor Vapor?

1. Abre la app Terminal en tu Mac
2. Navega al directorio Vapor
3. Ejecuta el comando `vapor xcode -y` (se abrirá Xcode con el proyecto de Vapor)
4. En el archivo configure.swift, modifica la ip de la linea `serverConfig.hostname = "192.168.1.66"` por la ip de tu Mac.
5. Cierra Xcode
6. De nuevo en la Terminal y en el directorio de Vapor, ejecuta `vapor build` y a continuación, `vapor run`.

(Nota: en el ejemplo del servidor Vapor, se utiliza una base de datos SQLite sin autenticación almacenada en un fichero dentro del propio proyecto, por lo que en entornos de producción se recomienda utilizar una base de datos PostgreSQL con contraseña)

## ¿Cómo configurar la aplicación iOS?

Modificamos el archivo AppDelegate.swift de nuestra aplicación para enviar al servidor el token del dispositivo cuando se acepten las notificaciones push. Existen varias formas de hacerlo, por ejemplo:

```swift
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerForPushNotifications(application: application)
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        sendPushNotificationsDetails(to: "http://192.168.1.66:8080/api/token", using: deviceToken)
    }

    func registerForPushNotifications(application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .sound, .alert]) { [weak self] granted, _ in
            guard granted else { return }
            center.delegate = self?.notificationDelegate
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }

    func sendPushNotificationsDetails(to urlString: String, using deviceToken: Data) {

        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL string")
        }

        let token = deviceToken.reduce("") {
            $0 + String(format: "%02x", $1)
        }

        var obj: [String: Any] = [
        "token": token,
        "appIdentifier": Bundle.main.bundleIdentifier!,
        "debug": false
        ]

        #if DEBUG
        obj["debug"] = true
        #endif

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: obj)

        URLSession.shared.dataTask(with: request).resume()

    }

}
```
(Modifica `192.168.1.66` por la ip del servidor Vapor)

## ¿Cómo enviar notificaciones?

Para realizar el envío de notificaciones a los dispostivos:

1. En la Terminal de tu Mac ve a la carpeta ConsoleSend.
2. Ejecuta el comando `swift package generate-xcodeproj`.
3. Abre el proyecto .xcodeproj que se acaba de generar.
3. En el archivo main.swift encontrarás en las primeras líneas siguientes datos que debes modificar: 
```swift
let p8FilePath = "/Users/.../AuthKey_keyIdentifier.p8"
let keyIdentifier = "ABCD1234"
let teamIdentifier = "ABCD1234"
let apiUrl = "http://192.168.1.66:8080/api/token/" // Modifica la IP por la del servidor Vapor
```
4. Ejecuta el proyecto de Xcode. A continuación, podrás interactuar de forma sencilla para enviar la notificación que quieras a los dispositivos de una de tus apps.
