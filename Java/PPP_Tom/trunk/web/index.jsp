<%@ page import="PPP_Services.FileService" %>
<%@ page import="Utils.DiagramGroup" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta name="keywords" content="<%
    // This is a scriptlet.  Notice that the "date"
    // variable we declare here is available in the
    // embedded expression later on.
        FileService fs = new FileService();
        String file_name = request.getParameter("filename");
            String title_str = "";
        if (file_name != null && file_name.length() > 0) {
            String diagram_xml = new String(fs.GetFile("Diagrams/" + file_name, ""));
            if (file_name.contains(".dgs")) {
                DiagramGroup dg = new DiagramGroup(diagram_xml);
                title_str = dg.get_titleLabel();
            }
            out.print(title_str);
        }
%>">
    <meta name="description" content="<%out.print(title_str);%>">
    <title><%out.print(title_str);%></title>
</head>
<script language="JavaScript" type="text/javascript">

    var w1=null;

    function get_broswer_type()
    {
        if (navigator.userAgent.indexOf("Chrome") >= 0) return "Chrome";
        if (navigator.userAgent.indexOf("Safari") >= 0) return "Safari";
        if (navigator.userAgent.indexOf("Firefox") >= 0) return "Firefox";
        if (navigator.userAgent.indexOf("MSIE") >= 0) return "MSIE";
    }

    function pausecomp(millis)
    {
    var date = new Date();
    var curDate = null;

    do { curDate = new Date(); }
    while(curDate-date < millis);
    }

    function has_popup_blocker()
    {
        if (get_broswer_type() == "Chrome") return has_popup_blocker1();
        return has_popup_blocker2();
    }

    function has_popup_blocker1()
    {
        return false;
    }

    function has_popup_blocker2()
    {
        try {
        var win = window.open('testPopup.html','ReportViwer','width=200px,height=100px,left=50px,top=20px,location=no,directories=no,status=no,menubar=no,toolbar=no,resizable=1,maximize:yes,scrollbars=0');
            if (!win || win.closed || typeof win.closed == 'undefined') return true;
            win.moveBy(10,10);
            win.close();
            return false;
        } catch(err) {
            return true;
        }
    }

    function check_and_pop()
    {
        if (has_popup_blocker()) {
            alert("Please disable pop-up blocker for our web site or click at the link!");
            return;
        }
        popup_player();
    }

    function popup_player()
    {
        var maxx= 1.0;
        var maxy= 1.0;
        var ar1x = .60;


        var w = screen.width * maxx ;
        var h = screen.height * maxy ;


        var aw;
        var ah;


        if ( w * ar1x > h )
        {
            ah = h;
            aw = h / ar1x;

        }
        else
        {
            aw = w;
            ah = w * ar1x;
        }

        aw = w;
        ah = h;
        aw = Math.floor(aw) - 15;
        ah = Math.floor(ah) - 110;

        var l = 1;
        var t = 0;

        var randomnumber=Math.floor(Math.random()*10000);

        new_url = ('index2.jsp?'+(window.location.search.substring(1).length > 0 ? window.location.search.substring(1) : "fluid vol ov.xml"));
        new_name = "PPP_Player"+randomnumber;
        new_spec = 'toolbar=no, location=false, directories=no, status=no, menubar=no, scrollbars=no, resizable=yes, width='+ aw +  ', height=' + ah + ',left=' + l + ',top=' + t;
        w1=window.open(new_url,new_name,new_spec);
        if (get_broswer_type() == "Chrome")
        {
            setTimeout("if (w1.screenX === 1) {history.go(-1);} else { alert('Please disable pop-up blocker for our web site or click at the link!');}",100);
        }  else
        {
            setTimeout("history.go(-1);",100);
            w1.focus();
        }
    }

</script>
<body onload="javascript:check_and_pop();">
<a href="index2.jsp" onclick="javascript:popup_player();return false;">Play diagram now</a>

</body>
</html>