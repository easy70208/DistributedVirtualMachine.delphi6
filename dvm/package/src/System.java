package java.lang;

import java.io.*;

public class System {
  public static PrintStream out = new PrintStream();
  public System() {
  }
  
  public static void arraycopy( char[] s , int soffset , char[] d , int doffset , int len ) {
  	for ( int a = 0 ; a < len ; a++ ){ 
  		d[doffset+a] = s[soffset+a]; 
  		//System.out.println( s[soffset+a] ) ; 
  	}
  }
}
