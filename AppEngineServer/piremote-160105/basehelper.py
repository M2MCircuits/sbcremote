import webapp2
import os
import json
import time
import logging
from google.appengine.ext import ndb
from google.appengine.ext.webapp import blobstore_handlers
from google.appengine.api import app_identity
import time
from apns import APNs, Frame, Payload

"""
Main Helper class with helper methods for writing results and JSON.
"""
class MainHelperClass(webapp2.RequestHandler):


    def writeJson(self, dictionary):
        # self.response.headers.add_header("Access-Control-Allow-Origin", "*")
        self.response.out.write(json.dumps(dictionary))

    def writeResponse(self, response):
        responseDictionary = {"response" : response}
        self.writeJson(responseDictionary)

    def writeSucessfulResponse(self, parameter, response):
        responseDictionary = {"response": "Sucess",
                                parameter : response}
        self.writeJson(responseDictionary)

    def writeErrorResponse(self, info):
        response_dict = {"response" : "Error",
                            "info" : info}
        self.writeJson(response_dict)
   
    def jsonifyRequestBody(self, requestBody):
        return json.loads(requestBody)


    def sendAPN(self, alert, token, customdata):
        logging.info("APN getting setup..")
        apns = APNs(use_sandbox=False, cert_file='cert.pem', key_file='key.pem')
        payload = Payload(alert=alert, custom={'data': customdata}, sound="default", badge=0, content_available = True)
        apns.gateway_server.send_notification(token, payload)
        logging.info("APN sucessfully sent.")



