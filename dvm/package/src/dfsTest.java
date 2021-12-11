import java.io.*;


public class dfsTest extends Thread {

	public static void copy( String s , String d ) {
	try {
		FileInputStream fi;
		FileOutputStream fo;
		int a;
		byte buff[] = new byte[8192];
		
		 System.out.println( "start : " + s + " -> " + d );		 		
		 
		 fi = new FileInputStream( s );
		 fo = new FileOutputStream( d );
			while( true ) {
				a = fi.read(buff);
				if ( a == -1 ) break;
				fo.write( buff , 0 , a);
			} 
		 fi.close();
		 fo.close();
		}
		catch( Exception e ) {}

	}

  public static void main( String[] args ) {
  
	try {
		dfsTest.copy( "./dvm3.zip" , "@dvm3_1.zip" );
		dfsTest.copy( "./dvm3.zip" , "@dvm3_2.zip" );
		dfsTest.copy( "./dvm3.zip" , "@dvm3_3.zip" );		
		}
		catch( Exception e ) {}
  }
}
