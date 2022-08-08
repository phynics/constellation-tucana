import CoatySwift

extension CoatyObject: Identifiable {
    public var id: String {
        self.objectId.string
    }
}
