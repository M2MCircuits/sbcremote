package m2m.app.api;


import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;


import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.entity.StringEntity;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import org.json.simple.JSONArray;


public class weavedapi 
{

	static final String API_USER_LOGIN = "https://api.weaved.com/v22/api/user/login/";
	static final String API_LIST_ALL = "https://api.weaved.com/v22/api/device/list/all";
	static final String API_CONNECT = "https://api.weaved.com/v22/api/device/connect";
	static final String API_CONTENT_TYPE = "content-type";
	static final String API_APPLICATION_JSON = "application/json";
	static final String API_APPLICATION_KEY = "apikey";
	static final String API_WEAVED_DEMO_KEY = "WeavedDemoKey$2015";
	static final String API_DEVICETYPE_PI = "00:07:00:00:00:01:00:00:04:30:1F:40";
	
	
	private String tokenid = "";
	private ArrayList<rasppi> piList = null;
	
	weavedapi()
	{
		tokenid = "";
	}
	
	private String getToken()
	{
		return this.tokenid;
	}
	
	private void setToken(String t)
	{
		this.tokenid = t;
	}
	
	
	//API calls
	public boolean login(String usr, String psw)
	{
		String URL = API_USER_LOGIN + usr + "/" + psw;
		String dumpStr = "";
		String tokstr = "";
		
		try 
		{
			HttpClient httpAgent = new DefaultHttpClient();
			HttpGet httpGet = new HttpGet(URL);
			httpGet.setHeader(API_CONTENT_TYPE, API_APPLICATION_JSON);
			httpGet.setHeader(API_APPLICATION_KEY, API_WEAVED_DEMO_KEY);

			HttpResponse httpResponse = httpAgent.execute(httpGet);
			
			BufferedReader rd = new BufferedReader(new InputStreamReader(httpResponse.getEntity().getContent()));
      		String line = "";
		
			while ((line = rd.readLine()) != null) 
			{
				dumpStr = dumpStr + line + "\n";

			}
			
		} 
		catch (Exception e) 
		{
			// error handling
		}
		
		tokstr = this.basicParse(dumpStr, "token");
		this.setToken(tokstr);

		return true;
		
	}
	
	private String connect(String deviceaddress)
	{
		String URL = API_CONNECT;
		String dumpStr = "";
		String proxystr = "";
		//IMPORTAMT MOTE: hostip does not seem to affect request so is left blank
		String data = "{\"deviceaddress\":\"" + deviceaddress + "\", \"hostip\":\"36.143.180.96\",\"wait\":\"true\"}";
		
		try 
		{
			HttpClient httpAgent = new DefaultHttpClient();
			HttpPost httpPost = new HttpPost(URL);
			httpPost.setHeader(API_CONTENT_TYPE, API_APPLICATION_JSON);
			httpPost.setHeader(API_APPLICATION_KEY, API_WEAVED_DEMO_KEY);
			httpPost.setHeader("token", this.getToken());
			StringEntity postData = new StringEntity(data);
			httpPost.setEntity(postData);

			HttpResponse httpResponse = httpAgent.execute(httpPost);
			
			BufferedReader rd = new BufferedReader(new InputStreamReader(httpResponse.getEntity().getContent()));
      		String line = "";
		
			while ((line = rd.readLine()) != null) 
			{
				dumpStr = dumpStr + line + "\n";

			}
			
		} 
		catch (Exception e) 
		{
			// error handling
		}
		
		proxystr = this.proxyParse(dumpStr);

		return proxystr;
	}
	
	private void newPiList()
	{
		piList = new ArrayList<rasppi>();
	}
	
	private void addPi(String deval, String devadd, String devown)
	{
		rasppi newPi = new rasppi(deval, devadd, devown);
		this.piList.add(newPi);
	}
	
	protected void setup(boolean saved)
	{
		if(saved)
		{
			setup_saved();
		}
		else
		{
			setup_new();
		}
	}
	
	private void setup_saved()
	{
		//to be implemented if needed
	}
	
	private void setup_new()
	{
		this.newPiList();
		
		String rawList = this.listAll();
		int size = 0;
		try{
		JSONParser parser = new JSONParser();
		Object obj = parser.parse(rawList);
		JSONObject devicesOuter = (JSONObject) obj;
		JSONArray devices = (JSONArray) devicesOuter.get("devices");
		size = devices.size();
		} catch (ParseException e)
		{
			//error handling
		}
		
		for(int i = 0; i < size; i++)
		{
			boolean devicetype = (this.deviceParse(rawList, i, "devicetype")).equals(API_DEVICETYPE_PI);
			boolean devicestate = (this.deviceParse(rawList, i, "devicestate")).equals("active");
			boolean servicetitle = (this.deviceParse(rawList, i, "servicetitle")).equals("HTTP");
			boolean webenabled = (this.deviceParse(rawList, i, "webenabled")).equals("1");
			if(devicetype && devicestate && servicetitle && webenabled)
			{
				String deviceAlias = this.deviceParse(rawList, i, "devicealias");
				String deviceAddress = this.deviceParse(rawList, i, "deviceaddress");
				String deviceOwner = this.deviceParse(rawList, i, "ownerusername");
				this.addPi(deviceAlias, deviceAddress, deviceOwner);
			}
		}
		
	}
	
	
	public void updatePi(int index)
	{
		rasppi currentPi = this.getPi(index);
		currentPi.update();
	}
	
