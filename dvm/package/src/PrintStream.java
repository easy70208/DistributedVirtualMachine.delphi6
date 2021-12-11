package java.io;

public class PrintStream {

  public PrintStream() {
  }

  public native void print( char c );
  public native void println( char c );

  public native void print( int v );
  public native void println( int v );

  public native void print( long v );
  public native void println( long v );

  public native void print( String s );
  public native void println( String s );
  
  public void print( boolean b ) {
  	if ( b == true ) 
  		print( "true" );
  	else 
  		print("false");
  }
  public void println( boolean b ) {
  	if ( b == true ) 
  		println( "true" );
  	else 
  		println("false");
  }
}
