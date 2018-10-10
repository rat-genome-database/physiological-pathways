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
	import mx.controls.TextArea;
	
	public class SmileyTextProcessor
	{
		private var smileyWidths:Array = new Array();		//width of smileys
		private var smileyCodeLengths:Array = new Array(); //this is the length of each smiley code
		public var activeSmileys:Array = new Array();	//currerntly active
		private var smileyCodeFirstChars:Array = new Array(); //quick reference to check our smileys against
		private var smileyCount:int;
		
		private var textArea: TextArea;
		
		private var textFieldWidth:Number;				//current width
		private var spaceWidth:Number; //width of one space
		private var currentLine:int = 0;				//current line this component is on
		private var smileyScaleFactor:Number = 1;			///scale factor
		
		//debug
		private var debugText:TextArea;			
		
		public static var htmlTags:Array =  ["&nbsp;","&lt;", "&gt;", "&amp;", "&quot;", "&apos;"];
		public static var htmlTagReplacements:Array =  [" ","<", ">", "&", "\"", "'"];
		private var smileyText:SmileyText; //the html text we are currently processing
		
		public function SmileyTextProcessor(p_textArea:TextArea, p_smileyWidths:Array, smileyScaleFactor:Number) {
			textArea = p_textArea;
			spaceWidth = textArea.measureHTMLText(" ").width;
			textFieldWidth = textArea.width - 20;
			activeSmileys = new Array();
			smileyWidths = p_smileyWidths;
			//store the lengths and first chars for more efficient use
			smileyCount = Smileys.smileys.length;
			for (var i:int =0; i< smileyCount; i++) {
				smileyCodeLengths.push((String)(Smileys.smileyCodes[i]).length);
				smileyCodeFirstChars.push((String)(Smileys.smileyCodes[i]).substr(0,1));
			}
			
		}
		
		/*
		* Processes the string p_text
		* returns the currentLine that the textarea is on, after processing the string
		* or -1 if something was wrong
		*/
		public function processHtmlString(p_text:String):Number
		{
			smileyText = new SmileyText(p_text);
			
			//now iterate over the smiley text, and add a smiley to our active list for any smiley we encounter, 
			//while calculating the dimensions/scale, etc
			var i:int;
			while (smileyText.nextChar() !=null) {//(smileyText.position < pLen) // 
				smileyText.offset = 1;	// we use this to help track when we have a line break
				var wasSmiley:Boolean =false;
				if (smileyText.currentChar == "<") { 
					//skip contents of html tags
					i = smileyText.text.indexOf(">", smileyText.position + 1);	
					if (i > smileyText.position) smileyText.position += i + 1;				
					continue; 
				} 
				else if (smileyText.currentChar == "&") { 
					htmlToText();	//convert these...
				} 
				else if (looksLikeSmiley()) {
					//iterate through our list of smileys to see if we have a match
					for (i=0; i < smileyCount; i++) { 
						
						//check against each smiley
						if (smileyText.text.substr(smileyText.position, smileyCodeLengths[i]) != Smileys.smileyCodes[i]) {
							continue; //not a match so get next smiley
						}
						wasSmiley=true;
						//c is the amount of characters to represent this smiley
						var c:Number = Math.floor((smileyWidths[i] * smileyScaleFactor) / spaceWidth)+1;
						
						if (smileyText.currentLineWidth + spaceWidth * c >= textFieldWidth) {
							addNewLine();
						}

						//add the smiley to our array for this line
						if (activeSmileys[currentLine] == undefined){
							activeSmileys[currentLine] = new Array();
						}
						var x:int = smileyText.currentLineWidth-((smileyWidths[i] * smileyScaleFactor) / spaceWidth);
						smileyText.currentLineWidth += Math.ceil(spaceWidth * c);
						activeSmileys[currentLine].push({swf: Smileys.smileys[i], x:x});

						//update the text with spaces where the smiley is
						var spaces:String = " ";	
						while (--c > 0) {
							spaces += " ";
						}
						smileyText.text = smileyText.text.substring(0, smileyText.position) + spaces + 
									   smileyText.text.substr(smileyText.position + smileyCodeLengths[i]);

						smileyText.position += spaces.length;	
						smileyText.lastWord = smileyText.position;					
						break;
					}
				}
				if (!wasSmiley) measureCurrentChar(); 
		 	
			}
			//line was processed, add the text to our text area and eal with accordingyl
			textArea.htmlText += smileyText.text + "<br />"; 
			currentLine++;
			return currentLine;
		}
		
		//convert html to text
		private function htmlToText():void
		{
			var i:Number = smileyText.text.indexOf(";", smileyText.position + 1);	
			if (i <= smileyText.position)
				return;
			var tagIndex:int = htmlTags.indexOf(smileyText.text.substring(smileyText.position, i + 1).toLowerCase());
			if (tagIndex==-1) return;
			smileyText.currentChar = htmlTagReplacements[tagIndex];
			smileyText.offset = (i + 1) - smileyText.position;
		}
		
		//returns true if the current position of the parsing smileytext looks like it could be a smiley
		private function looksLikeSmiley() :Boolean {
			if (smileyCodeFirstChars.indexOf(smileyText.currentChar) == -1 ) return false;
			if (smileyText.position == smileyText.len) return false;
			if (smileyText.text.substr(smileyText.position + 1) == " ") return false;
			return true;
		}
		
		//use this to wrap a line
		private function addNewLine():void
		{
			smileyText.text = smileyText.text.substring(0, smileyText.position) + "<BR>" + smileyText.text.substr(smileyText.position);
			smileyText.position += 4;
			smileyText.currentLineWidth = smileyText.lastWord = 0;	
			currentLine++;	
		}
		
		//gets called if curent char is not part of a smiley, in which case it mesures to see if wrapping has occurred.
		private function measureCurrentChar() : void {
			var w:Number = textArea.measureHTMLText(smileyText.currentChar).width; 
			if (smileyText.currentLineWidth + w < textFieldWidth) {	
				smileyText.position += smileyText.offset;	
				smileyText.currentLineWidth += w;				
				if (smileyText.offset == 1 && (smileyText.currentChar == " " || smileyText.currentChar == "-" || smileyText.currentChar == ",")) {
					smileyText.lastWord = smileyText.position;
				}
			}
			else { 
				if (smileyText.lastWord > 0) { 
					smileyText.position = smileyText.lastWord;
				}
				addNewLine();
			}
		}

	}
}