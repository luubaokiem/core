<!--- @@Copyright: Daemon Pty Limited 2002-2011, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!--- @@Description: HTML Page Content Type --->
<cfcomponent extends="versions" displayname="HTML Page" 
	hint="Forms the basis of the content framework of the site. HTML content items often include containers and publishing rules." 
	bUseInTree="1" bFriendly="1" fuAlias="html"
	bObjectBroker="1" >
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty 
	name="Title" type="string" hint="Title of content item." required="no" default="" ftType="string" ftLabel="Title"
	ftSeq="1" ftwizardStep="Web Page" ftFieldset="General Details" ftValidation="required" 
	ftHint="This title will appear as the major title on the page. It should not be confused with the title that appears in the navigation.">

<cfproperty 
	name="displayMethod" type="string" hint="Display method to render this HTML object with." required="yes" default="displayPageStandard" 
	ftSeq="4" ftwizardStep="Web Page" ftFieldset="General Details" ftLabel="Page Layout" 
	ftHint="This selection will determine the overall layout of the page."
	ftType="webskin" ftPrefix="displayPage" >

<cfproperty 
	name="Teaser" type="longchar" ftLabel="Teaser" ftType="longchar" hint="Teaser text." required="no" default=""
	ftSeq="10" ftwizardStep="Web Page" ftFieldset="Teaser"
	ftAutoResize="true">
	
<cfproperty 
	name="teaserImage" type="uuid" ftType="uuid" hint="UUID of image to display in teaser" required="no" default=""
	ftSeq="11" ftwizardStep="Web Page" ftFieldset="Teaser" ftLabel="Teaser Image"
	ftJoin="dmImage" ftLibraryData="getTeaserImageLibraryData" ftLibraryDataTypename="dmHTML">

<cfproperty 
	name="Body" type="longchar" hint="Main body of content." required="no" default="" 
	ftSeq="12" ftwizardStep="Web Page" ftFieldset="Body" ftLabel="Body" ftLabelAlignment="block"
	ftType="richtext" 
	ftImageArrayField="aObjectIDs" ftImageTypename="dmImage" ftImageField="StandardImage"
	ftTemplateTypeList="dmImage,dmFile,dmNavigation,dmHTML" ftTemplateWebskinPrefixList="insertHTML"
	ftLinkListFilterRelatedTypenames="dmFile,dmNavigation,dmHTML"
	ftTemplateSnippetWebskinPrefix="insertSnippet">

<cfproperty 
	name="aObjectIDs" type="array" hint="Related media items for this content item." required="no" default=""
	ftSeq="13" ftwizardStep="Web Page" ftFieldset="Relationships" ftLabel="Associated Media" 
	ftType="array" ftJoin="dmImage,dmFile" 
	ftShowLibraryLink="false" ftAllowAttach="true" ftAllowAdd="true" ftAllowEdit="true" ftRemoveType="detach"
	bSyncStatus="true">

<cfproperty 
	name="aRelatedIDs" type="array" ftType="array" hint="Holds object pointers to related objects. Can be of mixed types." required="no" default="" 
	ftSeq="14" ftwizardStep="Web Page" ftFieldset="Relationships" ftLabel="Associated Content"
	ftJoin="dmNavigation,dmHTML" >

<!--- 
 // seo
--------------------------------------------------------------------------------------------------->
<cfproperty 
	name="seoTitle" type="string" hint="SEO title of content item." required="no" default="" 
	ftSeq="32" ftwizardStep="SEO" ftFieldset="SEO" ftlabel="SEO Title"
	ftlimit="69" ftLimitOverage="warn" ftAutoResize="true"
	ftHint="If specified, the SEO title will be used instead of the page title for the TITLE tag. This title will be used as the preferred title by search engines. Different search engines have different lengths of snippet title: Google 69, Yahoo 72, Bing 65."
	fttype="longchar"
	ftRenderWebskinBefore="editSEOPreview"
	fthelptitle="Search Engine Optimization" 
	ftHelpSection="The keywords and description that you enter here will provide search engines with extra information that describes your page. Remember that a good SEO strategy is much more than just a good description and keywords." />
	
<cfproperty 
	name="extendedmetadata" type="longchar" hint="HTML head section for extended keywords." required="no" default=""
	ftSeq="35" ftwizardStep="SEO" ftFieldset="SEO" ftlabel="Description Tag"
	ftHint="Concise summary of the page. Different search engines have different character limits (including spaces) for their search snippet: Google 156, Yahoo 161, Bing 150."
	ftType="longchar" ftLimit="170" ftLimitOverage="warn"
	ftAutoResize="true" />

<cfproperty 
	name="metaKeywords" type="longchar" hint="HTML head section metakeywords." required="no" default="" 
	ftSeq="38" ftwizardStep="SEO" ftFieldset="SEO" ftLabel="Keyword Tag(s)"
	ftHint="Keep it simple and relevant: 10-20 keywords per page. Limited to 900 characters including spaces."
	ftType="longchar" ftLimit="900"
	ftAutoResize="true" ftLimitOverage="warn" />