	public int getPiListSize()
	{
		return this.piList.size();
	}
	
	private rasppi getPi(int i)
	{
		return piList.get(i);
	}
	
	public void setPiCreds(int index,String usr, String psw)
	{
		rasppi currentPi = this.getPi(index);
		currentPi.setCreds(usr, psw);
		
	}
	
	public void genPiProxy(int index)
	{
		rasppi currentPi = this.getPi(index);
		String proxy = this.connect(currentPi.getAddress());
		currentPi.setProxy(proxy);
		
	}
	
	public void setupPi(int index, boolean saved)
	{
		rasppi currentPi = this.getPi(index);
		currentPi.setup(saved);
	}

	
	private String listAll()
	{
		String URL = API_LIST_ALL;
		String returnStr = "";
		
		try 
		{
			HttpClient httpAgent = new DefaultHttpClient();
			HttpGet httpGet = new HttpGet(URL);
			httpGet.setHeader(API_CONTENT_TYPE, API_APPLICATION_JSON);
			httpGet.setHeader(API_APPLICATION_KEY, API_WEAVED_DEMO_KEY);
			httpGet.setHeader("token", this.getToken());

			HttpResponse httpResponse = httpAgent.execute(httpGet);

			BufferedReader rd = new BufferedReader(new InputStreamReader(
					httpResponse.getEntity().getContent()));
			String line = "";

			while ((line = rd.readLine()) != null) {
				returnStr = returnStr + line + "\n";

			}

		} catch (Exception e) {
			// error handling
		}
		
		return returnStr;
		
		
		
	}
	
	
	private String basicParse(String rawin, String field)
	{
		String returnstr = "";
		try 
		{

			JSONParser parser = new JSONParser();
			Object obj = parser.parse(rawin);

			JSONObject getField = (JSONObject) obj;
			String fieldResult = (String) getField.get(field);


			returnstr = fieldResult;
		} catch (ParseException p) {
			// error handling code
		}
		return returnstr;

	}
	
	private String deviceParse(String devraw, int devindex, String field )
	{
		JSONParser parser = new JSONParser();
		String requestedField = "";

		try 
		{

			Object obj = parser.parse(devraw);

			JSONObject devicesOuter = (JSONObject) obj;

			JSONArray devices = (JSONArray) devicesOuter.get("devices");
			JSONObject specified = (JSONObject) devices.get(devindex);
			requestedField = (String) specified.get(field);
		} 
		catch (Exception e) 
		{
			// error handling
		}
		
		return requestedField;
	}
	
	private String proxyParse(String rawcon)
	{
		JSONParser parser = new JSONParser();
		String requestedField = "";

		try 
		{

			Object obj = parser.parse(rawcon);

			JSONObject connectOuter = (JSONObject) obj;

			JSONObject connection = (JSONObject) connectOuter.get("connection");
			requestedField = (String) connection.get("proxy");
			
		} 
		catch (Exception e) 
		{
			// error handling
		}
		
		return requestedField;
	}
	
	//pi get methods
	public String getPiAlias(int index)
	{
		rasppi currentPi = this.getPi(index);
		return currentPi.getAlias();
	}
	
	public String getPiAddress(int index)
	{
		rasppi currentPi = this.getPi(index);
		return currentPi.getAddress();
	}
	
	public String getPiOwner(int index)
	{
		rasppi currentPi = this.getPi(index);
		return currentPi.getOwner();
	}
	
	public int getPiSize(int index)
	{
		rasppi currentPi = this.getPi(index);
		return currentPi.getSize();
	}

	//including this function for consistency, should simply return pin
	public int getPiPinNumber(int index, int pin)
	{
		rasppi currentPi = this.getPi(index);
		return currentPi.getPinNumber(pin, true);
	}
	
	public String getPiPinName(int index, int pin)
	{
		rasppi currentPi = this.getPi(index);
		return currentPi.getPinName(pin, true);
	}
	
	public boolean isPiPinPersistent(int index, int pin)
	{
		rasppi currentPi = this.getPi(index);
		return currentPi.isPinPersitent(pin, true);
	}
	
	public String getPiPinHighLabel(int index, int pin)
	{
		rasppi currentPi = this.getPi(index);
		return currentPi.getPinHighLabel(pin, true);
	}
	
