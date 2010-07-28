
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry" />


<cfif thistag.executionMode eq "Start">

	<!--- environment variables --->
	<cfparam name="request.fc.startTickCount" default="#GetTickCount()#" />
	<cfparam name="request.bHideContextMenu" default="false" type="boolean" /><!--- Hide the tray.  For backwards compatibility --->
	<cfparam name="request.fc.trayData" default="#structnew()#" />
	
	<cfset request.fc.trayData.objectid = url.objectid />
	<cfset request.fc.trayData.type = url.type />
	<cfset request.fc.trayData.view = url.view />
	<cfset request.fc.trayData.bodyView = url.bodyView />

</cfif>

<cfif thistag.executionMode eq "End">

	<cfif len(url.type) 
		AND NOT structKeyExists(application.rules, url.type) 
		AND request.mode.bAdmin 
		AND request.fc.bShowTray 
		AND NOT request.bHideContextMenu
		AND NOT structKeyExists(request.fc, "bAdminTrayRendered") 
		AND NOT request.mode.ajax>
		
		<cfset request.fc.bAdminTrayRendered = true />
		
		<cfparam name="session.fc" default="#structNew()#" />
		<cfparam name="session.fc.trayWebskin" default="displayAdminBarHidden" />
		
		<cfset request.fc.totalTickCount = (GetTickCount() - request.fc.startTickCount) / 1000 />
		
		<cfset urlTray = application.fapi.getLink(type=url.type, objectid=url.objectid, urlParameters='ajaxmode=1') />

		<!--- import libraries --->
		<skin:loadJS id="jquery" />
		<skin:loadJS id="jquery-ui" />
		<skin:loadJS id="jquery-tooltip" />
		<skin:loadJS id="farcry-form" />
		<skin:loadCSS id="jquery-ui" />
		<skin:loadCSS id="farcry-form" />
		<skin:loadCSS id="farcry-tray" />	
		<skin:loadCSS id="jquery-tooltip" />

		<cfoutput>	
		<skin:onReady>
		

		$fc.traySwitch = function(webskin){
		    $j('##farcrytray').html('');
			$j.ajax({
				type: "POST",
				cache: false,
				<cfif findNoCase("?",urlTray)>
					url: '#urlTray#' + '&view=' + webskin + '&totalTickCount=#request.fc.totalTickCount#', 
				<cfelse>
					url: '#urlTray#' + '?view=' + webskin + '&totalTickCount=#request.fc.totalTickCount#', 
				</cfif>
				
				complete: function(data){
					$j('##farcrytray').html(data.responseText);					
				},
				data:{
					refererURL:'#cgi.script_name#?#cgi.query_string#'
					<cfloop collection="#request.fc.trayData#" item="thistag.traydatakey">
						<cfif issimplevalue(request.fc.trayData[thistag.traydatakey])>
							, '#thistag.traydatakey#':'#jsstringformat(request.fc.trayData[thistag.traydatakey])#'
						<cfelse>
							<cfif thistag.traydatakey eq "profile"><cfset application.fapi.addProfilePoint("End","End") /></cfif>
							<cfwddx action="cfml2wddx" input="#request.fc.trayData[thistag.traydatakey]#" output="thistag.traydatawddx" />
							, '#thistag.traydatakey#':'#jsstringformat(thistag.traydatawddx)#'
						</cfif>
					</cfloop>
				},
				dataType: "html"
			});
		}
		
		$fc.trayAction = function(urlParams){
		    document.location = '#cgi.script_name#?#cgi.query_string#&' + urlParams;
		}
			
		$fc.editTrayObject = function(typename,objectid) {
			$fc.traySwitch('displayAdminBarHidden');
			$fc.objectAdminAction('Inline Edit', '#application.url.webtop#/edittabOverview.cfm?typename=' + typename + '&objectid=' + objectid + '&method=edit&ref=iframe');		
		};	
		
		
	
			
		
		// only show the frame if we are not in a frame
		if (top === self) { 		
			$j("body").append("<div style='bottom:0;left:0;font-size:11px;padding:0;position:fixed;width:100%;z-index:9999;text-align:left;'><div id='farcrytray'></div></div>");	
			$fc.traySwitch('#session.fc.trayWebskin#'); // add tray
			
		}	
		
				
		</skin:onReady>
	
		
		</cfoutput>
		
		<farcry:webskinTracer />
	</cfif>
	
</cfif>