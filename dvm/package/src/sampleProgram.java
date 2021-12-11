import java.io.*;

class sdvmfileIOTestByOrginalRequest {
	
	public static void start() {
	
		System.out.println( "sdvmfileIOTest : a.txt -> b.txt" );
		
		try {
				FileInputStream fis = new FileInputStream("a.txt");
				FileOutputStream fos = new FileOutputStream("b.txt");
				int a;
		
				while( true ) {
					a = fis.read();
					if( a == -1 ) break;
					fos.write( a );
				}
				
				fis.close();
				fos.close();
			}
		catch( Exception e ) {}	
	}
}

class sdvmfileIOTestByRemoteRequest {

	public static void start() {

		System.out.println( "sdvmfileIOTest : a.txt -> @b.txt" );
			
		try {
			FileInputStream fis = new FileInputStream("a.txt");
			FileOutputStream fos = new FileOutputStream("@b.txt");
			int a;
		
			while( true ) {
				a = fis.read();
				if( a == -1 ) break;
				fos.write( a );
			}
			
				fis.close();
				fos.close();
			
		}
		catch( Exception e ) {}	
	}
}

class sdvmThreadTest extends Thread {
	int a;
	
	public sdvmThreadTest(int a){ this.a = a; }
	
	public void start() { super.start(); }
	
	public void run() {
	
		System.out.println( "sdvmThreadTest : start" );
		
		int aa = a;		
		int cc = 0;
		
		for( int b = 1 ; b <= aa ; b++ ) 
			cc = cc + b;

		System.out.println( cc );
	}
	
}

class sdvmbasicTest {
	int a;
	static int intFieldValue = 1;
	static long longFieldValue = 2;
	static String test="Hello World";
	
	public sdvmbasicTest(int a){
		this.a = a;
	}
	
	public void start() {
	
		System.out.println( "sdvmbasicTest" );
		
		int a = sdvmbasicTest.intFieldValue;
		a = a + 1;
		System.out.println( a );
		
		long b = sdvmbasicTest.longFieldValue;
		b = b + 1;
		System.out.println( b );
		
		System.out.println( sdvmbasicTest.test );
	
	}
}

public class sampleProgram {

	public static void main( String[] args ) {
	
		new sdvmbasicTest(10).start();
		
		new sdvmThreadTest(100).start();
		
		sdvmfileIOTestByOrginalRequest.start();
		
		sdvmfileIOTestByRemoteRequest.start();
	
	}
}
