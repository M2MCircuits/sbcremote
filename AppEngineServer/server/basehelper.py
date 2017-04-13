import webapp2
import os
import json
import time
import logging
from google.appengine.ext import ndb
from models import Account
from google.appengine.ext.webapp import blobstore_handlers
from google.appengine.api import app_identity
import time
from apns import APNs, Frame, Payload

"""
Main Helper class with helper methods for writing results and JSON.
"""
class MainHelperClass(webapp2.RequestHandler):


    cert_path = "pimote-cert.pem"
    key_path = "pimote-key.pem"

    def writeJson(self, dictionary):
        # self.response.headers.add_header("Access-Control-Allow-Origin", "*")
        self.response.out.write(json.dumps(dictionary))

    def writeResponse(self, response):
        responseDictionary = {"response" : response}
        self.writeJson(responseDictionary)

    def writeSucessfulResponse(self, info):
        responseDictionary = {"response": "Sucess",
                                "data" : response}
        self.writeJson(responseDictionary)

    def writeErrorResponse(self, info):
        response_dict = {"response" : "Error",
                            "info" : info}
        self.writeJson(response_dict)
   
    def jsonifyRequestBody(self):
        return json.loads(self.request.body)

    def validateAccount(self, serviceID):
        key = ndb.Key(Account, serviceID)
        profile = key.get()
        if profile:
            return profile
        else:
            return None



    def sendAPN(self, alert, phone_token, customdata):
        logging.info("APN getting setup..")
        apns = APNs(use_sandbox=True, cert_file="pimote-cert.pem", key_file="pimote-key.pem")
        payload = Payload(alert=alert, custom={'data': customdata}, sound="default", badge=0, content_available = True)
        apns.gateway_server.send_notification(phone_token, payload)
        logging.info("APN sucessfully sent.")



