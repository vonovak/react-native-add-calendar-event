//
//  AddCalendarEvent.swift
//  AddCalendarEvent
//
//  Created by Vojtech Novak on 17/04/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

import Foundation


@objc(AddCalendarEvent)
class AddCalendarEvent {
    
    private var eventStore: EKEventStore = nil
    
    func getEventStoreInstance() -> EKEventStore {
        if(self.eventStore == nil) {
            self.eventStore = EKEventStore()
        }
        return self.eventStore
    }
    
    @objc func addEvent(_ eventOptions: NSDictionary, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) -> Void {
        let addController = EKEventEditViewController()
        
        addController.eventStore = getEventStoreInstance()
        addController.editViewDelegate = self
        self.present(addController, animated: true, completion: nil)
    }
}
