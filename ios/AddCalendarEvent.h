
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EKEventEditViewController.h>
#import <EventKitUI/EventKitUIDefines.h>
#import <React/RCTUIManager.h>
#import <React/RCTUtils.h>

@interface AddCalendarEvent : NSObject <RCTBridgeModule, EKEventEditViewDelegate>

@end
