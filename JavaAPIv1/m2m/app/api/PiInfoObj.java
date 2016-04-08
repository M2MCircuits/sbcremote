package m2m.app.api;

public class PiInfoObj {
	
	int indexInWeaved;
	String devicealias;
	String deviceaddress;
	String deviceowner;
	int pins;
	
	PiInfoObj(int ind, String al, String add, String own, int p)
	{
		indexInWeaved = ind;
		devicealias = al;
		deviceaddress = add;
		deviceowner = own;
		pins = p;
	}
	
	public int index()
	{
		return indexInWeaved;
	}
	
	public String alias()
	{
		return devicealias;
	}
	
	public String address()
	{
		return deviceaddress;
	}
	
	public String owner()
	{
		return deviceowner;
	}
	
	public int pins()
	{
		return pins;
	}

}
