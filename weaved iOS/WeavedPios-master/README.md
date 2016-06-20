# WeavedPios
An iPhone app allowing you to control your Raspberry Pi's GPIOs through Weaved and WebioPi on iOS
programmed with Xcode in swift

Basic goals of this project:

1. Allow the user to Log in to Weaved (done)
2. Allow the user to select a Raspberry Pi that has WebIOPi installed on it (done)
3. Allow the user to monitor and control the GPIO pins on the Pi, as long as they are logged in (done)
4. Allow the user to label GPIOs, label their 'high' and 'low' states (so for Water, you could have "flow" and "stop") (done)
5. Allow the user to choose which GPIOs to ignore, so that they aren't cluttered with 16 pins on their app

6. Allow the user to configure notifications, so that they can be notified of a monitor pin moving, even if they are not logged in
7. Allow the user to set pins to be "persistent," which is to say that if the Pi reboots, the pin will set itself to where it was before it rebooted. Or set them to NOT be persistent, and to start off as "off" or "on"
8. Think of a better name than "WeavedPios"



April 29, 2016
This version is in Xcode 7.2

faq

1. "How do I compile this?"

Simply download Attempt2, Attempt2.xcodeproj, and Attempt2Tests, put them in the same folder somewhere on your mac, and open Attempt2.xcodeproj with Xcode. Once you've successfully imported the project, click the play button to compile and run. You may have to set the Target to iOS 9.1 or earlier.


2. "What does this do that the official Weaved and WebIOPi apps don't do?"

The notifications, labeling, and persistency should make this a bit more convenient than the official Weaved and WebIOPi apps.
