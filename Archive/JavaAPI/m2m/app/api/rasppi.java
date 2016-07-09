package m2m.app.api;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;


import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.auth.BasicScheme;
import org.apache.http.auth.UsernamePasswordCredentials;

import org.json.simple.JSONObject;
import org.json.simple.JSONArray;
import org.json.simple.parser.ParseException;
import org.json.simple.parser.JSONParser;


public class rasppi {
	
	
	//constants
	static final boolean GPIO_FUNCTION_IN = pipin.GPIO_FUNCTION_IN;
	static final boolean GPIO_FUNCTION_OUT = pipin.GPIO_FUNCTION_OUT;
	static final boolean GPIO_VALUE_HIGH = pipin.GPIO_VALUE_HIGH;
	static final boolean GPIO_VALUE_LOW = pipin.GPIO_VALUE_LOW;

	private String devicealias; //the name assigned to the device on weaved
	private String deviceaddress; //unique address for the device on weaved
	private String deviceowner; //owner of device (on Weaved)
	private ArrayList<pipin> GPIO; //contains information about each GPIO pin as a pipin object
	
	private String webiopiusername; //username for WebIOPi
	private String webiopipassword; //password for WebIOPi
	
	private String deviceproxy; //proxy URL through which WebIOPi can be accessed

	
	rasppi()
	{
		devicealias = "";
		deviceaddress = "";
		deviceowner = "";
		webiopiusername = "";
		webiopipassword = "";
		deviceproxy = "";

	}
	
	rasppi(String deval, String devadd, String devown)
	{
		devicealias = deval;
		deviceaddress = devadd;
		deviceowner = devown;
		deviceproxy = "";
		webiopiusername = "";
		webiopipassword = "";

	}
	
	//set credentials which will be used for HTTP requests
	protected boolean setCreds(String usr, String psw)
	{
		webiopiusername = usr;
		webiopipassword = psw;
		return true;
	}
	
	//specify proxy
	protected String setProxy(String URL)
	{
		//be sure proxy ends in slash
		if(URL.substring(URL.length() - 1) != "/")
		{
			URL = URL + "/";
		}
		deviceproxy = URL;
		return deviceproxy;
	}
	
	//getter methods
	protected String getAlias()
	{
		return devicealias;
	}
	
	protected String getAddress()
	{
		return deviceaddress;
	}
	
	protected String getOwner()
	{
		return deviceowner;
	}
	
	protected String getProxy()
	{
		return deviceproxy;
	}
		
	protected int getSize()
	{
		return GPIO.size();
	}
	
	//setter methods
	protected String setAlias(String al)
	{
		devicealias = al;
		return devicealias;
	}
	
	protected String setAddress(String add)
	{
		deviceaddress = add;
		return deviceaddress;
	}
	
	protected String setOwner(String own)
	{
		deviceowner = own;
		return deviceowner;
	}
	
	
	//REST API helper method
	private String APIRequests(String request_param, boolean isGET) {
		String response = "";
		try {
			//string containing URL and parameters for request
			String requestString = this.getProxy() + request_param;
			HttpClient httpClient = new DefaultHttpClient();
			HttpResponse httpResponse;
			if (isGET) {
				//send get request to URL
				HttpGet httpAgent = new HttpGet(requestString);
				//authenticate request with username and password
				httpAgent.addHeader(BasicScheme.authenticate(
						new UsernamePasswordCredentials(webiopiusername,
								webiopipassword), "UTF-8", false));
				//send request
				httpResponse = httpClient.execute(httpAgent);
			} else {
				//similar as above except a post request was sent
				HttpPost httpAgent = new HttpPost(requestString);
				httpAgent.addHeader(BasicScheme.authenticate(
						new UsernamePasswordCredentials(webiopiusername,
								webiopipassword), "UTF-8", false));
				httpResponse = httpClient.execute(httpAgent);
			}

			//read response
			BufferedReader rd = new BufferedReader(new InputStreamReader(
					httpResponse.getEntity().getContent()));
			String line = "";
			while ((line = rd.readLine()) != null) {
				response = response + line + "\n";
			}

		} catch (IOException e) {
			// error handling
		}

		return response;

	}
	
