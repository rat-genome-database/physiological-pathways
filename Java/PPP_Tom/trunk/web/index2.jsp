<%@ page import="PPP_Services.FileService" %>
<%@ page import="Utils.DiagramGroup" %>
<%@ page import="java.util.Date" %>
<%--
  Created by IntelliJ IDEA.
  User: WLiu
  Date: Mar 26, 2010
  Time: 3:26:29 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!-- saved from url=(0014)about:internet -->

<html lang="en">

<!--
Smart developers always View Source.

This application was built using Adobe Flex, an open source framework
for building rich Internet applications that get delivered via the
Flash Player or to desktops via Adobe AIR.

Learn more about Flex at http://flex.org
// -->

<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="description" content="Physiological Pathway Diagram">
<!--  BEGIN Browser History required section -->
<link rel="stylesheet" type="text/css" href="history/history.css" />
<!--  END Browser History required section -->

<title></title>

    <script src="AC_OETags.js" language="javascript"></script>
    <script src="jquery-1.7.2.min.js" language="javascript"></script>

<!--  BEGIN Browser History required section -->
<script src="history/history.js" language="javascript"></script>
<!--  END Browser History required section -->

<style>
body { margin: 0px; overflow:hidden }
</style>
<script language="JavaScript" type="text/javascript">
<!--
// -----------------------------------------------------------------------------
// Globals
// Major version of Flash required
var requiredMajorVersion = 10;
// Minor version of Flash required
var requiredMinorVersion = 0;
// Minor version of Flash required
var requiredRevision = 0;
// -----------------------------------------------------------------------------
// -->
<!--
function moveIFrame(x,y,w,h) {
    var frameRef=document.getElementById("myFrame");
    frameRef.style.left=x;
    frameRef.style.top=y;
    var iFrameRef=document.getElementById("content");
	iFrameRef.width=w;
	iFrameRef.height=h;
}

function backwardIFrame() {
  history.go(-1);
}

function forwardIFrame() {
  history.go(1);
}

function setIFrameContent( contentSource )
{
	document.getElementById("content").src = contentSource;
}

function hideIFrame()
{
    document.getElementById("myFrame").style.visibility="hidden";
}

function showIFrame()
{
    document.getElementById("myFrame").style.visibility="visible";
}

function getURL()
{
  return frames['content'].location;
}
// -->
</script>
<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-2739107-2']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>
</head>

<body scroll="no" onload="javascript:window.focus();setTimeout('window.focus();', 1000)">
<script language="JavaScript" type="text/javascript">
<!--
// Version check for the Flash Player that has the ability to start Player Product Install (6.0r65)
var hasProductInstall = DetectFlashVer(6, 0, 65);

// Version check based upon the values defined in globals
var hasRequestedVersion = DetectFlashVer(requiredMajorVersion, requiredMinorVersion, requiredRevision);

if ( hasProductInstall && !hasRequestedVersion ) {
	// DO NOT MODIFY THE FOLLOWING FOUR LINES
	// Location visited after installation is complete if installation is required
	var MMPlayerType = (isIE == true) ? "ActiveX" : "PlugIn";
	var MMredirectURL = window.location;
    document.title = document.title.slice(0, 47) + " - Flash Player Installation";
    var MMdoctitle = document.title;

	AC_FL_RunContent(
		"src", "playerProductInstall",
		"FlashVars", "MMredirectURL="+MMredirectURL+'&MMplayerType='+MMPlayerType+'&MMdoctitle='+MMdoctitle+"",
		"width", "100%",
		"height", "100%",
		"align", "middle",
		"id", "PPP_Player",
		"quality", "high",
		"bgcolor", "#444444",
		"name", "PPP_Player",
		"allowScriptAccess","sameDomain",
		"type", "application/x-shockwave-flash",
		"pluginspage", "http://www.adobe.com/go/getflashplayer"
	);
} else if (hasRequestedVersion) {
	// if we've detected an acceptable version
	// embed the Flash Content SWF when all tests are passed
	AC_FL_RunContent(
			"src", <%
               String program_name = request.getParameter("programname");
               if (program_name != null && program_name.equalsIgnoreCase("designer")) {
                   out.print("\"PPP_Designer?v=");
               } else {
                   out.print("\"PPP_Player?v=");
               }
               out.print((new Date()).getTime()+"\"");
            %>,
            "FlashVars", 'fileName=' + (window.location.search.substring(1).length > 0 ? window.location.search.substring(1) : "fluid vol ov.xml"),
			"width", "100%",
			"height", "100%",
			"align", "middle",
			"id", "PPP_Player",
			"quality", "high",
			"bgcolor", "#444444",
			"name", "PPP_Player",
			"allowScriptAccess","sameDomain",
			"type", "application/x-shockwave-flash",
			"pluginspage", "http://www.adobe.com/go/getflashplayer",
			"wmode", "opaque",
			"allowFullScreen", "true"
	);
  } else {  // flash is too old or we can't detect the plugin
    var alternateContent = 'Alternate HTML content should be placed here. '
  	+ 'This content requires the Adobe Flash Player. '
   	+ '<a href=http://www.adobe.com/go/getflash/>Get Flash</a>';
    document.write(alternateContent);  // insert non-flash content
  }

function test()
{
    return true;
}

  function openURL( url, target )
{
	try
	{
		var popup = window.open( url, target );
		if ( popup == null )
			return false;

		if ( window.opera )
			if (!popup.opera)
				return false;
	}

	catch(err)
	{
		return false;
	}

	return true;
}

  function IFrameLoaded()
  {
  	PPP_Player.newFrameLoaded();
  }

  function myMovie_DoFSCommand(com, comPara) {
      if (com=="changeTitle") {
        document.title=comPara+" Diagram";
      }
      if (com=="changeDescription") {
          $('meta[name=description]').attr('content', comPara);
      }
 }
// -->
</script>
<noscript>
  	<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
			id="PPP_Player" width="100%" height="100%"
			codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
			<param name="movie" value="PPP_Player.swf" />
			<param name="quality" value="high" />
			<param name="bgcolor" value="#444444" />
			<param name="allowScriptAccess" value="sameDomain" />
			<embed src="PPP_Player.swf" quality="high" bgcolor="#444444"
				width="100%" height="100%" name="PPP_Player" align="middle"
				play="true"
				loop="false"
				quality="high"
				allowScriptAccess="sameDomain"
				type="application/x-shockwave-flash"
				pluginspage="http://www.adobe.com/go/getflashplayer"
				wmode="opaque">
			</embed>
	</object>
</noscript>

<!--
<iframe name="_history" src="history.htm" frameborder="0" scrolling="no" width="22" height="0"></iframe>
-->
<div name="myFrame" id="myFrame" style="position:absolute;background-color:white;border:0px;visibility:hidden;">
<iframe id='content' name='content' frameborder='0' onload='IFrameLoaded()'></iframe>
</div>
</body>
</html>
