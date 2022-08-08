import CoatySwift
import UIKit

class CoatyService {
    let container: Container
    static let brokerHost = "192.168.178.47"
    static let brokerPort = 1883
    
    init() throws {
        // Register controllers and custom object types.
        let components = Components(
            controllers: [
                "DiscoverManifestController": DiscoverManifestController.self
            ],
            objectTypes: [
                ConstellationServiceManifest.self
            ]
        )
        
        // Create a configuration.
        guard let configuration = CoatyService.createExampleConfiguration() else {
            print("Invalid configuration! Please check your options.")
            throw CoatyError.configurationError
        }
        
        // Resolve everything!
        container = Container.resolve(components: components,
                                      configuration: configuration)
    }
    
    private static func createExampleConfiguration() -> Configuration? {
        return try? .build { config in
            
            config.common = CommonOptions()
            
            config.common?.logLevel = .info
            config.common?.agentIdentity = ["name": "constellation-tucana: \(UIDevice.current.identifierForVendor?.uuidString ?? "")"]
            config.common?.ioContextNodes = [:]
            config.common?.extra = ["ContainerVersion": "0.0.1"]
            
            // Define communication-related options, such as the host address of
            // your broker (default is "localhost") and the port it exposes
            // (default is 1883). Define a unqiue communication namespace for
            // your application and make sure to immediately connect with the
            // broker, indicated by `shouldAutoStart: true`.
            let mqttClientOptions = MQTTClientOptions(host: brokerHost,
                                                      port: UInt16(brokerPort))
            
            
            config.communication = CommunicationOptions(namespace: "me.atkn.constellation",
                                                        mqttClientOptions: mqttClientOptions,
                                                        shouldAutoStart: true)
        }
    }
}
