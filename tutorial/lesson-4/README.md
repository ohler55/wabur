
# WABuR Tutorial Lesson 4

In this lesson a custom controller is created to add a read-only timestamp to
the blog entries.

It would be nice to have an indication of when a blog entry was created. That
should not be left up to the author and it should not be editable. There are a
few things that need to be done to implement this feature. First the
controller should be updated so that on create a timestamp is added. Next the
view and edit displays should show the timestamp as read only.

 - [Controller](#controller)
 - [Displays](#displays)

## Controller

TBD
inherit from WAB::OpenController
add when to data
update configs
  wabur.conf
  opo-rub.conf

## Displays


TBD
note use of 'alt' for time format
items are in a table