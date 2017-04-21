#import "AddCalendarEvent.h"


@implementation AddCalendarEvent

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

static NSString *const _id = @"id";
static NSString *const _calendarId = @"calendarId";
static NSString *const _title = @"title";
static NSString *const _location = @"location";
static NSString *const _startDate = @"startDate";
static NSString *const _endDate = @"endDate";
static NSString *const _allDay = @"allDay";
static NSString *const _notes = @"notes";
static NSString *const _url = @"url";


- (EKEventStore *) getEventStoreInstance {
    if (self.eventStore == nil){
        self.eventStore = [[EKEventStore alloc] init];
    }
    return self.eventStore;
}

- (id) init {
    self = [super init];
    if (self != nil) {
        self.eventStore = nil;
        self.calendarAccessGranted = NO;
        self.defaultCalendar = nil;
    }
    return self;
}


RCT_EXPORT_METHOD(presentNewEventDialog:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    self.viewController = RCTPresentedViewController();
    self.eventOptions = options;
    [self checkEventStoreAccessForCalendar];
    if (self.calendarAccessGranted) {
        [self showCalendarEventModal];
    }
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
    
    
    addController.event = event;

    
    addController.eventStore = [self getEventStoreInstance];
    addController.editViewDelegate = self;
    [self.viewController presentViewController:addController animated:YES completion:nil];
}

-(void)accessGrantedForCalendar
{
    // Let's get the default calendar associated with our event store
    self.defaultCalendar = self.eventStore.defaultCalendarForNewEvents;
    self.calendarAccessGranted = YES;
}

// Prompt the user for access to their Calendar
-(void)requestCalendarAccess
{
    [[self getEventStoreInstance] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             self.calendarAccessGranted = YES;
             [self showCalendarEventModal];
//             RootViewController * __weak weakSelf = self;
//             // Let's ensure that our code will be executed from the main queue
//             dispatch_async(dispatch_get_main_queue(), ^{
//                 // The user has granted access to their Calendar; let's populate our UI with all events occuring in the next 24 hours.
//                 [weakSelf accessGrantedForCalendar];
//             });
         }
     }];
}

-(void)checkEventStoreAccessForCalendar
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (status)
    {
            // Update our UI if the user has granted access to their Calendar
        case EKAuthorizationStatusAuthorized: [self accessGrantedForCalendar];
            break;
            // Prompt the user for access to Calendar if there is no definitive answer
        case EKAuthorizationStatusNotDetermined: [self requestCalendarAccess];
            break;
            // Display a message if the user has denied or restricted access to Calendar
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Privacy Warning" message:@"Permission was not granted for Calendar"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self.viewController presentViewController:alert animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark EKEventEditViewDelegate

// Overriding EKEventEditViewDelegate method to react to user action
- (void)eventEditViewController:(EKEventEditViewController *)controller
          didCompleteWithAction:(EKEventEditViewAction)action
{
    //AddCalendarEvent * __weak weakSelf = self;
    // Dismiss the modal view controller
    [self.viewController dismissViewControllerAnimated:YES completion:^
     {
//         if (action != EKEventEditViewActionCanceled)
//         {
//             dispatch_async(dispatch_get_main_queue(), ^{
//                 // Re-fetch all events happening in the next 24 hours
//                 weakSelf.eventsList = [self fetchEvents];
//                 // Update the UI with the above events
//                 [weakSelf.tableView reloadData];
//             });
//         }
     }];
}

@end
  
