# sbcremote
SBC remote for M2M Circuits

## Summary

A mobile application for Android and iOS that allows the user to remotely monitor and configure the GPIO ports of Raspberry Pis and other single-board computers.

## Description

This is an open-source mobile application which enables users to remotely manipulate the GPIO unit of a Raspberry Pi. The project builds on top of emerging technology such as the Maker Modem, Weaved, and WebIOPi to remotely control single-board computers. The mobile application will integrate WebIOPi to let users control their Raspberry Pis remotely. The GUI will contain a configuration screen that will allow the user to change I/O signals. Additionally, the user will be notified when I/O signals change or some event occurs.

## Installation

To set up WebIOPI and Weaved, follow the steps given here: http://webiopi.trouch.com/INSTALL.html. This step includes creating an account with Weaved and downloading Weaved onto your single board computer.

Once Weaved is installed, you can download the app to your mobile device.

## Usage

On opening the app, a login screen for Weaved will pop up, allowing the user to provide their username and password.

After signing in, the user will be presented with a device screen, which will list the devices associated with the Weaved account.

After choosing a device, the user will be taken to a control screen, which will list the control pins' states and names, show the status of each pin in real time, and allow the user to set the pins to high or low.

From the control screen, the user will be able to go to a configuration page, which will have app settings and customizable GPIO pin names. It will also allow the user to rename the high and low states for each pin, set each pin's natural state to Monitor, Control, or Ignore, and allow the user to enable push notifications, a feature that will let the user know when a pin switches states.

## Link to wiki
Additional documentation for the Weaved and WebIOPi APIs, in addition to a short explanation of weavedapi public methods, can be found on the wiki:
https://github.com/siddhesh-singh/sbcremote/wiki

##  Design Team
J. Hunter Heard,
Luke New,
Siddhesh Pratap Singh,
Peter Welsh

## Sponsored by

Jesse Lee and Don Powrie of M2M Circuits and Miguel Razo of the UTDallas Computer Science department
