import jess.*;
public class RunJESS {

	
	public static void main(String[] args) {	
		
		Rete r = new Rete();
		try {
			
			r.batch("restaurant.clp");
		} catch (JessException e) {
			e.printStackTrace();
		}

	}

}
