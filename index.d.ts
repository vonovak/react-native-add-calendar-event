declare module "react-native-add-calendar-event" {
  interface NavigationBarIOS {
    tintColor: string;
    barTintColor: string;
    backgroundColor: string;
    translucent: boolean;
    titleColor: string;
  }

  interface CreateOptions {
    title?: string;
    /**
     * in UTC, format: 'YYYY-MM-DDTHH:mm:ss.SSSZ'
     */
    startDate?: string;
    /**
     * in UTC, format: 'YYYY-MM-DDTHH:mm:ss.SSSZ'
     */
    endDate?: string;
    location?: string;
    allDay?: boolean;
    /**
     * iOS only
     */
    url?: string;
    /**
     * The notes (iOS) or description (Android) associated with the event.
     */
    notes?: string;
    navigationBarIOS?: NavigationBarIOS;
    /*
    * Alert string, could be "0", "1", "2" or "3"
    * 0 => set an alarm at the original startDate
    * 1 => set an alarm 5 minutes before startDate
    * 2 => set an alarm 30 minutes before startDate
    * 3 => set an alarm 60 minutes before startDate
    * if no alert is set in the config, then no alert is set on the reminder
    */
   alert?: string;
  }

  /**
   * These are two different identifiers on iOS.
   * On Android, where they are both equal and represent the event id, also strings.
   */
  interface SuccessAction {
    action: "SAVED";
    calendarItemIdentifier: string;
    eventIdentifier: string;
  }

  interface CancelAction {
    action: "CANCELED";
  }

  interface DeletedAction {
    action: "DELETED";
  }

  interface DoneAction {
    action: "DONE";
  }

  interface RespondedAction {
    action: "RESPONDED";
  }

  type CreateResult = SuccessAction | CancelAction;

  interface EditOptions {
    /**
     * Id of edited event.
     */
    eventId: string;
    /**
     * `ACTION_EDIT` should work for editing events but this doesn't always seem to be the case.
     * This option leaves the choice up to you. By default, the module will use `ACTION_VIEW` which will only
     * show the event, but from there it is easy for the user to tap the edit button and make changes.
     */
    useEditIntent?: boolean;
    navigationBarIOS?: NavigationBarIOS;
  }

  type EditResult = SuccessAction | CancelAction | DeletedAction;

  interface ViewOptions {
    /**
     * Id of edited event.
     */
    eventId: string;
    /**
     * iOS only
     * https://developer.apple.com/documentation/eventkitui/ekeventviewcontroller/1613964-allowsediting?language=objc
     */
    allowsEditing?: boolean;
    /**
     * iOS only
     * https://developer.apple.com/documentation/eventkitui/ekeventviewcontroller/1613956-allowscalendarpreview?language=objc
     */
    allowsCalendarPreview?: boolean;
    navigationBarIOS?: NavigationBarIOS;
  }

  type ViewResult = DoneAction | RespondedAction | DeletedAction;

  class AddCalendarEvent {
    static presentEventCreatingDialog(
      options: CreateOptions
    ): Promise<CreateResult>;
    static presentEventEditingDialog(options: EditOptions): Promise<EditResult>;
    static presentEventViewingDialog(options: ViewOptions): Promise<ViewResult>;
  }

  export = AddCalendarEvent;
}
