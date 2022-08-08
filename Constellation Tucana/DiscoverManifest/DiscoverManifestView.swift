import SwiftUI

struct DiscoverManifestView: View {
    @ObservedObject var discoverManifestController: DiscoverManifestController
    var body: some View {
        NavigationView {
            List(discoverManifestController.receivedObjects) { service in
                NavigationLink("\(service.displayName)") {
                    List {
                        Section {
                            Text("\(service.displayName)")
                            Text("\(service.serviceIdentity)")
                        }
                        ForEach(service.serviceContext) { context in
                            DiscoverManifestContextView(context: context)
                        }
                    }
                }
            }
        }
    }
}

struct DiscoverManifestContextView: View {
    let context: ConstellationServiceContext
    
    var body: some View {
        Section {
            Text("\(context.displayName)")
            Text("\(context.contextName)")
        }
        switch context.type {
        case let .item(contextValue):
            Section {
                Text("\(context.displayName)")
                Text("\(context.contextName)")
                Text("\(contextValue.rawValue)")
            }
        case let .list(contextList):
            List(contextList) {
                DiscoverManifestContextView(context: $0)
            }
        }
    }
}
