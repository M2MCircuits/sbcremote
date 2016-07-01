package m2m.app.api;

public class pipin {
	

	static final boolean GPIO_FUNCTION_IN = true;
	static final boolean GPIO_FUNCTION_OUT = false;
	static final boolean GPIO_VALUE_HIGH = true;
	static final boolean GPIO_VALUE_LOW = false;
	
	private boolean pin_function; //function of the pin
	private int pin_number; //number of the pin on the physical GPIO
	private String pin_name; //assigned alias for pin
	private boolean pin_state; //true = high, false = low
	private String pin_high_label; //label to display when pin is high
	private String pin_low_label; //label to display when pin is low
	
	pipin()
	{
		pin_function = GPIO_FUNCTION_IN;
		pin_number = -1;
		pin_name = String.valueOf(pin_number);
		pin_state = false;
		pin_high_label = "HIGH";
		pin_low_label = "LOW";
		
		
	}
	
	pipin( boolean pfun, int pinum, String pinam, boolean pist, String pihi, String pilo)
	{
		pin_function = pfun;
		pin_number = pinum;
		pin_name = pinam;
		pin_state = pist;
		pin_high_label = pihi;
		pin_low_label = pilo;
	}
	
	pipin( boolean pfun, int pinum, boolean pist)
	{
		pin_function = pfun;
		pin_number = pinum;
		pin_name = String.valueOf(pin_number);
		pin_state = pist;
		pin_high_label = "HIGH";
		pin_low_label = "LOW";
	}
	
	//getter methods follow
	protected boolean getFunction()
	{
		return pin_function;
	}
	
	protected int getNumber()
	{
		return pin_number;
	}
	
	protected String getName()
	{
		return pin_name;
	}
	
	protected boolean getState()
	{
		return pin_state;
	}
	
	protected String getHighLabel()
	{
		return pin_high_label;
	}
	
	protected String getLowLabel()
	{
		return pin_low_label;
	}

	
	//setter methods follow
	protected boolean setFunction(boolean gf)
	{

		pin_function = gf;
		return pin_function;
	}
	
	protected int setNumber(int i)
	{
		pin_number = i;
		return pin_number;
	}
	
	protected String setName(String sn)
	{
		pin_name = sn;
		return pin_name;
	}
	
	//function must always be set before state
	protected boolean setState(boolean hl)
	{
		if (this.getFunction() == GPIO_FUNCTION_OUT) 
		{
			pin_state = hl;
		}
		return pin_state;
	}
	
	protected String setHighLabel(String hl)
	{
		pin_high_label = hl;
		return pin_high_label;
	}
	
	protected String setLowLabel(String ll)
	{
		pin_low_label = ll;
		return pin_low_label;
	}
	
	@Override
	public String toString()
	{
		return "{" + "\"number\":" + "\"" + this.getNumber() + "\"" + ","  + "\"function\":" + "\"" + this.getFunction() + "\"" + ","  + "\"name\":" + "\"" + this.getName() + "\"" + ","  + "\"state\":" + "\"" + this.getState() + "\"" + "," + "\"high\":" + "\"" + this.getHighLabel() + "\"" + ","  + "\"low\":" + "\"" + this.getLowLabel() + "\"" + "}";
	}

	
	
}