	//REST API functions for WebIOPi
	protected String GetGPIOState()
	{
		return APIRequests("*", true);
	}
	
	//returns true = "in" or false = "out"
	protected boolean GetGPIOfunction(int pin)
	{
		String parstring = "GPIO/" + String.valueOf(pin) + "/function";
		String response = APIRequests(parstring, true);
		response = response.toLowerCase();
		response = response.trim();
		
		if(response.equals("in"))
		{
			return GPIO_FUNCTION_IN;
		}
		else if(response.equals("0"))
		{
			return GPIO_FUNCTION_OUT;
		}
		else
		{
			//error handling to be added
			return false;
		}
	}
	
	//returns true = HIGH or false = LOW
	protected boolean GetGPIOvalue(int pin)
	{
		String parstring = "GPIO/" + String.valueOf(pin) + "/value";
		String response = APIRequests(parstring, true);
		response = response.toLowerCase();
		response = response.trim();
		
		if(response.equals("1"))
		{
			return GPIO_VALUE_HIGH;
		}
		else if(response.equals("0"))
		{
			return GPIO_VALUE_LOW;
		}
		else
		{
			//error handling to be added
			return false;
		}
	}
	
	//set functions return the response to the POST requests
	protected String SetGPIOfunction(int pin, boolean fun)
	{
		String pin_function;
		
		if(fun == GPIO_FUNCTION_IN)
		{
			pin_function = "in";
		}
		else
		{
			pin_function = "out";
		}
		
		String parstring = "GPIO/" + String.valueOf(pin) + "/function/" + pin_function;
		String response = APIRequests(parstring, false);

		return response;
		
	}
	
	protected String SetGPIOvalue(int pin, boolean val)
	{
		String pin_value;
		
		if(val == GPIO_VALUE_HIGH)
		{
			pin_value = "1";
		}
		else
		{
			pin_value = "0";
		}
		
		String parstring = "GPIO/" + String.valueOf(pin) + "/value/" + pin_value;
		String response = APIRequests(parstring, false);

		
		return response;
		
	}
	

	
	//GPIO related methods
	
	//create the GPIO array
	private void createGPIO()
	{

		GPIO = new ArrayList<pipin>();

	}
	
	private void trimGPIO()
	{
		GPIO.trimToSize();
	}
	
	
	//returns pin at index
	private pipin getPin(int index)
	{
		return GPIO.get(index);
	}
	
	//returns pin with specified pin number
	private pipin getPinDeep(int pinNumber)
	{
		pipin foundPin = null;
		int max = this.getSize();
		for(int i = 0; i < max; i++)
		{
			int currentNum = (this.getPin(i)).getNumber();
			if(currentNum == pinNumber)
			{
				foundPin = this.getPin(i);
			}
		}
		return foundPin;
		
		
	}
	
	//getter methods to access pin getter methods
	protected boolean getPinFunction(int index, boolean deep)
	{
		pipin currentPin = null;
		if(deep)
		{
			currentPin = this.getPin(index);
		}
		else
		{
			currentPin = this.getPinDeep(index);
		}
		
		return currentPin.getFunction();
	}
	
	protected int getPinNumber(int index, boolean deep)
	{
		pipin currentPin = null;
		if(deep)
		{
			currentPin = this.getPin(index);
		}
		else
		{
			currentPin = this.getPinDeep(index);
		}
		
		return currentPin.getNumber();
	}
	
	protected String getPinName(int index, boolean deep)
	{
		pipin currentPin = null;
		if(deep)
		{
			currentPin = this.getPin(index);
		}
		else
		{
			currentPin = this.getPinDeep(index);
		}
		
		return currentPin.getName();
	}
	
	
	protected String getPinHighLabel(int index, boolean deep)
	{
		pipin currentPin = null;
		if(deep)
		{
			currentPin = this.getPin(index);
		}
		else
		{
			currentPin = this.getPinDeep(index);
		}
		
		return currentPin.getHighLabel();
	}
	
