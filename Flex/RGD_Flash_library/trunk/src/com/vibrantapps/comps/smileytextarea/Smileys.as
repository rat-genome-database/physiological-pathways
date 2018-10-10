/*
Copyright (c) 2007 vibrant apps

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
package com.vibrantapps.comps.smileytextarea
{
	public class Smileys
	{
		/* EMBED SMILEYS */
			//here are all the smileys
     	    [Embed(source="/assets/lib.swf", symbol="smi_smile")]
    	    public static var smi_smile:Class;
    	    
	        [Embed(source="/assets/lib.swf", symbol="smi_ask")]
    	    public static var smi_ask:Class;
			
			[Embed(source="/assets/lib.swf", symbol="smi_awe")]
    	    public static var smi_awe:Class;
			
			[Embed(source="/assets/lib.swf", symbol="smi_baby")]
    	    public static var smi_baby:Class;
			
			[Embed(source="/assets/lib.swf", symbol="smi_cool")]
    	    public static  var smi_cool:Class;
    	    
    	    [Embed(source="/assets/lib.swf", symbol="smi_evil")]
    	    public static  var smi_evil:Class;

			[Embed(source="/assets/lib.swf", symbol="smi_fuck")]
    	    public static  var smi_fuck:Class;
    	    
    	    [Embed(source="/assets/lib.swf", symbol="smi_grin")]
    	    public static  var smi_grin:Class;

			[Embed(source="/assets/lib.swf", symbol="smi_heart")]
    	    public static  var smi_heart:Class;

			[Embed(source="/assets/lib.swf", symbol="smi_kiss")]
    	    public static  var smi_kiss:Class;
    	    
    	    [Embed(source="/assets/lib.swf", symbol="smi_laugh")]
    	    public static  var smi_laugh:Class;
    	    
    	    [Embed(source="/assets/lib.swf", symbol="smi_newline")]
    	    public static  var smi_newline:Class;
    	    
    	    [Embed(source="/assets/lib.swf", symbol="smi_ninja")]
    	    public static  var smi_ninja:Class;
    	    
    	    [Embed(source="/assets/lib.swf", symbol="smi_red")]
    	    public static  var smi_red:Class;
    	    
    	    [Embed(source="/assets/lib.swf", symbol="smi_roll")]
    	    public static  var smi_roll:Class;
    	    
    	    [Embed(source="/assets/lib.swf", symbol="smi_roll_eyes")]
    	    public static  var smi_roll_eyes:Class;

     	  	[Embed(source="/assets/lib.swf", symbol="smi_sad")]
    	    public static  var smi_sad:Class;
    	    
    	    [Embed(source="/assets/lib.swf", symbol="smi_slash")]
    	    public static  var smi_slash:Class;
    	    
    	    [Embed(source="/assets/lib.swf", symbol="smi_sleep")]
    	    public static  var smi_sleep:Class;
    	    
    	    [Embed(source="/assets/lib.swf", symbol="smi_tongue")]
    	    public static  var smi_tongue:Class;
    	    
    	    [Embed(source="/assets/lib.swf", symbol="smi_weird")]
    	    public static  var smi_weird:Class;
    	    
    	    [Embed(source="/assets/lib.swf", symbol="smi_whistle")]
    	    public static  var smi_whistle:Class;
    	    
	     	[Embed(source="/assets/lib.swf", symbol="smi_wink")]
    	    public static  var smi_wink:Class;
    	    
    	    [Embed(source="/assets/lib.swf", symbol="smi_wonder")]
    	    public static  var smi_wonder:Class;

			public static  var smileys:Array = [smi_smile,
											smi_ask,
											smi_awe,
											smi_baby,
											smi_cool,
											smi_evil,
											smi_fuck,
											smi_grin,
											smi_heart,
											smi_kiss,
											smi_laugh,
											smi_newline,
											smi_ninja,
											smi_red,
											smi_roll,
											smi_roll_eyes,
											smi_sad,
											smi_slash,
											smi_sleep,
											smi_tongue,
											smi_weird,
											smi_whistle,
											smi_wink,
											smi_wonder];

		public static  var smileyCodes:Array = [":-)",
											":?:",
											":awe:",
											":baby:",
											":cool:",
											":evil:",
											":fuck:",
											":D",
											":h:",
											":x",
											":lol:",
											":nl:",
											":ninja:",
											":red:",
											":roll:",
											":[",
											":-(",
											":/:",
											":z:",
											":)~",
											":weird:",
											":whistle:",
											";-)",
											":wonder:"];	
		
	}
}