	public String getPiPinLowLabel(int index, int pin)
	{
		rasppi currentPi = this.getPi(index);
		return currentPi.getPinLowLabel(pin, true);
	}
	
	public boolean addPiPinPersistence(int index, int pin)
	{
		rasppi currentPi = this.getPi(index);
		return currentPi.addPinPersistence(pin, true);
	}
	
	public boolean removePiPinPersistence(int index, int pin)
	{
		rasppi currentPi = this.getPi(index);
		return currentPi.removePinPersistence(pin, true);
	}
	
	//setter methods for pins
	public String setPiPinName(int index, int pin, String newname)
	{
		rasppi currentPi = this.getPi(index);
		return currentPi.setPinName(pin, newname, true);
	}
	
	public String setPiPinHighLabel(int index, int pin, String newname)
	{
		rasppi currentPi = this.getPi(index);
		return currentPi.setPinHighLabel(pin, newname, true);
	}
	
	public String setPiPinLowLabel(int index, int pin, String newname)
	{
		rasppi currentPi = this.getPi(index);
		return currentPi.setPinLowLabel(pin, newname, true);
	}
	
	
	//get an array of valid pin numbers for specified pi
	public ArrayList<Integer> validPiPinNumbers(int index)
	{
		rasppi currentPi = this.getPi(index);
		return currentPi.validPinNumbers();
	}
	
	//WebIOPi REST API methods
	public String GetPiGPIOState(int piIndex, boolean update)
	{
		rasppi currentPi = this.getPi(piIndex);
		String st = currentPi.GetGPIOState();
		if(update)
		{
			currentPi.update();
		}
		return st;
		
	}
	
	public boolean GetPiGPIOPinFunction(int piIndex, int pinNumber, boolean update)
	{
		rasppi currentPi = this.getPi(piIndex);
		boolean fun = currentPi.GetGPIOfunction(pinNumber);
		if(update)
		{
			currentPi.update();
		}
		return fun;
		
	}
	
	public boolean GetPiGPIOPinValue(int piIndex, int pinNumber, boolean update)
	{
		rasppi currentPi = this.getPi(piIndex);
		boolean val = currentPi.GetGPIOvalue(pinNumber);
		if(update)
		{
			currentPi.update();
		}
		return val;
		
	}
	
	public String SetPiGPIOPinFunction(int piIndex, int pinNumber, boolean fun, boolean update)
	{
		rasppi currentPi = this.getPi(piIndex);
		String ret = currentPi.SetGPIOfunction(pinNumber, fun);
		if(update)
		{
			currentPi.update();
		}
		return ret;
		
	}
	
	public String SetPiGPIOPinValue(int piIndex, int pinNumber, boolean val, boolean update)
	{
		rasppi currentPi = this.getPi(piIndex);
		String ret = currentPi.SetGPIOvalue(pinNumber, val);
		if(update)
		{
			currentPi.update();
		}
		return ret;
		
	}
	
	//methods specifying the boolean value associated with certain parameters
	
	//which boolean value represents HIGH input/output (true)
	public boolean getPinHighBool()
	{
		return pipin.GPIO_VALUE_HIGH;
	}
	//which boolean value represents LOW input/output (false)
	public boolean getPinLowBool()
	{
		return pipin.GPIO_VALUE_LOW;
	}
	//which boolean value represents IN (input pin) (true)
	public boolean getPinInBool()
	{
		return pipin.GPIO_FUNCTION_IN;
	}
	//which boolean value represents OUT (output pin) (false)
	public boolean getPinOutBool()
	{
		return pipin.GPIO_FUNCTION_OUT;
	}
	
	public String exportPiJSON(int index)
	{
		return (this.getPi(index)).toString();
	}
	
	public String exportPiPinJSON(int index, int pin)
	{
		rasppi currentPi = this.getPi(index);
		return currentPi.exportPinJSON(pin, true);
	}
	
	public ArrayList<PinInfoObj> getPiPinInfoArray(int piIndex)
	{
		rasppi currentPi = this.getPi(piIndex);
		return currentPi.getPinInfoArray();
	}
	
	public ArrayList<PiInfoObj> getPiInfoArray(int index)
	{
		ArrayList<PiInfoObj> retArr = new ArrayList<PiInfoObj>();
		int max = this.getPiListSize();
		rasppi currentPi;
		for(int i = 0; i < max; i++)
		{
			currentPi = this.getPi(i);
			PiInfoObj newInfo = new PiInfoObj(i, currentPi.getAlias(), currentPi.getAddress(), currentPi.getOwner(), currentPi.getSize());
			retArr.add(newInfo);
			
		}
		return retArr;
		
	}
	
	public void logout()
	{
		//this function is meant to log user out from weaved session but currently only discards data
		this.newPiList();
		this.setToken("");
	}
	
}
