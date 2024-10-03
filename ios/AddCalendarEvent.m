#import "AddCalendarEvent.h"
#import "EKEventStoreSingleton.h"

@interface AddCalendarEvent()

@property (nonatomic) UIViewController *viewController;
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

static NSString *const DELETED = @"DELETED";
static NSString *const SAVED = @"SAVED";
static NSString *const CANCELED = @"CANCELED";
static NSString *const DONE = @"DONE";
static NSString *const RESPONDED = @"RESPONDED";

- (NSDictionary *)constantsToExport
{
    return @{
             DELETED: DELETED,
             SAVED: SAVED,
             CANCELED: CANCELED,
             DONE: DONE,
             RESPONDED: RESPONDED
             };
}

static NSString *const _eventId = @"eventId";
static NSString *const _title = @"title";
static NSString *const _location = @"location";
static NSString *const _startDate = @"startDate";
static NSString *const _endDate = @"endDate";
static NSString *const _notes = @"notes";
static NSString *const _url = @"url";
static NSString *const _allDay = @"allDay";
static NSString *const _attendees = @"attendees";

static NSString *const MODULE_NAME= @"AddCalendarEvent";


- (EKEventStore *)getEventStoreInstance {
    return [EKEventStoreSingleton getInstance];
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        [self resetPromises];
    }
    return self;
}

#pragma mark -
#pragma mark Dialog methods

RCT_EXPORT_METHOD(presentEventCreatingDialog:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    self.eventOptions = options;
    self.resolver = resolve;
    self.rejecter = reject;
    EKEventEditViewController *controller = [[EKEventEditViewController alloc] init];
    controller.event = [self createNewEventInstance];
    controller.eventStore = [self getEventStoreInstance];
    controller.editViewDelegate = self;
    [self assignNavbarColorsTo:controller.navigationBar];
    [self presentViewController:controller];
}

RCT_EXPORT_METHOD(presentEventViewingDialog:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    self.eventOptions = options;
    self.resolver = resolve;
    self.rejecter = reject;
    EKEventViewController *controller = [[EKEventViewController alloc] init];
    controller.event = [self getEventInstance];
    controller.delegate = self;
    if (options[@"allowsEditing"]) {
        controller.allowsEditing = [RCTConvert BOOL:options[@"allowsEditing"]];
    }
    if (options[@"allowsCalendarPreview"]) {
        controller.allowsCalendarPreview = [RCTConvert BOOL:options[@"allowsCalendarPreview"]];
    }
    UINavigationController *navBar = [[UINavigationController alloc] initWithRootViewController:controller];
    [self assignNavbarColorsTo:navBar.navigationBar];
    [self presentViewController:navBar];
}

-(void)assignNavbarColorsTo: (UINavigationBar *) navigationBar
{
    NSDictionary * navbarOptions = _eventOptions[@"navigationBarIOS"];

    if (navbarOptions) {
        if (navbarOptions[@"tintColor"]) {
            navigationBar.tintColor = [RCTConvert UIColor:navbarOptions[@"tintColor"]];
        }
        if (navbarOptions[@"backgroundColor"]) {
            navigationBar.backgroundColor = [RCTConvert UIColor:navbarOptions[@"backgroundColor"]];
        }
        if (navbarOptions[@"translucent"]) {
            navigationBar.translucent = [RCTConvert BOOL:navbarOptions[@"translucent"]];
        }
        if (navbarOptions[@"barTintColor"]) {
            navigationBar.barTintColor = [RCTConvert UIColor:navbarOptions[@"barTintColor"]];
        }
        if(navbarOptions[@"titleColor"]) {
            UIColor* titleColor = [RCTConvert UIColor:navbarOptions[@"titleColor"]];
            navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: titleColor};
        }
    }
}

RCT_EXPORT_METHOD(presentEventEditingDialog:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    self.eventOptions = options;
    self.resolver = resolve;
    self.rejecter = reject;

    EKEventEditViewController *controller = [[EKEventEditViewController alloc] init];
    [[self getEventStoreInstance] calendarItemWithIdentifier: _eventOptions[_eventId]];
    controller.event = [self getEventInstance];
    controller.eventStore = [self getEventStoreInstance];
    controller.editViewDelegate = self;
    [self assignNavbarColorsTo:controller.navigationBar];
    [self presentViewController:controller];
}

- (void)presentViewController: (UIViewController *) controller {
    self.viewController = RCTPresentedViewController();
    [self.viewController presentViewController:controller animated:YES completion:nil];
}

- (nullable EKEvent *)getEventInstance {
    EKEvent *maybeEvent = [[self getEventStoreInstance] eventWithIdentifier: _eventOptions[_eventId]];
    if (!maybeEvent) {
        maybeEvent = [[self getEventStoreInstance] calendarItemWithIdentifier: _eventOptions[_eventId]];
    }
    return maybeEvent;
}

- (EKEvent *)createNewEventInstance {
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
    if (options[_attendees]) {
        NSArray *invitees = [RCTConvert NSArray:options[_attendees]];

        NSMutableArray *attendees = [NSMutableArray new];
        for (int i = 0; i < [invitees count]; i++) {
            Class className = NSClassFromString(@"EKAttendee");
            id attendee = [className new];
            NSDictionary *invitee = [invitees objectAtIndex:i];
            NSString *name = [invitee valueForKey:@"name"];
            NSString *email = [invitee valueForKey:@"email"];

            [attendee setValue:email forKey:@"emailAddress"];
            if(name && ![name isEqualToString:@"(null)"]) {
                [attendee setValue:name forKey:@"firstName"];
            }
            else {
                [attendee setValue:email forKey:@"firstName"];
            }

            [attendees addObject:attendee];
        }

        [event setValue:attendees forKey:_attendees];
    }
    return event;
}

- (void)rejectPromise: (NSString *) code withMessage: (NSString *) message withError: (NSError *) error {
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
             if (action == EKEventEditViewActionCanceled) {
                 [weakSelf resolveWithAction:CANCELED];
             } else if (action == EKEventEditViewActionSaved) {
                 EKEvent *evt = controller.event;
                 NSDictionary *params = @{
                                          @"eventIdentifier":evt.eventIdentifier,
                                          @"calendarItemIdentifier":evt.calendarItemIdentifier,
                                          };
                 [weakSelf resolveWithAction:SAVED andParams:params];
             } else if (action == EKEventEditViewActionDeleted) {
                 [weakSelf resolveWithAction:DELETED];
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
             if (action == EKEventViewActionDeleted) {
                 [weakSelf resolveWithAction:DELETED];
             } else if (action == EKEventViewActionDone) {
                 [weakSelf resolveWithAction:DONE];
             } else if (action == EKEventViewActionResponded) {
                 [weakSelf resolveWithAction:RESPONDED];
             }
         });
     }];
}

- (void)resolveWithAction: (NSString *)action {
    [self resolvePromise: @{
                             @"action": action
                             }];
}

- (void)resolveWithAction: (NSString *)action andParams: (NSDictionary *) params {
    NSMutableDictionary *extendedArgs = [params mutableCopy];
    [extendedArgs setObject:action forKey:@"action"];
    [self resolvePromise: extendedArgs];
}

- (void)resolvePromise: (id) result {
    if (self.resolver) {
        self.resolver(result);
        [self resetPromises];
    }
}

@end
