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

# Store a list of all gpio channel numbers
chan_list = [2,3,4,17,27,22,10,9,11,5,6,13,19,26,18,23,24,25,8,7,12,16,20,21]

# Read conf file
f = open('/etc/weaved/services/Weavedhttp8000.conf', 'r')
contents = f.read()
f.close()

# Extract UID (Weaved/Remot3.it Device ID)
UID = "filenotfound"
for item in contents.split("\n"):
	if "UID" in item:
		UID = item.split(" ")[1]
		
# Import webiopi's GPIO library
webiopiGPIO = webiopi.GPIO

# Store python version
pyVersion = sys.version_info[0]

# Define the gpio pin configuration database path
pinConfigDB = "/etc/webiopi/gpio_config.db"

# This function sends a json encoded message to the App Engine
def postToAppEngine(message):
	# App Engine URL
	URL = "piremote-160105.appspot.com/apns"
	
	# Set content type as json in header
	headers = {"Content-type": "application/json", "Accept": "text/plain"}
	
	# Determine which http library should be used
	if pyVersion < 3:
		# Establish python2 http connection
		conn = httplib.HTTPSConnection(URL, 443)
	else:
		# Establish python3 http connection
		conn = http.client.HTTPSConnection(URL, 443)
	# Send the http POST to App Engine
	conn.request('POST', '/%s' % UID, message, headers)
	# Collect the response
	response = conn.getresponse()
	# Check for errors
	if response.status == 200:
		webiopi.debug("Notification sent to App Engine")
	else:
		webiopi.debug("Notification failed to send")
	# Close the http connection
	conn.close()

###################### Define the callback function ##################
def callback(gpio):
	# Uncomment the following line if only input pins should send notifications
	# if webiopiGPIO.getFunction(gpio) == webiopiGPIO.IN:
	# jsonify the pin
	# message=1 (pin change), funct(Function): 0=input 1=output, val(Value): 0=off(low) 1=on(high)
	jsonPin = json.dumps({'message' : 1, 'pin': gpio, 'funct' : webiopiGPIO.getFunction(gpio), 'val' : webiopiGPIO.digitalRead(gpio)})
	# Post the pin to App Engine
	postToAppEngine(jsonPin)
	
	
# setup() is called by WebIOPi when it starts up
def setup():

	# Send iOS app a notification that the pi just restarted.
	# message=0 (pi restarted)
	restartMessage = json.dumps({'message': 0})
	postToAppEngine(restartMessage)
	
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
		# Fetch pin configuration from DB
		c.execute('SELECT pin, function FROM pins')
		webiopi.debug("fetching contents of pins table")
		pinList = c.fetchall()
		webiopi.debug("Checking if it was empty")
		# If the list is empty, raise exception
		if not pinList:
			webiopi.debug("the table was empty")
			raise sqlite3.OperationalError
		webiopi.debug("setting the pin functions")
		# Set each pin's function according to the database
		for pin in pinList:
			webiopiGPIO.setFunction(pin[0], pin[1])
	except sqlite3.OperationalError:
		# Build new table
		webiopi.debug("Create new pins table")
		try:
			c.execute('CREATE TABLE pins (pin integer, function integer)')
		except sqlite3.OperationalError:
			webiopi.debug("pins table already exists")
			pass
		pinList = []
		# Set the table with default values (input)
		webiopi.debug("filling pins table with default values")
		for gpio in chan_list:
			newFunct = (gpio, 0)
			pinList.append(newFunct)
		# Insert all of the default pin values at once
		c.executemany('INSERT INTO pins VALUES (?,?)', pinList)
		webiopi.debug("Committing new database changes")
		# Commit the database changes
		sqlconn.commit()
	except:
		error = "Unable to access the pin database: " + sys.exc_info()[0]
		webiopi.debug(error)
	webiopi.debug("Closing database")
	sqlconn.close()

# loop() is periodically called by webiopi as it runs
def loop():
	# Get current pin configuration
	pinList = []
	for gpio in chan_list:
		func = webiopiGPIO.getFunction(gpio)
		newFunct = (func, gpio)
		pinList.append(newFunct)
	sqlconn = sqlite3.connect(pinConfigDB)
	c = sqlconn.cursor()
	try:
		# Update the pin configuration in the database
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