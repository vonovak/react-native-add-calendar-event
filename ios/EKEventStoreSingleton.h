//
//  EKEventStoreSingleton.h
//  RNAddCalendarEvent
//
//  Created by Vojtech Novak on 13/05/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#ifndef EKEventStoreSingleton_h
#define EKEventStoreSingleton_h
#import <EventKit/EventKit.h>

@interface EKEventStoreSingleton : NSObject {
}


+ (EKEventStore *)getInstance;

@end

#endif /* EKEventStoreSingleton_h */
