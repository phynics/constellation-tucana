import CoatySwift
import Combine

protocol UpdatableObject {
    associatedtype T where T: CoatyObject
    
    func objectDidUpdate(newObject: T)
    func objectDidDeadvertise()
}
