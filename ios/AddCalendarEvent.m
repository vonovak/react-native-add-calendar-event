#import "AddCalendarEvent.h"
#import "EKEventStoreSingleton.h"

@interface AddCalendarEvent()

@property (nonatomic) EKCalendar *defaultCalendar;
@property (nonatomic) UIViewController *viewController;
@property (nonatomic) BOOL calendarAccessGranted;
@property (nonatomic) NSDictionary *eventOptions;

@property (nonatomic) RCTPromiseResolveBlock resolver;
@property (nonatomic) RCTPromiseRejectBlock rejecter;

@end


@implementation AddCalendarEvent

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()
    
+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

static NSString *const _eventId = @"eventId";
static NSString *const _title = @"title";
static NSString *const _location = @"location";
static NSString *const _startDate = @"startDate";
static NSString *const _endDate = @"endDate";
static NSString *const _notes = @"notes";
static NSString *const _url = @"url";
static NSString *const _allDay = @"allDay";

static NSString *const MODULE_NAME= @"AddCalendarEvent";


- (EKEventStore *)getEventStoreInstance {
    return [EKEventStoreSingleton getInstance];
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.calendarAccessGranted = NO;
        self.defaultCalendar = nil; // defaultCalendar not used in the module at this point
        [self resetPromises];
    }
    return self;
}


RCT_EXPORT_METHOD(presentEventCreatingDialog:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    self.eventOptions = options;
    self.resolver = resolve;
    self.rejecter = reject;
    SEL showEventCreatingDialog = @selector(showEventCreatingController);
    [self checkEventStoreAccessForCalendar:showEventCreatingDialog];
    if (self.calendarAccessGranted) {
        [self showEventCreatingController];
    }
}

-(void)showEventCreatingController
{
    EKEventEditViewController *controller = [[EKEventEditViewController alloc] init];
    controller.event = [self createNewEventInstance];
    controller.eventStore = [self getEventStoreInstance];
    controller.editViewDelegate = self;
    [self showCalendarEventModal:controller];
}

RCT_EXPORT_METHOD(presentEventViewingDialog:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    self.eventOptions = options;
    self.resolver = resolve;
    self.rejecter = reject;
    SEL showEventViewingDialog = @selector(showEventViewingController);
    [self checkEventStoreAccessForCalendar:showEventViewingDialog];
    if (self.calendarAccessGranted) {
        [self showEventViewingController];
    }
}

-(void)showEventViewingController
{
    EKEventViewController *controller = [[EKEventViewController alloc] init];
    controller.event = [self getNewOrEditedEventInstance];
//    controller.eventStore = [self getEventStoreInstance];
//    controller.editViewDelegate = self;
    controller.delegate = self;
    [self showCalendarEventModal:controller];
}

RCT_EXPORT_METHOD(presentEventEditingDialog:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    self.eventOptions = options;
    self.resolver = resolve;
    self.rejecter = reject;
    SEL showEventEditingController = @selector(showEventEditingController);
    [self checkEventStoreAccessForCalendar: showEventEditingController];
    if (self.calendarAccessGranted) {
        [self showEventEditingController];
    }
}

-(void)showEventEditingController
{
    EKEventEditViewController *controller = [[EKEventEditViewController alloc] init];
    controller.event = [self getNewOrEditedEventInstance];
    controller.eventStore = [self getEventStoreInstance];
    controller.editViewDelegate = self;
    [self showCalendarEventModal:controller];
}

-(void)checkEventStoreAccessForCalendar: (SEL) onAccessPermitted
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];

    switch (status)
    {
        case EKAuthorizationStatusAuthorized: [self accessGrantedForCalendar];
            break;
        case EKAuthorizationStatusNotDetermined: [self requestCalendarAccess:onAccessPermitted];
            break;
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        {
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

-(void)requestCalendarAccess: (SEL) onAccessPermitted
{
    [[self getEventStoreInstance] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
     {
         AddCalendarEvent * __weak weakSelf = self;
         dispatch_async(dispatch_get_main_queue(), ^{
             if (granted) {
                 [weakSelf accessGrantedForCalendar];
                 [weakSelf performSelector:onAccessPermitted];
             } else {
                 [weakSelf rejectAndReset:@"accessNotGranted" withMessage:@"accessNotGranted" withError:nil];
             }
         });
     }];
}

-(void)showCalendarEventModal: (UIViewController *) controller {
    self.viewController = RCTPresentedViewController();
    [self.viewController presentViewController:controller animated:YES completion:nil];
}

-(nullable EKEvent *)getNewOrEditedEventInstance {
    EKEvent *maybeEvent = [[self getEventStoreInstance] eventWithIdentifier: _eventOptions[_eventId]];
    if (!maybeEvent) {
        maybeEvent = [[self getEventStoreInstance] calendarItemWithIdentifier: _eventOptions[_eventId]];
    }
    return maybeEvent;
}

-(EKEvent *)createNewEventInstance {
    EKEvent *event = [EKEvent eventWithEventStore: [self getEventStoreInstance]];
    NSDictionary *options = _eventOptions;

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
    if (options[_allDay]) {
        event.allDay = [RCTConvert BOOL:options[_allDay]];
    }
    return event;
}

- (void)rejectAndReset: (NSString *) code withMessage: (NSString *) message withError: (NSError *) error {
    if (self.rejecter) {
        self.rejecter(code, message, error);
        [self resetPromises];
    }
}

- (void)resetPromises {
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
    [self.viewController dismissViewControllerAnimated:YES completion:^
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (action != EKEventEditViewActionCanceled)
             {
                 EKEvent *evt = controller.event;
                 NSDictionary *result = @{
                                          @"eventIdentifier":evt.eventIdentifier,
                                          @"calendarItemIdentifier":evt.calendarItemIdentifier,
                                          };
                 [weakSelf resolveAndReset: result];
             } else {
                 [weakSelf resolveAndReset: @(NO)];
             }
         });
     }];
}

- (void)eventViewController:(EKEventViewController *)controller
      didCompleteWithAction:(EKEventViewAction)action
{
    
}

- (void)resolveAndReset: (id) result {
    if (self.resolver) {
        self.resolver(result);
        [self resetPromises];
    }
}

@end