	protected String getPinLowLabel(int index, boolean deep)
	{
		pipin currentPin = null;
		if(deep)
		{
			currentPin = this.getPin(index);
		}
		else
		{
			currentPin = this.getPinDeep(index);
		}
		
		return currentPin.getLowLabel();
	}
	
	
	protected ArrayList<Integer> validPinNumbers() 
	{
		ArrayList<Integer> returnList = new ArrayList<Integer>();
		pipin currentPin;
		int max = this.getSize();
		for (int i = 0; i < max; i++) 
		{
			currentPin = this.getPin(i);
			returnList.add(new Integer(currentPin.getNumber()));

		}
		return returnList;
	}
	
	//setter methods for pins
	protected String setPinName(int index, String newname, boolean deep)
	{
		pipin currentPin = null;
		if(deep)
		{
			currentPin = this.getPin(index);
		}
		else
		{
			currentPin = this.getPinDeep(index);
		}
		
		return currentPin.setName(newname);
	}
	
	protected String setPinHighLabel(int index, String newlab, boolean deep)
	{
		pipin currentPin = null;
		if(deep)
		{
			currentPin = this.getPin(index);
		}
		else
		{
			currentPin = this.getPinDeep(index);
		}
		
		return currentPin.setHighLabel(newlab);
	}
	
	protected String setPinLowLabel(int index, String newlab, boolean deep)
	{
		pipin currentPin = null;
		if(deep)
		{
			currentPin = this.getPin(index);
		}
		else
		{
			currentPin = this.getPinDeep(index);
		}
		
		return currentPin.setLowLabel(newlab);
	}
	
	
	
	private void addPin(int pin_number, boolean pin_function, String pin_name, boolean pin_state, String pin_high_label, String pin_low_label)
	{
		pipin newPin = new pipin(pin_function, pin_number, pin_name, pin_state, pin_high_label, pin_low_label);
		GPIO.add(newPin);
	}
	
	private void addPin(int pin_number, boolean pin_function, boolean pin_state)
	{
		pipin newPin = new pipin(pin_function, pin_number, pin_state);
		GPIO.add(newPin);
	}
	
	protected void setup(boolean saved, String param)
	{
		if(saved)
		{
			this.setup_saved(param);
		}
		else
		{
			this.setup_new();
		}
		
	}
	
	//if there is a saved configuration for this pi's GPIO
	private void setup_saved(String param)
	{
		//add code
		
	}
	
