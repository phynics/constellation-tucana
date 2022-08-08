import CoatySwift
import SwiftUI
import RxSwift

class UpdatingLifecycleController<ObservedType>: Controller, ObservableObject where ObservedType: UpdatableObject & CoatyObject {
    private(set) var receivedObjects: [ObservedType] = []
    
    override func onCommunicationManagerStarting() {
        super.onCommunicationManagerStarting()
        _observeAdvertise()
        _observeUpdate()
        _observeDeadvertise()
        _discoverObjects()
        
    }
    
    override func onCommunicationManagerStopping() {
        super.onCommunicationManagerStopping()
    }
    
    private func _observeAdvertise() {
        do {
            try self.communicationManager
                .observeAdvertise(withObjectType: ObservedType.objectType)
                .debug()
                .subscribe(onNext: { [weak self] advertiseEvent in
                    print(String(describing: advertiseEvent))
                    self?._processReceivedObject(advertiseEvent.data.object)
                })
                .disposed(by: disposeBag)
        } catch {
            logError(error: error, message: "UpdatingLifeCycleController: observeAdvertise()")
        }
    }
    
    private func _discoverObjects() {
        self.communicationManager
            .publishDiscover(.with(objectTypes: [ObservedType.objectType] ))
            .debug()
            .subscribe(onNext: { [weak self] resolveEvent in
                print(String(describing: resolveEvent))
                self?._processReceivedObject(resolveEvent.data.object)
            })
            .disposed(by: disposeBag)
    }
    
    private func _observeUpdate() {
        do {
            try self.communicationManager
                .observeUpdate(withObjectType: ObservedType.objectType)
                .subscribe(onNext: { [weak self] updateEvent in self?._processReceivedObject(updateEvent.data.object) })
                .disposed(by: disposeBag)
        } catch {
            logError(error: error, message: "UpdatingLifecycleController: updateObjects()")
        }
    }
    
    private func _observeDeadvertise() {
        self.communicationManager
            .observeDeadvertise()
            .subscribe(onNext: { [weak self] deadvertiseEvent in self?._processDeadvertisedObjects(deadvertiseEvent.data.objectIds) })
            .disposed(by: disposeBag)
    }
    
    private func _processReceivedObject(_ coatyObject: CoatyObject?) {
        guard let updatableObject = coatyObject as? ObservedType,
              let coatyObject = coatyObject as? ObservedType.T else {
            return
        }
        
        objectWillChange.send()
        
        if let existingObject = receivedObjects.first(where: { coatyObject.objectId == $0.objectId }) {
            existingObject.objectDidUpdate(newObject: coatyObject)
        } else {
            receivedObjects.append(updatableObject)
        }
        
    }
    
    private func _processDeadvertisedObjects(_ uuids: [CoatyUUID]) {
        objectWillChange.send()
        for objectId in uuids {
            if let presentObjectIndex = receivedObjects.firstIndex(where: { $0.objectId == objectId || $0.parentObjectId == objectId }) {
                receivedObjects.remove(at: presentObjectIndex)
            }
        }
    }
    
    
}
