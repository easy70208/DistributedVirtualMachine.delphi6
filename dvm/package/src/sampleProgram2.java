class newTest2 extends Thread {
	int a;
	
	public newTest2(int a){ this.a = a; }
	
	public void start() { super.start(); }
	
	public void run() {
		int c = 0;
		
		for( int b = 0 ; b < a ; b++ ) 
			c = c + b;

		System.out.println( this.a );
	}
	
}

public class sampleProgram2 {
	public static void main( String[] args ) {
		newTest2 t = new newTest2( 10 );
		t.start();
	}
}
