class addre20_7 extends Thread {
  long svalue;
  long evalue;

  public addre20_7( long s, long e) {
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

    dtsTest20_7.totalValue = dtsTest20_7.totalValue + t;		
    System.out.println( dtsTest20_7.totalValue );
	}
}

public class dtsTest20_7 {

  public static long totalValue;

	public dtsTest20_7() {}

  public dtsTest20_7( long maxValue , int threadNumber ) {
  
  	long start;
  	long end;
  	long incValue;
  	
  	
  	start = 1;
  	incValue = maxValue / threadNumber;
  	end = incValue;
  	
  	for( int b = 0 ; b < threadNumber ; b++ ) {
	  	new addre20_7( start , end ).start();
	  	
	  	start = end + 1;
	  	end = end + incValue;
		}  
		
  }

  public static void main( String[] args ) {

		int threadNum = 20;  	
		
		System.out.println( "process test" );
		
		
    new dtsTest20_7(90000000L, threadNum);

    while( Thread.activeCount() != 1 );
    System.out.println( "totalValue : " + dtsTest20_7.totalValue );      
    
  }
}
