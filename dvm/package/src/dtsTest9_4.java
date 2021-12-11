class addre9_4 extends Thread {
  long svalue;
  long evalue;

  public addre9_4( long s, long e) {
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

    dtsTest9_4.totalValue = dtsTest9_4.totalValue + t;		
    System.out.println( dtsTest9_4.totalValue );
	}
}

public class dtsTest9_4 {

  public static long totalValue;

	public dtsTest9_4() {}

  public dtsTest9_4( long maxValue , int threadNumber ) {
  
  	long start;
  	long end;
  	long incValue;
  	
  	
  	start = 1;
  	incValue = maxValue / threadNumber;
  	end = incValue;
  	
  	for( int b = 0 ; b < threadNumber ; b++ ) {
	  	new addre9_4( start , end ).start();
	  	
	  	start = end + 1;
	  	end = end + incValue;
		}  
		
  }

  public static void main( String[] args ) {

		int threadNum = 9;  	
		
		System.out.println( "process test" );
		
		
    new dtsTest9_4(90000L, threadNum);

    while( Thread.activeCount() != 1 );
    System.out.println( "totalValue : " + dtsTest9_4.totalValue );      
    
  }
}
