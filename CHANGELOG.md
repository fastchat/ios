# FastChat 0.7.0-Beta2 #
* Fixed creating groups - you can now create lovely groups.
* 


# FastChat 0.7.0-Beta1 #

* First Beta. This has quite a few bugs, mainly with past groups and usernames not appearing. If it’s obvious, I know about it.

## Known Issues ##
* You can't send images.
* Sometimes usernames don't appear.
* You can't create new group


Holy shit, there is a lot in this release. Let’s go over the big changes.

## Adapter Layout ##
I updated the project to use iOS 8 Adaptive Layout. This means we now have:
* Landscape (FUCK YA), Mike loves me now.
* iPad

All for free. The iPad version isn't great, it's just a big iPhone app. But I also got it for free, so I can update that later. And it all works! It's freaking so cool!

## New Profile Page ##
You can logout, logout from all devices, and we also have some new options. This is a work in progress, but it lays the groundwork for coming features, such as subscriptions, options, preferences, and policy stuff.

## New Message View ##
I swapped out the Message view with a completely new message view. It's super awesome, and has a lot of great benefits. In this process I lost images (sorry), but it's really awesome. New messages coming in and sending have a better animation. Loading the message view is also super fast, so Dave can stop complaining.
* Typing notifications! See when other people are typing. Because fun!
* In App Browser! Super easy to see links super fast. Also you can open those links in Safari/Chrome if you hate it.
* When sending a message, the last word will be autocorrected.
* If you exit a group before sending a message, FastChat remembers the text, and it appears next time you go back to the group.
* Socket.io should NOT disconnect if you are sending a message and background the app. Of course, this may still happen if you lose Internet or something.
* Message view is now smarter about when it “scrolls” to the bottom.
* Updated the image viewer so you can “flick to dismiss it” when not flicking the image itself.

## New Detail Page ##
Groups now each have a Detail page, which allows you to view members in the group, invite new members, and set do not distrub (which doesn't work yet). This is where lots of new group features will be going.

## New "New Group" Page ##
This now looks just like the message view, just with no messages. There's also a great way to add people to the group (I broke it). This will be finished shortly, but it's a huge step forward in creating new groups.
* Added in a cancel button to the create group page.


Randomly:
* Empty groups now have a different background color on the Group Page so it’s super easy to tell when you’re talking to yourself.

* In the making of this build, I’ve updated 3 separate Open Source Projects! Pretty fucking awesome.
