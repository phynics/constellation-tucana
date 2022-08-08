import Foundation

typealias IdentifiableArray = Array<Identifiable>

extension Array where Element: Identifiable {
    mutating func appendUniquely(_ element: Element) {
        guard self.contains(where: { element.id == $0.id }) == false else {
            return
        }
        
        self.append(element)
    }
}
