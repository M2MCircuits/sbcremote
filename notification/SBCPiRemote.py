import sys
import webiopi
import RPi.GPIO as RPIGPIO
import json
import sqlite3
import os
if sys.version_info[0] < 3:
	import httplib
else:
	import http.client

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

# store python version
pyVersion = sys.version_info[0]

pinConfigDB = "/etc/webiopi/gpio_config.db"

def postToAppEngine(message):
	URL = "piremote-160105.appspot.com/apns"
	
	headers = {"Content-type": "application/json", "Accept": "text/plain"}
	
	if pyVersion < 3:
		conn = httplib.HTTPSConnection(URL, 443)
	else:
		conn = http.client.HTTPSConnection(URL, 443)
		
	conn.request('POST', '/%s' % UID, message, headers)
	response = conn.getresponse()
	if response.status == 200:
		webiopi.debug("Notification sent to App Engine")
	else:
		webiopi.debug("Notification failed to send")
	conn.close()

###################### Define the callback functions ##################
def callback(gpio):
	# if webiopiGPIO.getFunction(gpio) == webiopiGPIO.IN:
	jsonPin = json.dumps({'pin': gpio})
	# postToAppEngine(jsonPin)
	webiopi.debug("Notification sent to App Engine")
	
	
# setup() is called by WebIOPi when it starts up
def setup():

	# Send iOS app a notification that the pi just restarted.
	# restartMessage = json.dumps({'message': 'pi restarted'})
	# postToAppEngine(restartMessage)
	webiopi.debug("Notification - Webiopi restarted")
	
	# Turn off RPi's warnings
	RPIGPIO.setwarnings(False)
	
	#set the RPi GPIO mode to BCM numbering
	RPIGPIO.setmode(RPIGPIO.BCM)
	
	# Use the RPi.GPIO library to setup each pin as its current state.
	# This is hacky because webiopi already controls what the pin types are,
	# but it's necessary in order to set the RPi.GPIO event listeners
	# RPIGPIO.setup(chan_list, RPIGPIO.IN)
	webiopi.debug("Setting all pins as input")
	for gpio in chan_list:
		RPIGPIO.setup(gpio, RPIGPIO.IN)
		# Add event listener for each pin
		RPIGPIO.add_event_detect(gpio, RPIGPIO.BOTH)
		RPIGPIO.add_event_callback(gpio, callback)
	
	# Set pins to previous configuration
	sqlconn = sqlite3.connect(pinConfigDB)
	c = sqlconn.cursor()
	try:
		webiopi.debug("Attempting to access database")
		c.execute('SELECT pin, function FROM pins')
		webiopi.debug("fetching contents of pins table")
		pinList = c.fetchall()
		webiopi.debug("Checking if it was empty")
		if not pinList:
			webiopi.debug("the table was empty")
			raise sqlite3.OperationalError
		webiopi.debug("setting the pin functions")
		for pin in pinList:
			webiopiGPIO.setFunction(pin[0], pin[1])
	except sqlite3.OperationalError:
		# Build new table
		webiopi.debug("Attempting to create new pins table")
		try:
			c.execute('CREATE TABLE pins (pin integer, function integer)')
			webiopi.debug("Attempting to create new pins table")
		except sqlite3.OperationalError:
			webiopi.debug("pins table created")
			pass
		pinList = []
		webiopi.debug("filling pins table with default values")
		for gpio in chan_list:
			newFunct = (gpio, 0)
			pinList.append(newFunct)
		c.executemany('INSERT INTO pins VALUES (?,?)', pinList)
		webiopi.debug("Committing new database changes")
		sqlconn.commit()
	except:
		error = "Unable to access the pin database: " + sys.exc_info()[0]
		webiopi.debug(error)
	webiopi.debug("Closing database")
	sqlconn.close()

def loop():
	pinList = []
	for gpio in chan_list:
		func = webiopiGPIO.getFunction(gpio)
		newFunct = (func, gpio)
		pinList.append(newFunct)
	sqlconn = sqlite3.connect(pinConfigDB)
	c = sqlconn.cursor()
	try:
		c.executemany('UPDATE pins SET function=? WHERE pin=?', pinList)
		sqlconn.commit()
	except:
		error = "Unable to update the pin database: " + sys.exc_info()[0]
		webiopi.debug(error)
	sqlconn.close()
	webiopi.sleep(1)

# destroy() is called by WebIOPi when it shuts down
def destroy():
	# Remove event listeners for each pin
	webiopi.debug("Removing pin listeners")
	for gpio in chan_list:
		RPIGPIO.remove_event_detect(gpio)