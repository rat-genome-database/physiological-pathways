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
	public class SmileyText
	{
		public var text:String;			// html text we are currentl
		public var len:int;		// length of text
		public var currentLineWidth:Number;	//meausreuemt of
		public var offset:int;		//used to keeps track of html tags, smiley chars, etc
		public var position:int;	//tracks position as we iterate throguh the text
		public var lastWord:int; //posiiton of last work
		public var currentChar:String; //most recent character -see nextChar function
		
		public function SmileyText(p_text:String) {
			text = p_text;
			len = p_text.length;
			currentLineWidth = 0;//textArea.measureHTMLText(init).width - 2;
			position = 0;
			lastWord = 0;
			offset = 0;
			currentChar = null;
		}
		
		public function nextChar() : String {
			if (position<len) {
				currentChar = text.substr(position,1);
			} else {
				currentChar = null;
			}
			return currentChar;
		}
	}
}