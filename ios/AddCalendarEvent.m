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

RCT_EXPORT_METHOD(requestCalendarPermission:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    self.resolver = resolve;
    self.rejecter = reject;
    
    [self checkEventStoreAccessForCalendar];
}

-(void)checkEventStoreAccessForCalendar
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (status)
    {
        case EKAuthorizationStatusAuthorized: [self markCalendarAccessAsGranted];
            break;
        case EKAuthorizationStatusNotDetermined: [self requestCalendarAccess];
            break;
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        {
            [self rejectAndReset:@"permissionNotGranted" withMessage:@"permissionNotGranted" withError:nil];
        }
            break;
        default:
            [self rejectAndReset:@"permissionNotGranted" withMessage:@"permissionNotGranted" withError:nil];
            break;
    }
}

-(void)markCalendarAccessAsGranted
{
    self.defaultCalendar = [self getEventStoreInstance].defaultCalendarForNewEvents;
    self.calendarAccessGranted = YES;
    [self resolveAndReset: @(YES)];
}

-(void)requestCalendarAccess
{
    [[self getEventStoreInstance] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
     {
         AddCalendarEvent * __weak weakSelf = self;
         dispatch_async(dispatch_get_main_queue(), ^{
             if (granted) {
                 [weakSelf markCalendarAccessAsGranted];
             } else {
                 [weakSelf rejectAndReset:@"accessNotGranted" withMessage:@"accessNotGranted" withError:nil];
             }
         });
     }];
}

RCT_EXPORT_METHOD(presentEventCreatingDialog:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    self.eventOptions = options;
    self.resolver = resolve;
    self.rejecter = reject;
    
    AddCalendarEvent * __weak weakSelf = self;
    
    void (^showEventCreatingController)(void) = ^{
        EKEventEditViewController *controller = [[EKEventEditViewController alloc] init];
        controller.event = [weakSelf createNewEventInstance];
        controller.eventStore = [weakSelf getEventStoreInstance];
        controller.editViewDelegate = weakSelf;
        [weakSelf presentViewController:controller];
    };
    
    [self runIfAccessGranted:showEventCreatingController];
}

-(void)runIfAccessGranted: (void (^)(void))codeBlock
{
    if (self.calendarAccessGranted) {
        codeBlock();
    } else {
        [self rejectAndReset:@"accessNotGranted" withMessage:@"accessNotGranted" withError:nil];
    }
}

RCT_EXPORT_METHOD(presentEventViewingDialog:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    self.eventOptions = options;
    self.resolver = resolve;
    self.rejecter = reject;
    
    AddCalendarEvent * __weak weakSelf = self;

    void (^showEventViewingController)(void) = ^{
        EKEventViewController *controller = [[EKEventViewController alloc] init];
        controller.event = [weakSelf getEditedEventInstance];
        //    controller.eventStore = [self getEventStoreInstance];
        //    controller.editViewDelegate = self;
        controller.delegate = weakSelf;
        controller.allowsEditing = YES;
//        controller.allowsCalendarPreview = YES;
        UINavigationController *navBar = [[UINavigationController new] initWithRootViewController:controller];
//        navBar.navigationBar.tintColor = [UIColor blueColor];
//        navBar.navigationBar.backgroundColor = [UIColor greenColor];
        [weakSelf presentViewController:navBar];
    };
    
    [self runIfAccessGranted:showEventViewingController];
}

RCT_EXPORT_METHOD(presentEventEditingDialog:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    self.eventOptions = options;
    self.resolver = resolve;
    self.rejecter = reject;
    
    AddCalendarEvent * __weak weakSelf = self;

    void (^showEventEditingController)(void) = ^{
        EKEventEditViewController *controller = [[EKEventEditViewController alloc] init];
        controller.event = [weakSelf getEditedEventInstance];
        controller.eventStore = [weakSelf getEventStoreInstance];
        controller.editViewDelegate = weakSelf;
        controller.navigationBar.tintColor = [UIColor blueColor];
        controller.navigationBar.backgroundColor = [UIColor greenColor];
        [weakSelf presentViewController:controller];
    };
    
    [self runIfAccessGranted:showEventEditingController];
}

-(void)presentViewController: (UIViewController *) controller {
    self.viewController = RCTPresentedViewController();
    [self.viewController presentViewController:controller animated:YES completion:nil];
}

-(nullable EKEvent *)getEditedEventInstance {
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


#pragma mark -
#pragma mark EKEventViewDelegate

- (void)eventViewController:(EKEventViewController *)controller
      didCompleteWithAction:(EKEventViewAction)action
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

- (void)resolveAndReset: (id) result {
    if (self.resolver) {
        self.resolver(result);
        [self resetPromises];
    }
}

@end

