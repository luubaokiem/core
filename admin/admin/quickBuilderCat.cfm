<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/quickBuilderCat.cfm,v 1.2 2005/05/30 07:35:15 pottery Exp $
$Author: pottery $
$Date: 2005/05/30 07:35:15 $
$Name: milestone_3-0-1 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: Quickly builds a category structure$
$TODO:$

|| DEVELOPER ||
$Developer: Quentin Zervaas (quentin@mitousa.com) $
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/farcry_core/tags/farcry/" prefix="farcry">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

<!--- character to indicate levels --->
<cfset levelToken = "-" />

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<!--- check permissions --->
<cfscript>
	iDeveloperPermission = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="developer");
</cfscript>

<cfif iDeveloperPermission eq 1>

	<cfif isDefined("form.submit")>
	    <cfscript>
	        startPoint = form.startPoint;
	        makenavaliases = isDefined("form.makenavaliases") and form.makenavaliases;
	        if (makenavaliases)
	            navaliaseslevel = form.navaliaseslevel;
	
	        structure = form.structure;
	
	        lines = listToArray(structure, "#chr(13)##chr(10)#");
	
	        // setup items with their level and objectids
	        items = arrayNew(1);
	        lastlevel = 1;
	
	        for (i = 1; i lte arraylen(lines); i = i + 1) {
	            prefix = spanIncluding(lines[i], levelToken);
	            prefixLen = len(prefix);
	
	            line = lines[i];
	            lineLen = len(line);
	
	            level = prefixLen + 1;
	            if (level gt lastlevel)
	                level = lastlevel + 1;
	            title = trim(right(lines[i], lineLen - prefixLen));
	
	            if (len(title) gt 0) {
	                item = structNew();
	                //item.title = ReplaceNoCase(title, "'", "''", "ALL");
	                item.title = title;
	                item.level = level;
	                item.objectid = createuuid();
	                item.parentid = '';
	                arrayAppend(items, item);
	                lastlevel = item.level;
	            }
	        }
	
	        parentstack = arrayNew(1);
	        navstack = arrayNew(1);
	        arrayAppend(parentstack, startPoint);
	
	        // now figure out each item's parent node
	        lastlevel = 0;
	        for (i = 1; i lte arraylen(items); i = i + 1) {
	            if (items[i].level lt lastlevel) {
	                diff = lastlevel - items[i].level;
	                for (j = 0; j lte diff; j = j + 1) {
	                    arrayDeleteAt(parentstack, arraylen(parentstack));
	                    arrayDeleteAt(navstack, arraylen(navstack));
	                }
	            }
	            else if (items[i].level eq lastlevel) {
	                arrayDeleteAt(parentstack, arraylen(parentstack));
	                arrayDeleteAt(navstack, arraylen(navstack));
	            }
	
	            items[i].parentid = parentstack[arraylen(parentstack)];
	
	            arrayAppend(parentstack, items[i].objectid);
	
	            navtitle = lcase(rereplacenocase(items[i].title, "\W+", "_", "all"));
	            arrayAppend(navstack, rereplace(navtitle, "_+", "_", "all"));
	
	            if (makenavaliases) {
	                if (navaliaseslevel eq 0 or items[i].level lte navaliaseslevel)
	                    items[i].lNavIDAlias = arrayToList(navstack, '_');
	                else
	                    items[i].lNavIDAlias = '';
	
	            }
	            else
	                items[i].lNavIDAlias = '';
	
	            lastlevel = items[i].level;
	        }
	
	        // now finish setting up the structure of each item
	        for (i = 1; i lte arraylen(items); i = i + 1) {
	            structDelete(items[i], "level");
	        }
	    </cfscript>
	
	    <cfimport taglib="/farcry/fourq/tags/" prefix="q4">
	
	    <cfscript>
	        o_farcrytree = createObject("component", "#application.packagepath#.farcry.tree");
	        oCat = createObject("component", "#application.packagepath#.farcry.category");
	
	        for (i = 1; i lte arraylen(items); i = i + 1) {
	            oCat.addCategory(dsn=application.dsn,parentID=items[i].parentID,categoryID=items[i].objectID,categoryLabel=items[i].title);
	            if (len(items[i].lNavIDAlias)) 
	            	oCat.setAlias(categoryid=items[i].objectID,alias=items[i].title);
	        }
	    </cfscript>
	
	    <cfoutput>
	        <div class="formTitle">#application.adminBundle[session.dmProfile.locale].catTreeQuickBuilder#</div>
	        <p>
	            #application.adminBundle[session.dmProfile.locale].followingItemsCreated#
	        </p>
	        <ul>
				<cfset subS=listToArray('#arrayLen(items)#,"Category"')>
				<li>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].objects,subS)#</li>
	        </ul>
	    </cfoutput>
	<cfelse>
	
	    <cfscript>
	        o = createObject("component", "#application.packagepath#.farcry.tree");
	        qNodes = o.getDescendants(dsn=application.dsn, objectid=application.catid.root);
	    </cfscript>
		
	<cfoutput>
	<script language="JavaScript">
	    function updateDisplayBox()
	    {
	        document.theForm.displayMethod.disabled = !document.theForm.makehtml.checked;
	    }
	
	    function updateNavTreeDepthBox()
	    {
	        document.theForm.navaliaseslevel.disabled = !document.theForm.makenavaliases.checked;
	    }
	</script>

	<form method="post" class="f-wrap-1 f-bg-long wider" action="" name="theForm">
	<fieldset>
	
		<h3>#application.adminBundle[session.dmProfile.locale].catTreeQuickBuilder#</h3>
		
		<label for="startPoint"><b>#application.adminBundle[session.dmProfile.locale].createStructureWithin#</b>
		<select name="startPoint" id="startPoint">
		<option value="#application.catid.root#" selected>#application.adminBundle[session.dmProfile.locale].Root#</option>
		<cfloop query="qNodes">
		<option value="#qNodes.objectId#">#RepeatString("&nbsp;&nbsp;|", qNodes.nlevel)#- #qNodes.objectName#</option>
		</cfloop>
		</select><br />
		</label>
		
		<fieldset class="f-checkbox-wrap">
		
			<b>#application.adminBundle[session.dmProfile.locale].navAliases#</b>
			
			<fieldset>
			
			<label for="makenavaliases">
			<input type="checkbox" name="makenavaliases" id="makenavaliases" checked="checked" value="1" onclick="updateNavTreeDepthBox()" class="f-checkbox" />
			#application.adminBundle[session.dmProfile.locale].createNavAliases#
			</label>
			
			<select name="navaliaseslevel">
	            <option value="0">#application.adminBundle[session.dmProfile.locale].all#</option>
	            <option value="1" selected >1</option>
	            <option value="2">2</option>
	            <option value="3">3</option>
	            <option value="4">4</option>
	            <option value="5">5</option>
	            <option value="6">6</option>
	          </select><br />
	          #application.adminBundle[session.dmProfile.locale].levels#
			  <script>updateNavTreeDepthBox()</script>
			
			</fieldset>
		
		</fieldset>
		
		<label for="levelToken"><b>#application.adminBundle[session.dmProfile.locale].levelToken#</b>
		<select name="levelToken" id="levelToken">
		<option>#levelToken#</option>
		</select><br />
		</label>
		
		<label for="structure"><b>#application.adminBundle[session.dmProfile.locale].structure#</b>
		<textarea name="structure" id="structure" rows="10" cols="40" class="f-comments"></textarea><br />
		</label>
		
		<div class="f-submit-wrap">
		<input type="submit" value="#application.adminBundle[session.dmProfile.locale].buildSiteStructure#" name="submit" class="f-submit" /><br />
		</div>
		
	</fieldset>
	</form>
	
	<hr />

	<h4>#application.adminBundle[session.dmProfile.locale].instructions#</h4>
	<p>
	#application.adminBundle[session.dmProfile.locale].quicklyBuildFarCrySiteBlurb#
	</p>
	
	<hr />
	
	<h4>#application.adminBundle[session.dmProfile.locale].example#</h4>
	<p>
	<pre>
	Item 1
	-Item 1.2
	--Item 1.2.1
	-Item 1.3
	Item 2
	-Item 2.1
	--Item 2.2
	Item 3
	</pre>
	</p>
	
	<p>
	#application.adminBundle[session.dmProfile.locale].visualPurposesBlurb#
	</p>
	
	<p>
	<pre>
	Item 1
	- Item 1.2
	-- Item 1.2.1
	</pre>
	</p>
	
	</cfoutput>
	</cfif>

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="no">