<cfproperty 
	name="ownedby" displayname="Owned by" type="string" hint="Username for owner." required="No" default=""
	ftSeq="50" ftwizardStep="Miscellaneous" ftFieldset="Content Details" ftLabel="Owned By"
	ftHint="This should be set to the person responsible for this page. Any questions... ask this person."
	ftType="list" ftRenderType="dropdown" ftListData="getOwners" >
	
<cfproperty 
	name="reviewDate" type="date" hint="The date for which the object will be reviewed." required="no" default=""
	ftSeq="52" ftwizardStep="Miscellaneous" ftFieldset="Content Details" ftLabel="Review Date" 
	ftHint="Optionally enter a date to remind you when this content should be reviewed."
	ftType="datetime" ftToggleOffDateTime="true" ftShowTime="false">
	
<cfproperty 
	name="catHTML" type="string" hint="Topic." required="no" default="" 
	ftSeq="54" ftwizardStep="Miscellaneous" ftFieldset="Content Details" ftLabel="Categories"
	ftType="Category" ftAlias="root" />


<!------------------------------------------------------------------------
object methods 
------------------------------------------------------------------------->	
<cffunction name="deleteRelatedIds" hint="Deletes references to a given uuid in the dmHTML_relatedIds table">
	<cfargument name="objectid" required="yes" type="uuid">
	<cfargument name="dsn" required="no" default="#application.dsn#">
	<cfargument name="dbowner" required="no" default="#application.dbowner#">
	
	<cfset var q = ''>
	<cfquery name="q" datasource="#arguments.dsn#">
		DELETE FROM #application.dbowner#dmHTML_aRelatedIDs
		WHERE parentid = '#arguments.objectid#'
	</cfquery>
	
</cffunction>


<cffunction name="delete" access="public" hint="Specific delete method for dmHTML. Removes all descendants">
	<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	
	<!--- get object details --->
	<cfset var stObj = getData(arguments.objectid)>
	
	<cfset var oHTML = createObject("component", application.stcoapi.dmHTML.packagePath) />
	<cfset var stHTML = structNew() />
	<cfset var qRelated = queryNew("blah") />
	<cfset var qDeleteRelated = queryNew("blah") />
	
	<cfset var stReturn = structNew() />
	
	<cfif NOT structIsEmpty(stObj)>
		
		<cfset stReturn = super.delete(stObj.objectId) />
		
		<!--- Find any dmHTML pages that reference this html page. --->
		<cfquery datasource="#application.dsn#" name="qRelated">
		SELECT parentid FROM dmHTML_aRelatedIDs
		WHERE data = '#stobj.objectid#'
		</cfquery>
		
		<cfif qRelated.recordCount>

			<!--- Delete any of these relationships --->
			<cfquery datasource="#application.dsn#" name="qDeleteRelated">
			DELETE FROM dmHTML_aRelatedIDs
			WHERE data = '#stobj.objectid#'
			</cfquery>
						
			<!--- Remove deleted objects from object broker if required --->
			<cfset application.fc.lib.objectbroker.RemoveFromObjectBroker(lObjectIDs="#valueList(qRelated.parentID)#", typename="dmHTML") />
			
			
			
			<cfloop query="qRelated">
				<cfset stHTML = oHTML.getData(objectid=qRelated.parentid, bUseInstanceCache=false) />				
			</cfloop>		
						
		</cfif>

		
		<cfreturn stReturn>
	<cfelse>
		
		<cfset stReturn.bSuccess = false>
		<cfset stReturn.message = "#arguments.objectid# (dmHTML) not found.">
		<cfreturn stReturn>
		
	</cfif>
</cffunction>

<cffunction name="getTeaserImageLibraryData" access="public" output="false" returntype="query" hint="Return a query for all images already associated to this object.">
	<cfargument name="primaryID" type="uuid" required="true" hint="ObjectID of the object that we are attaching to" />
	<cfargument name="qFilter" type="query" required="false" default="#queryNew('key')#" hint="If a library verity search has been run, this is the qResultset of that search" />
	
	<cfset var q = queryNew("blah") />
		
	<!--- 
	Run the entire query and return in to the library. Let the library handle the pagination.
	 --->
	<cfquery datasource="#application.dsn#" name="q">
	SELECT data as objectid, dmImage.label, dmImage.thumbnailimage, dmImage.title, dmImage.alt
	FROM dmHTML_aObjectIDs 
	INNER JOIN 
		 dmImage ON dmHTML_aObjectIDs.data = dmImage.objectid
	WHERE parentid = '#arguments.primaryID#'
	<cfif qFilter.RecordCount>
		AND data IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#qFilter.key#" />)
	</cfif>
	ORDER BY seq
	</cfquery>
	
	<cfreturn q />
	
</cffunction>



</cfcomponent>

