#import "AddCalendarEvent.h"
#import "EKEventStoreSingleton.h"

@interface AddCalendarEvent()

@property EKEventStore *eventStore;
@property EKCalendar *defaultCalendar;
@property UIViewController *viewController;
@property BOOL calendarAccessGranted;
@property NSDictionary *eventOptions;

@property (nonatomic) RCTPromiseResolveBlock resolver;
@property (nonatomic) RCTPromiseRejectBlock rejecter;

@end


@implementation AddCalendarEvent

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

static NSString *const _id = @"id";
static NSString *const _title = @"title";
static NSString *const _location = @"location";
static NSString *const _startDate = @"startDate";
static NSString *const _endDate = @"endDate";
static NSString *const _notes = @"notes";
static NSString *const _url = @"url";

static NSString *const MODULE_NAME= @"AddCalendarEvent";


- (EKEventStore *) getEventStoreInstance {
    return [EKEventStoreSingleton getInstance];
}

- (id) init {
    self = [super init];
    if (self != nil) {
        self.eventStore = nil;
        self.calendarAccessGranted = NO;
        self.defaultCalendar = nil; // defaultCalendar not used in the module at this point
        [self resetPromises];
    }
    return self;
}


RCT_EXPORT_METHOD(presentNewEventDialog:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    self.viewController = RCTPresentedViewController();
    self.eventOptions = options;
    self.resolver = resolve;
    self.rejecter = reject;
    [self checkEventStoreAccessForCalendar];
    if (self.calendarAccessGranted) {
        [self showCalendarEventModal];
    }
}

-(void)checkEventStoreAccessForCalendar
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (status)
    {
        case EKAuthorizationStatusAuthorized: [self accessGrantedForCalendar];
            break;
        case EKAuthorizationStatusNotDetermined: [self requestCalendarAccess];
            break;
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Permission was not granted for Calendar"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self.viewController presentViewController:alert animated:YES completion:nil];
            [self rejectAndReset:@"permissionNotGranted" withMessage:@"permissionNotGranted" withError:nil];
        }
            break;
        default:
            break;
    }
}

-(void)accessGrantedForCalendar
{
    self.defaultCalendar = [self getEventStoreInstance].defaultCalendarForNewEvents;
    self.calendarAccessGranted = YES;
}

-(void) showCalendarEventModal {
    EKEventEditViewController *addController = [[EKEventEditViewController alloc] init];
    NSDictionary * options = _eventOptions;
    
    EKEvent *event = [EKEvent eventWithEventStore: [self getEventStoreInstance]];
    event.title = [RCTConvert NSString:options[_title]];
    event.location = options[_location] ? [RCTConvert NSString:options[_location]] : nil;
    
    if (options[_startDate]) {
        event.startDate = [RCTConvert NSDate:options[_startDate]];
    }
    if (options[_endDate]) {
        event.endDate = [RCTConvert NSDate:options[_endDate]];
    }
    if (options[_url]) {
        event.URL = [RCTConvert NSURL:options[_url]];
    }
    if (options[_notes]) {
        event.notes = [RCTConvert NSString:options[_notes]];
    }
    
    addController.event = event;
    addController.eventStore = [self getEventStoreInstance];
    addController.editViewDelegate = self;
    [self.viewController presentViewController:addController animated:YES completion:nil];
}

-(void)requestCalendarAccess
{
    [[self getEventStoreInstance] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
     {
         AddCalendarEvent * __weak weakSelf = self;
         dispatch_async(dispatch_get_main_queue(), ^{
             if (granted) {
                 [weakSelf showCalendarEventModal];
                 weakSelf.calendarAccessGranted = YES;
             } else {
                 [weakSelf rejectAndReset:@"accessNotGranted" withMessage:@"accessNotGranted" withError:nil];
             }
         });
     }];
}

- (void) resolveAndReset: (id) result {
    if (self.resolver != nil) {
        self.resolver(result);
        [self resetPromises];
    }
}

- (void) rejectAndReset: (NSString*) code withMessage: (NSString*) message withError: (NSError*) error {
    if (self.rejecter != nil) {
        self.rejecter(code, message, error);
        [self resetPromises];
    }
}

- (void) resetPromises {
    self.resolver = nil;
    self.rejecter = nil;
}

#pragma mark -
#pragma mark EKEventEditViewDelegate

// Overriding EKEventEditViewDelegate method to react to user action
- (void)eventEditViewController:(EKEventEditViewController *)controller
          didCompleteWithAction:(EKEventEditViewAction)action
{
    AddCalendarEvent * __weak weakSelf = self;
    // Dismiss the modal view controller
    [self.viewController dismissViewControllerAnimated:YES completion:^
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (action != EKEventEditViewActionCanceled)
             {
                 [weakSelf resolveAndReset: controller.event.calendarItemIdentifier];
             } else {
                 [weakSelf resolveAndReset: @(NO)];
             }
         });
     }];
}

@end

