import CoatySwift

// TODO: Maybe make a generic class for autoupdating objects
class ConstellationServiceManifest: CoatyObject, UpdatableObject {
    
    override class var objectType: String {
        return register(objectType: "constellation.manifest", with: self)
    }
    
    private(set) var displayName: String
    private(set) var serviceIdentity: String
    private(set) var serviceContext: [ConstellationServiceContext]
    
    init(displayName: String, serviceIdentity: String, serviceContext: [ConstellationServiceContext]) {
        self.displayName = displayName
        self.serviceIdentity = serviceIdentity
        self.serviceContext = serviceContext
        
        super.init(coreType: .CoatyObject,
                   objectType: ConstellationServiceManifest.objectType,
                   objectId: .init(),
                   name: "Constellation Object")
    }
    
    // MARK: Codable methods.
    
    enum CodingKeys: String, CodingKey {
        case displayName
        case serviceIdentity
        case serviceContext
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        displayName = try container.decode(String.self, forKey: .displayName)
        serviceIdentity = try container.decode(String.self, forKey: .serviceIdentity)
        serviceContext = try container.decode([ConstellationServiceContext].self, forKey: .serviceContext)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(serviceIdentity, forKey: .serviceIdentity)
        try container.encode(serviceContext, forKey: .serviceContext)
    }
    
    // MARK: - Updatable Object
    
    func objectDidUpdate(newObject: ConstellationServiceManifest) {
        self.isDeactivated = false
        self.serviceContext = newObject.serviceContext
        self.serviceIdentity = newObject.serviceIdentity
        self.displayName = newObject.displayName
        self.name = newObject.name
    }
    
    func objectDidDeadvertise() {
        self.isDeactivated = true
    }
}

struct ConstellationServiceContext: Codable, Identifiable {
    enum ContextValueType: String, Codable {
        case string, number, boolean
    }
    enum ContextType: Codable {
        case list([ConstellationServiceContext])
        case item(ContextValueType)
        
        enum CodingKeys: CodingKey {
            case list, item
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if container.contains(.item) {
                self = .item(try container.decode(ContextValueType.self, forKey: .item))
            } else {
                self = .list(try container.decode([ConstellationServiceContext].self, forKey: .list))
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case let .list(list):
                try container.encode(list, forKey: .list)
            case let .item(item):
                try container.encode(item, forKey: .item)
            }
        }
    }
    
    var id: String {
        displayName + contextName
    }
    
    var displayName: String
    var contextName: String
    var type: ContextType
}

