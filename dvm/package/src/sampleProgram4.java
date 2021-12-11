import java.io.*;

public class sampleProgram4 {
	public static void main( String[] args ) {
	
	
		try {
			FileInputStream fis = new FileInputStream("a.txt");
			FileOutputStream fos = new FileOutputStream("@b.txt");
			int a;
		
			while( true ) {
				a = fis.read();
				if( a == -1 ) break;
				fos.write( a );
			}
		}
		catch( Exception e ) {}	
	}
}
