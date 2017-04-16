import sys
import webiopi
import RPi.GPIO as RPIGPIO
import json
import sqlite3
import os
import requests

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

# App Engine URL
url = "https://piremote-160105.appspot.com/apns/" + UID

# Import webiopi's GPIO library
webiopiGPIO = webiopi.GPIO

# Define the gpio pin configuration database path
pinConfigDB = "/etc/webiopi/gpio_config.db"

# This function sends a json encoded message to the App Engine
def postToAppEngine(jsonMessage):

	# Send the http POST to App Engine
	response = requests.post(url, data=jsonMessage)

	# Check for errors
	if response.status_code == 200:
		webiopi.debug("Notification sent to App Engine")
	else:
		# errorMessage = jsonMessage + " -- Notification failed to send: " + str(response.status_code) + " - " + response.text
		errorMessage = jsonMessage + " -- Notification failed to send: Status Code " + str(response.status_code)
		webiopi.debug(errorMessage)

###################### Define the callback function ##################
def callback(gpio):
	# Uncomment the following line if only input pins should send notifications
	# if webiopiGPIO.getFunction(gpio) == webiopiGPIO.IN:
	# jsonify the pin
	# message=1 (pin change), funct(Function): 0=input 1=output, val(Value): 0=off(low) 1=on(high)
	jsonPin = json.dumps({'message' : 1, 'pin': gpio, 'funct' : webiopiGPIO.getFunction(gpio), 'val' : int(webiopiGPIO.digitalRead(gpio))})
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
	webiopi.debug("Adding event listeners for each pin")
	for gpio in chan_list:
		RPIGPIO.setup(gpio, RPIGPIO.IN)
		# Add event listener for each pin
		RPIGPIO.add_event_detect(gpio, RPIGPIO.BOTH)

	# Set pins to previous configuration
	sqlconn = sqlite3.connect(pinConfigDB)
	c = sqlconn.cursor()
	try:
		# Fetch pin configuration from DB
		c.execute('SELECT pin, function FROM pins')
		webiopi.debug("Fetching contents of -pins- table")
		pinList = c.fetchall()
		webiopi.debug("Checking if -pins- table is empty")
		# If the list is empty, raise exception
		if not pinList:
			webiopi.debug("The -pins- table was empty")
			raise sqlite3.OperationalError
		webiopi.debug("Setting the pin functions")
		# Set each pin's function according to the database
		for pin in pinList:
			webiopiGPIO.setFunction(pin[0], pin[1])
			if pin[1] == webiopiGPIO.OUT:
				webiopiGPIO.digitalWrite(pin[0], webiopiGPIO.LOW)
	except sqlite3.OperationalError:
		# Build new table
		webiopi.debug("Create new -pins- table")
		try:
			c.execute('CREATE TABLE pins (pin integer, function integer)')
		except sqlite3.OperationalError:
			webiopi.debug("-pins- table already exists")
			pass
		pinList = []
		# Set the table with default values (input)
		webiopi.debug("Filling -pins- table with default values")
		for gpio in chan_list:
			newFunct = (gpio, 0)
			pinList.append(newFunct)
		# Insert all of the default pin values at once
		c.executemany('INSERT INTO pins VALUES (?,?)', pinList)
		webiopi.debug("Committing new database changes")
		# Commit the database changes
		sqlconn.commit()
	except:
		error = "Unable to access the pin database: " + str(sys.exc_info()[0])
		webiopi.debug(error)
	webiopi.debug("Closing database")
	sqlconn.close()
	webiopi.debug("Adding event callbacks for each pin")
	# Add event callbacks
	for gpio in chan_list:
		RPIGPIO.add_event_callback(gpio, callback)

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
# def destroy():
	# # Remove event listeners for each pin
	# webiopi.debug("Removing pin listeners")
	# for gpio in chan_list:
		# RPIGPIO.remove_event_detect(gpio)