import webiopi
import RPi.GPIO as RPIGPIO
import httplib
import json

# Enable debug output
webiopi.setDebug()

chan_list = [2,3,4,17,27,22,10,9,11,5,6,13,19,26,18,23,24,25,8,7,12,16,20,21]

#/etc/weaved/services/Weavedhttp8000.conf
UID = "filenotfound"
# Read conf file
f = open('/etc/weaved/services/Weavedhttp8000.conf', 'r')
contents = f.read()
f.close()

#extract UID
for item in contents.split("\n"):
	if "UID" in item:
		UID = item.split(" ")[1]
		
# import webiopi's GPIO library
webiopiGPIO = webiopi.GPIO

def postToAppEngine(pin):
	URL = "piremote-160105.appspot.com/apns/"
	# is there supposed to be a : at the end?
	# URL = "piremote-160105.appspot.com/apns/:"
	httpServ = httplib.HTTPSConnection(URL, 443)
	httpServ.connect()

	jsonPin = json.dumps({'pin': pin})
	httpServ.request('POST', '/%s' % UID, jsonPin)

	response = httpServ.getresponse()
	if response.status == httplib.OK:
		webiopi.debug("Notification sent to App Engine")
	else:
		webiopi.debug("Notification failed to send")

	httpServ.close()
	
###################### Define the callback functions ##################

def callback(gpio):
	if webiopiGPIO.getFunction(gpio) == webiopiGPIO.IN:
		postToAppEngine(gpio)

# setup() is called by WebIOPi when it starts up
def setup():
	#set the RPi GPIO mode to BCM numbering
	RPIGPIO.setmode(RPIGPIO.BCM)
	
	# Set all GPIO pins as inputs with the RPi.GPIO library.
	# This is hacky because webiopi already controls what the pin types are,
	# but it's necessary in order to set the RPi.GPIO event listeners
	RPIGPIO.setup(chan_list, RPIGPIO.IN)
	
	### TODO: Set pins to previous configuration  ##
	# If we're able to store the prev config in the iOS app,
	# maybe we can send the app a notification at this point
	# which would trigger the configuration push to the pi
	
	# Send iOS app a notification that the pi just restarted.
	# This could be the notification which triggers the pin
	# configuration mentioned above.
	
	
	# Turn off RPi's warnings
	RPIGPIO.setwarnings(False)
	
	# Add event listener for each pin
	for gpio in chan_list:
		RPIGPIO.add_event_detect(gpio, RPIGPIO.BOTH)
		RPIGPIO.add_event_callback(gpio, callback)
	
# destroy() is called by WebIOPi when it shuts down
def destroy():
	# Remove event listeners for each pin
	for gpio in chan_list:
		RPIGPIO.remove_event_detect(gpio)