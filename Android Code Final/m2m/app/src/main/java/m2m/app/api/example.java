package m2m.app.api;



public class example
{
	
	public static void main(String[] args)
	{
		System.out.println("testing");
		weavedapi WeavedAPI = new weavedapi();
		WeavedAPI.login("siddhesh.singh@utdallas.edu", "newpass2");
		WeavedAPI.setup(false);
		WeavedAPI.setPiCreds(0, "webiopi","raspberry");
		WeavedAPI.genPiProxy(0);
		WeavedAPI.setupPi(0, false, "");
		System.out.println(WeavedAPI.getPiInfoArray().get(0).alias());
		
	}
	
}
