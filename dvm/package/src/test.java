public class test extends Thread {
	long t;
	
	
	public void start() {
		t = 1234567890L;

		super.start();
	}
	
	public void run() {
	
		
		System.out.println( t );
		
		t = t + 8765432199L;
		
		System.out.println( t );
		
		t++;
		
		System.out.println( t );
		
		t--;					
		
		System.out.println( t );
		
		t = t - 1234567890L;		
		
		System.out.println( t );		
				
				
	}
	
	public static void main( String[] args ) {
		new test().start();
	}
	
	
}
