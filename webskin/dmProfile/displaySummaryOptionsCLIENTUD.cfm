<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Summary options (CLIENTUD) --->
<!--- @@description: Farcry UD specific options --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfset stUser = createObject("component", application.stcoapi["farUser"].packagePath).getByUserID(listfirst(stObj.username,"_")) />

<cfoutput>
	<li><a href="#application.url.webtop#?id=home.overview&typename=farUser&objectid=#stUser.objectid#&bodyView=editOwnPassword"><admin:resource key="coapi.farUser.general.changepassword">Change password</admin:resource></a></li>
</cfoutput>

<cfsetting enablecfoutputonly="false" />