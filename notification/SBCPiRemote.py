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
GPIO = webiopi.GPIO

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
		print "Notification sent to App Engine"
	else:
		print "Notification failed"

	httpServ.close()
	
###################### Define the callback functions ##################

def callback_2(2):
	if GPIO.getFunction(2) == GPIO.IN:
		postToAppEngine(2)
def callback_3(3):
	if GPIO.getFunction(3) == GPIO.IN:
		postToAppEngine(3)
def callback_4(4):
	if GPIO.getFunction(4) == GPIO.IN:
		postToAppEngine(4)
def callback_17(17):
	if GPIO.getFunction(17) == GPIO.IN:
		postToAppEngine(17)
def callback_27(27):
	if GPIO.getFunction(27) == GPIO.IN:
		postToAppEngine(27)
def callback_22(22):
	if GPIO.getFunction(22) == GPIO.IN:
		postToAppEngine(22)
def callback_10(10):
	if GPIO.getFunction(10) == GPIO.IN:
		postToAppEngine(10)
def callback_9(9):
	if GPIO.getFunction(9) == GPIO.IN:
		postToAppEngine(9)
def callback_11(11):
	if GPIO.getFunction(11) == GPIO.IN:
		postToAppEngine(11)
def callback_5(5):
	if GPIO.getFunction(5) == GPIO.IN:
		postToAppEngine(5)
def callback_6(6):
	if GPIO.getFunction(6) == GPIO.IN:
		postToAppEngine(6)
def callback_13(13):
	if GPIO.getFunction(13) == GPIO.IN:
		postToAppEngine(13)
def callback_19(19):
	if GPIO.getFunction(19) == GPIO.IN:
		postToAppEngine(19)
def callback_26(26):
	if GPIO.getFunction(26) == GPIO.IN:
		postToAppEngine(26)
def callback_18(18):
	if GPIO.getFunction(18) == GPIO.IN:
		postToAppEngine(18)
def callback_23(23):
	if GPIO.getFunction(23) == GPIO.IN:
		postToAppEngine(23)
def callback_24(24):
	if GPIO.getFunction(24) == GPIO.IN:
		postToAppEngine(24)
def callback_25(25):
	if GPIO.getFunction(25) == GPIO.IN:
		postToAppEngine(25)
def callback_8(8):
	if GPIO.getFunction(8) == GPIO.IN:
		postToAppEngine(8)
def callback_7(7):
	if GPIO.getFunction(7) == GPIO.IN:
		postToAppEngine(7)
def callback_12(12):
	if GPIO.getFunction(12) == GPIO.IN:
		postToAppEngine(12)
def callback_16(16):
	if GPIO.getFunction(16) == GPIO.IN:
		postToAppEngine(16)
def callback_20(20):
	if GPIO.getFunction(20) == GPIO.IN:
		postToAppEngine(20)
def callback_21(21):
	if GPIO.getFunction(21) == GPIO.IN:
		postToAppEngine(21)

# setup() is called by WebIOPi when it starts up
def setup():
	#set the RPi GPIO mode to BCM numbering
	RPIGPIO.setmode(RPIGPIO.BCM)
	
	# Set all GPIO pins as inputs with the RPi.GPIO library.
	# This is hacky because webiopi already controls what the pin types are,
	# but it's necessary in order to set the RPi.GPIO event listeners
	RPIGPIO.setup(chan_list, GPIO.IN)
	
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
	
	# Set event callback for each pin
	RPIGPIO.add_event_callback(2, callback_2)
	RPIGPIO.add_event_callback(3, callback_3)
	RPIGPIO.add_event_callback(4, callback_4)
	RPIGPIO.add_event_callback(17, callback_17)
	RPIGPIO.add_event_callback(27, callback_27)
	RPIGPIO.add_event_callback(22, callback_22)
	RPIGPIO.add_event_callback(10, callback_10)
	RPIGPIO.add_event_callback(9, callback_9)
	RPIGPIO.add_event_callback(11, callback_11)
	RPIGPIO.add_event_callback(5, callback_5)
	RPIGPIO.add_event_callback(6, callback_6)
	RPIGPIO.add_event_callback(13, callback_13)
	RPIGPIO.add_event_callback(19, callback_19)
	RPIGPIO.add_event_callback(26, callback_26)
	RPIGPIO.add_event_callback(18, callback_18)
	RPIGPIO.add_event_callback(23, callback_23)
	RPIGPIO.add_event_callback(24, callback_24)
	RPIGPIO.add_event_callback(25, callback_25)
	RPIGPIO.add_event_callback(8, callback_8)
	RPIGPIO.add_event_callback(7, callback_7)
	RPIGPIO.add_event_callback(12, callback_12)
	RPIGPIO.add_event_callback(16, callback_16)
	RPIGPIO.add_event_callback(20, callback_20)
	RPIGPIO.add_event_callback(21, callback_21)
	
# destroy() is called by WebIOPi when it shuts down
def destroy():
	# Remove event listeners for each pin
	for gpio in chan_list:
		RPIGPIO.remove_event_detect(gpio)