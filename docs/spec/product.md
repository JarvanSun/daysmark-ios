# Product

What a user can do. A behaviour that is not here is not built; a feature changes this file before
its code.

## What Daysmark is

- An iPhone and iPad app for important dates: countdowns (which keep counting up after the day
  has passed), birthdays and anniversaries. All three are one kind of event; they differ only by
  category.
- It is not a task or calendar tool. No screen uses task language: no "done", "due", "overdue",
  progress or strikethrough.
- The app follows the system's appearance and app language; it has no switch of its own for
  either.

## Events

- An event has a title, a start date, an optional end date, an optional time, a calendar system
  (Gregorian, Chinese lunar, Islamic Umm al-Qura), a repeat rule (never, monthly, yearly), one
  category, an illustrated icon, reminders and special reminder nodes.
- **Dates are what the user saw.** An event stores calendar components, never an instant or a
  time zone: an all-day event stays on the same calendar day everywhere, a timed event at the same
  local time.
- **Strict dates.** An invalid date is rejected, never moved: 30 February does not exist, a
  monthly event on the 31st skips shorter months, a yearly event on 29 February happens only in
  leap years.
- A repeating event always shows its next occurrence. A range counts to its start, then to its
  end ("starts in 12 days", "ends in 3 days", "ended 2 days ago").
- A past one-time event stays, counting up, until the user deletes it.

## Relative time

Every surface that shows how far an event is uses one complete, localized phrase.

| State | English | German | Simplified Chinese |
|---|---|---|---|
| Future | in 12 days | in 12 Tagen | 还有 12 天 |
| Past | 12 days ago | vor 12 Tagen | 已经 12 天 |
| The day itself | Today | Heute | 今天 |
| One day away | Tomorrow / Yesterday | Morgen / Gestern | 明天 / 昨天 |

- Never "0 days", "12 days left", `D-12` or a bare number beside a title.
- An all-day event counts days. A timed event counts days until its day, hours on that day and
  minutes in the last hour. Seconds tick only in event detail and in a Live Activity.
- Future and past are never told apart by color alone.

## Home

The only root screen. No tab bar.

- **Focus.** The top shows one event: the one the user pinned, otherwise the event nearest to now
  in either direction. Pinning another replaces it.
- **Landscape.** An illustration behind the focus: past on the left, future on the right, a dot
  for today; its hills grow with the number of events on each side.
- **Filters.** One row of categories with "All" first. It filters the list for the session.
- **List.** Every matching event: today and future first by distance, then past. Each row shows
  the title, the phrase and the absolute date. Long text wraps; it is never truncated.
- Leading swipe pins or unpins; trailing swipe shares or deletes. Select starts batch deletion.
- Search is the system search field and ignores the filters.
- With no events Home shows an "Add" button; with no match, "Reset filters".
- On iPad in regular width, Home is the sidebar of a split view.

## Event detail and editor

- Detail shows the title, the date, a large number with its phrase and a ticking line of days,
  hours, minutes and seconds. Tapping the number cycles days, weeks, hours and minutes. Share is
  the main action; the toolbar holds the pin toggle and Edit. On the event's day, confetti falls
  once.
- When two devices edited the event at the same time, detail lists the versions and the user
  keeps one.
- One editor sheet creates and edits; a new event needs only a title and a date. A live preview
  row follows the draft. With unsaved changes the sheet cannot be swiped away. Editing shows
  "Delete event" at the bottom.

## Categories

- Three built-in categories (Important Date, Birthday, Anniversary) cannot be renamed or deleted.
  The user adds, renames, deletes and reorders custom ones.
- A category only groups and filters; it never changes how an event counts, looks or reminds.
- Deleting a category moves its events to Important Date.

## Deleting

- Delete moves an event to Recently Deleted for 30 days; it leaves Home, widgets, reminders and
  Spotlight at once.
- Recently Deleted restores or deletes permanently, one or many. After 30 days an event is
  deleted permanently by itself. A deleted event never comes back from another device.

## Reminders

- Notifications are local. An event has any number of ordinary reminders (days before at a time
  of day, or minutes before a timed event).
- Special nodes, off by default: 100, 30, 7 and 1 days before; 100, 500 and 1000 days since; the
  1st, 5th and 10th anniversary; or a custom number. All nodes of an event share one time of day.
- Permission is asked when the user first adds a reminder, never at launch.
- A notification's title is the event's title, its body the phrase for that moment. Tapping it
  opens the event.

## Importing

- Birthdays from Contacts and dates from the system calendar, started in Settings. Permission is
  asked at that moment.
- An import is a one-time copy; the app never writes back. A rescan lists what is new, changed or
  conflicting.

## Onboarding, sharing and settings

- Onboarding is a welcome page, the user's own birthday, then ready-made events, all selected.
  Every step can be skipped and none asks for a permission. The created events are ordinary
  events.
- Sharing renders an event to a static card (title, phrase, absolute date, icon) and opens the
  system share sheet.
- Settings is pushed from Home: notifications, categories, import, how to add widgets, the app's
  language in system Settings, Siri and Shortcuts, Recently Deleted, and the version. There is no
  account.

## Outside the app

Widgets, Live Activities, Siri and Shortcuts, Spotlight and notifications are in
[system-surfaces.md](system-surfaces.md). They show the same phrase, order and focus as the app,
and none of them deletes anything.

## Sync and privacy

- Events, categories, reminders, the focus and deletions sync through the user's private iCloud
  database. A conflict is kept and shown, never resolved silently.
- Contact and calendar identifiers stay on the device that imported them.
- No analytics, no tracking, no third-party SDK that sends data.

## Not built

Tasks and calendar views; photos, notes and user-chosen colors; widgets that edit or delete;
deleting or editing reminders through Siri; shared events and accounts; generative models of any
kind.
