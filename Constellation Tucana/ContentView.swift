import SwiftUI

struct ContentView: View {
    let coatyService: CoatyService
    
    var manifestController: DiscoverManifestController {
        coatyService.container.getController(name: "DiscoverManifestController")!
    }
    
    var body: some View {
        DiscoverManifestView(discoverManifestController: manifestController)
    }
}