	//setup from current state
	private void setup_new()
	{
		String piState = this.GetGPIOState();
		this.createGPIO();
		int pinTotal = 0;
		//get number if pins
		try {
			JSONParser counter = new JSONParser();

			Object obj1 = counter.parse(piState);

			JSONObject jsonCount = (JSONObject) obj1;
			JSONObject jsonPins = (JSONObject) jsonCount.get("GPIO");
			pinTotal = (int) jsonPins.size();
			// pin indexing starts at 0
		} catch (ParseException p) {
			// error handling;
		}

		
		
		for(int i = 0; i < pinTotal; i++)
		{
			String pinVal = this.GPIOparse(piState, i, "value");
			String pinFun = this.GPIOparse(piState, i, "function");
			
			if(pinVal.equals("0") || pinVal.equals("1"))
			{

				if(pinFun.equalsIgnoreCase("in") || pinFun.equalsIgnoreCase("out"))
				{

					boolean pinFunBool, pinValBool;
					if(pinVal.equals("0"))
					{
						pinValBool = GPIO_VALUE_LOW;
					}
					else
					{
						pinValBool = GPIO_VALUE_HIGH;
					}
					
					if(pinFun.equalsIgnoreCase("in"))
					{
						pinFunBool = GPIO_FUNCTION_IN;
					}
					else
					{
						pinFunBool = GPIO_FUNCTION_OUT;
					}
					
					this.addPin(i, pinFunBool, pinValBool);
				}
			}
		}
		this.trimGPIO();
	}
	
	
	protected void update()
	{
		String piState = this.GetGPIOState();
		int pinTotal = this.getSize();
		
		for (int i = 0; i < pinTotal; i++) 
		{
			pipin current_pin = this.getPin(i);
			int pinNum = current_pin.getNumber();
			String pinVal = this.GPIOparse(piState, pinNum, "value");
			String pinFun = this.GPIOparse(piState, pinNum, "function");
			if (pinVal.equals("0") || pinVal.equals("1")) 
			{
				if (pinFun.equalsIgnoreCase("in")
						|| pinFun.equalsIgnoreCase("out")) 
				{
					boolean pinFunBool, pinValBool;
					if (pinVal.equals("0")) 
					{
						pinValBool = GPIO_VALUE_LOW;
					} 
					else 
					{
						pinValBool = GPIO_VALUE_HIGH;
					}

					if (pinFun.equalsIgnoreCase("in")) 
					{
						pinFunBool = GPIO_FUNCTION_IN;
					} 
					else 
					{
						pinFunBool = GPIO_FUNCTION_OUT;
					}

					//function must always be set before state
					current_pin.setFunction(pinFunBool);
					current_pin.setState(pinValBool);
				}
			}
		}

	}
	
	private String GPIOparse(String gpioraw, int pin, String field)
	{
		String returnstr = "";
		try {
			String pinstr = String.valueOf(pin);

			JSONParser parser = new JSONParser();
			Object obj = parser.parse(gpioraw);

			JSONObject gpiojson = (JSONObject) obj;
			JSONObject pinsjson = (JSONObject) gpiojson.get("GPIO");
			JSONObject singlepinjson = (JSONObject) pinsjson.get(pinstr);
			int val = ((Long) singlepinjson.get("value")).intValue();
			String fun = (String) singlepinjson.get("function");

			if (field.equalsIgnoreCase("value")) {
				returnstr = Integer.toString(val);
			} else if (field.equalsIgnoreCase("function")) {
				returnstr = fun;
			} else {
				returnstr = "";
			}

			return returnstr;
		} catch (ParseException p) {
			// error handling code
		}
		return returnstr;

	}
	
	protected ArrayList<PinInfoObj> getPinInfoArray()
	{
		ArrayList<PinInfoObj> infoList = new ArrayList<PinInfoObj>();
		pipin nextPin;
		int max = this.getSize();
		for(int i = 0; i < max; i++)
		{
				nextPin = this.getPin(i);
				PinInfoObj infoPin =  new PinInfoObj(nextPin.getNumber(), nextPin.getName(), nextPin.getFunction(), nextPin.getState(), nextPin.getHighLabel(), nextPin.getLowLabel());
				infoList.add(infoPin);
			
		}

		
		return infoList;
	}
	
	protected String exportPinJSON(int index, boolean deep)
	{
		pipin currentPin = null;
		if(deep)
		{
			currentPin = this.getPin(index);
		}
		else
		{
			currentPin = this.getPinDeep(index);
		}
		
		return currentPin.toString();
	}
	
	@Override
	public String toString()
	{
		int size = this.getSize();
		String representation = "";
		representation = representation + "{" + "\"" + this.getAlias() + "\": {\n";
		representation = representation + "\"owner\":" + "\"" + this.getOwner() + "\",\n";
		representation = representation + "\"address\":" + "\"" + this.getAddress() + "\",\n";
		representation = representation + "\"GPIO\": [ \n";
		
		for(int i = 0; i < size; i++)
		{
			pipin next_pin = this.getPin(i);
			representation = representation + next_pin.toString();
			if(i == size - 1)
			{
				representation = representation + "\n";
			}
			else
			{
				representation = representation + ",\n";
			}
		}
		representation = representation + "\n]}}";
		return representation;
	}

	
}
