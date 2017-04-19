#import <React/RCTBridgeModule.h>
//#import "AddCalendarEvent.h"

//@implementation AddCalendarEvent

@interface RCT_EXTERN_MODULE(AddCalendarEvent, NSObject)


RCT_EXTERN_METHOD(addEvent:
                  (NSDictionary *) config
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
  
