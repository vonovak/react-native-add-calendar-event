#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EKEventEditViewController.h>
#import <EventKitUI/EKEventViewController.h>
#import <EventKitUI/EventKitUIDefines.h>
#import <React/RCTUIManager.h>
#import <React/RCTUtils.h>

@interface AddCalendarEvent : NSObject <RCTBridgeModule, EKEventEditViewDelegate, EKEventViewDelegate>

@end
