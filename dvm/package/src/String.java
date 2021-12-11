package java.lang;

public class String {

  public char[] b;
  
  public String( StringBuffer s ) {
  	this.b = s.b;
  }

  public String(char[] b) {
    this.b = b;
  }

  public String( String b ) {
    this( b.b );
  }
  
  public  String(int offset, int count, char value[]) {
    	b = new char[count];
    	
    	for( int a = 0 ; a < count ; a++ ) this.b[a] = value[offset+a];
			
    }
  
    public String(char value[], int offset, int count) {
    	
    	b = new char[count];
    	
    	for( int a = 0 ; a < count ; a++ ) this.b[a] = value[offset+a];
    }  
  
  public int length() {
  	return b.length;
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
    public static String valueOf(Object obj) {
	return (obj == null) ? "null" : obj.toString();
    }
      
    public static String valueOf(boolean b) {
	return b ? "true" : "false";
    }

    public static String valueOf(char c) {
	char data[] = {c};
	return new String(0, 1, data);
    }

    public static String valueOf(int i) {
        return Integer.toString(i, 10);
    }

    public static String valueOf(long l) {
        return Long.toString(l, 10);
    }
  
    public static String valueOf(float f) {
	return Float.toString(f);
    }

    public static String valueOf(double d) {
	return Double.toString(d);
    }    

    
    public void getChars(int srcBegin, int srcEnd, char dst[], int dstBegin) {
        System.arraycopy(b, srcBegin, dst, dstBegin,
             srcEnd - srcBegin);
    }
    
    public String substring(int beginIndex, int endIndex) {
	    return new String( beginIndex, endIndex , b);
    }    
    
/*    public CharSequence subSequence(int beginIndex, int endIndex) {
        return this.substring(beginIndex, endIndex);
    }    
  */  
  
public char[] toCharArray() {
	char result[] = new char[b.length];
	getChars(0, b.length, result, 0);
	return result;
    }  
    
    
    
    public int indexOf(int ch) {
	return indexOf(ch, 0);
    }

    /**
     * Returns the index within this string of the first occurrence of the
     * specified character, starting the search at the specified index.
     * <p>
     * If a character with value <code>ch</code> occurs in the character
     * sequence represented by this <code>String</code> object at an index
     * no smaller than <code>fromIndex</code>, then the index of the first
     * such occurrence is returned--that is, the smallest value <i>k</i>
     * such that:
     * <blockquote><pre>
     * (this.charAt(<i>k</i>) == ch) && (<i>k</i> &gt;= fromIndex)
     * </pre></blockquote>
     * is true. If no such character occurs in this string at or after
     * position <code>fromIndex</code>, then <code>-1</code> is returned.
     * <p>
     * There is no restriction on the value of <code>fromIndex</code>. If it
     * is negative, it has the same effect as if it were zero: this entire
     * string may be searched. If it is greater than the length of this
     * string, it has the same effect as if it were equal to the length of
     * this string: <code>-1</code> is returned.
     *
     * @param   ch          a character.
     * @param   fromIndex   the index to start the search from.
     * @return  the index of the first occurrence of the character in the
     *          character sequence represented by this object that is greater
     *          than or equal to <code>fromIndex</code>, or <code>-1</code>
     *          if the character does not occur.
     */
    public int indexOf(int ch, int fromIndex) {
	int max = b.length;
	char v[] = b;

	if (fromIndex < 0) {
	    fromIndex = 0;
	} else if (fromIndex >= b.length) {
	    // Note: fromIndex might be near -1>>>1.
	    return -1;
	}
	for (int i = fromIndex ; i < max ; i++) {
	    if (v[i] == ch) {
		return i;
	    }
	}
	return -1;
    }    
    
    
static int indexOf(char[] source, int sourceOffset, int sourceCount,
                       char[] target, int targetOffset, int targetCount,
                       int fromIndex) {
	if (fromIndex >= sourceCount) {
            return (targetCount == 0 ? sourceCount : -1);
	}
    	if (fromIndex < 0) {
    	    fromIndex = 0;
    	}
	if (targetCount == 0) {
	    return fromIndex;
	}

        char first  = target[targetOffset];
        int i = sourceOffset + fromIndex;
        int max = sourceOffset + (sourceCount - targetCount);

    startSearchForFirstChar:
        while (true) {
	    /* Look for first character. */
	    while (i <= max && source[i] != first) {
		i++;
	    }
	    if (i > max) {
		return -1;
	    }

	    /* Found first character, now look at the rest of v2 */
	    int j = i + 1;
	    int end = j + targetCount - 1;
	    int k = targetOffset + 1;
	    while (j < end) {
		if (source[j++] != target[k++]) {
		    i++;
		    /* Look for str's first char again. */
		    continue startSearchForFirstChar;
		}
	    }
	    return i - sourceOffset;	/* Found whole string. */
        }
    }
    
    static int lastIndexOf(char[] source, int sourceOffset, int sourceCount,
                           char[] target, int targetOffset, int targetCount,
                           int fromIndex) {
        /*
	 * Check arguments; return immediately where possible. For
	 * consistency, don't check for null str.
	 */
        int rightIndex = sourceCount - targetCount;
	if (fromIndex < 0) {
	    return -1;
	}
	if (fromIndex > rightIndex) {
	    fromIndex = rightIndex;
	}
	/* Empty string always matches. */
	if (targetCount == 0) {
	    return fromIndex;
	}

        int strLastIndex = targetOffset + targetCount - 1;
	char strLastChar = target[strLastIndex];
	int min = sourceOffset + targetCount - 1;
	int i = min + fromIndex;

    startSearchForLastChar:
	while (true) {
	    while (i >= min && source[i] != strLastChar) {
		i--;
	    }
	    if (i < min) {
		return -1;
	    }
	    int j = i - 1;
	    int start = j - (targetCount - 1);
	    int k = strLastIndex - 1;

	    while (j > start) {
	        if (source[j--] != target[k--]) {
		    i--;
		    continue startSearchForLastChar;
		}
	    }
	    return start - sourceOffset + 1;
	}
    }    
    
    
    public char charAt(int index) {
        return b[index ];
    }    

}
