class adder extends Thread {
  long svalue;
  long evalue;

  public adder( long s, long e) {
    this.svalue = s;
    this.evalue = e;

    System.out.println(  s + ":" + e );
  }
  
	// for jdk 1.4 java compiler
	public void start() {
		super.start();
	}

	public void run() {
    long e;
    long s;
    long t;
				
    s = svalue;
    e = evalue;
    t = 0;
    
    for( long a = s ; a <= e ; a++ ){
	    t = t + a;
    }

    dtsTest.totalValue = dtsTest.totalValue + t;		
    System.out.println( dtsTest.totalValue );
	}
}

public class dtsTest {

  public static long totalValue;

	public dtsTest() {}

  public dtsTest( long maxValue , int threadNumber ) {
  
  	long start;
  	long end;
  	long incValue;
  	
  	
  	start = 1;
  	incValue = maxValue / threadNumber;
  	end = incValue;
  	
  	for( int b = 0 ; b < threadNumber ; b++ ) {
	  	new adder( start , end ).start();
	  	
	  	start = end + 1;
	  	end = end + incValue;
		}  
		
  }

  public static void main( String[] args ) {

		int threadNum = 9;  	
		
		System.out.println( "process test" );
		
		
    new dtsTest(90000000L, threadNum);

    //while( Thread.activeCount() != 1 );
    //System.out.println( "totalValue : " + dtsTest.totalValue );      
    
  }
}
