import SwiftUI

@main
struct Constellation_TucanaApp: App {
    let coatyService = try? CoatyService()
    
    var body: some Scene {
        WindowGroup {
            ContentView(coatyService: coatyService!)
        }
    }
}
