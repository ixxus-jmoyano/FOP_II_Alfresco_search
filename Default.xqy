import module namespace OPERATIONS = "http://ixxus.com/operations" at "Operations.xqy";
import module namespace CONSTANTS = "http://ixxus.com/constants" at "Constants.xqy";

if (xdmp:get-current-user() = "BAPAS-unknown")
then
  ( )
else
	OPERATIONS:doOperations(xdmp:get-request-field($CONSTANTS:paramOperation, "NONE"))
,

xdmp:log(fn:concat("Operation performed [",xdmp:get-request-field($CONSTANTS:paramOperation),"]"));

import module namespace OPERATIONS = "http://ixxus.com/operations" at "Operations.xqy";

import module namespace CONSTANTS = "http://ixxus.com/constants" at "Constants.xqy";

import module namespace MODEL = "http://ixxus.com/articlemodel" at "ArticleModel.xqy";

import module namespace SEARCHRESULT = "http://ixxus.com/searchresult" at "SearchResultModel.xqy";

import module namespace search = "http://marklogic.com/appservices/search" at "/Marklogic/appservices/search/search.xqy";

xdmp:set-response-content-type("text/html"),
<html>
	<head>
		<title>Build My Book</title>
	    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
		<meta http-equiv='Content-Type' content='text/html;charset=utf-8' />
		<meta http-equiv="Expires" content="-1" />
		<meta http-equiv="Pragma" content="no-cache"/>
		<meta http-equiv="Cache-Control" content="no-cache"/>
		<link rel="stylesheet" type="text/css" href="./styles.css"/>
		<script type="text/javascript" src="scripts.js">&#160;</script>
	</head>
	<body>
		<div class="containerDiv">
			<div class="searchDiv">
				<form method="post" name="Search" action="Default.xqy">
				{					
					let $searchTerm := xdmp:get-request-field($CONSTANTS:searchTerm, "")
					let $searchType := xdmp:get-request-field($CONSTANTS:searchType, "all")
						return
						<div class="searchBoxDiv">
							<div id="configDiv">
								<a onClick="javascript:openWindow('Configuration.xqy')" class="link">
									<img src="/Images/config.png" title="Change Configuration"/>
								</a>
							</div>
							<div>
								<h1 class="article title">Find:
									<input type="text" name="searchTerm" value="{$searchTerm}"/>
									<input type="button" class="actionButton" value="Search" onclick="javascript:navigateWithFormSubmission('Default.xqy?{$CONSTANTS:paramOperation}={$OPERATIONS:searchOp}', 'Search')"/>
								</h1>
							</div>
						</div>
				}
				</form>
			</div>
			{
			(: Results after performing search :)
			let $searchType := xdmp:get-request-field($CONSTANTS:searchType)
			let $searchTerm := xdmp:get-request-field($CONSTANTS:searchTerm)
			return
			(: Avoid to perform a search if there isn't a search term present:)
			if($searchTerm) then
				let $searchResultPage := if(xdmp:get-request-field($CONSTANTS:paramOperation, "NONE") = $OPERATIONS:searchOp) then
											let $initPage as xs:unsignedLong := 0 
											let $save := xdmp:set-session-field($CONSTANTS:searchResultPage, $initPage)
												return
												$initPage
										 else
											xdmp:get-session-field($CONSTANTS:searchResultPage)
				let $resultXML := search:search($searchTerm, (), (($searchResultPage * $CONSTANTS:pageSize)+1), $CONSTANTS:pageSize)
				let $save := xdmp:set-session-field($CONSTANTS:searchTotalResults, SEARCHRESULT:getTotalResults($resultXML))
				return
			<div class="resultsDiv">
				<div class="resultsLeftDiv">
					<div class="paginationDiv">
						<a onClick="javascript:navigateWithFormSubmission('Default.xqy?{$CONSTANTS:paramOperation}={$OPERATIONS:previousResultPage}', '{$CONSTANTS:hiddenForm}')" class="link">
							<img src="/Images/left_arrow.png" title="down article" width="50"/>
						</a>
						<h1>Page {$searchResultPage + 1} of {OPERATIONS:getMaxResultPage()}</h1>	
						<a onClick="javascript:navigateWithFormSubmission('Default.xqy?{$CONSTANTS:paramOperation}={$OPERATIONS:nextResultPage}', '{$CONSTANTS:hiddenForm}')" class="link">
							<img src="/Images/right_arrow.png" title="down article" width="50"/>
						</a>
					</div>
					{
					if($searchTerm != "") then
						for $resultItem in SEARCHRESULT:getResultItems($resultXML)
							let $uri := SEARCHRESULT:getResultUri($resultItem)
							let $article := MODEL:getXMLFromID($uri)
								return
								<div class="resultItemDiv">
									<h1 class="article title">
										{MODEL:getArticleTitle($article)}
									</h1>
									{
									if (fn:string-length(MODEL:getArticleSummary($article)) > 400) then
										<p class="article summary">{fn:concat(fn:substring($article, 0, 400), "...")}</p>
									else
										<p class="article summary">{MODEL:getArticleSummary($article)}</p>
									}						
									<div style="text-align:center">
										<a onClick="javascript:navigateWithFormSubmission('Default.xqy?{$CONSTANTS:paramOperation}={$OPERATIONS:addArticleOp}&amp;{$CONSTANTS:articleUri}={$uri}', '{$CONSTANTS:hiddenForm}')" class="link">
											<img src="/Images/add_article.png" title="add article" width="50"/>
										</a>
										<a onClick="javascript:navigateWithFormSubmission('ArticleDetails.xqy?{$CONSTANTS:articleUri}={$uri}', '{$CONSTANTS:hiddenForm}')" class="link">
											<img src="/Images/details_article.png" title="click to see full article" width="50"/>
										</a>
									</div>
								</div>
						else
						()
					}
					
				<div class="paginationDiv">
					<a onClick="javascript:navigateWithFormSubmission('Default.xqy?{$CONSTANTS:paramOperation}={$OPERATIONS:previousResultPage}', '{$CONSTANTS:hiddenForm}')" class="link">
						<img src="/Images/left_arrow.png" title="down article" width="50"/>
					</a>
					<h1>Page {$searchResultPage + 1} of {OPERATIONS:getMaxResultPage()}</h1>	
					<a onClick="javascript:navigateWithFormSubmission('Default.xqy?{$CONSTANTS:paramOperation}={$OPERATIONS:nextResultPage}', '{$CONSTANTS:hiddenForm}')" class="link">
						<img src="/Images/right_arrow.png" title="down article" width="50"/>
					</a>
				</div>				
				</div>	
				<div class="resultsRightDiv">
				{
					let $selection := xdmp:get-session-field($CONSTANTS:selectionsFile, "NONE")
					return
						if($selection != "NONE" and fn:count( $selection/item) !=0 ) then
							<div class="resultItemDiv">
								<h1 class="article title">
									Items Selected
								</h1>
								<h3 class="article title section" style="display:inline;">
									Title:<input type="text" id="{$CONSTANTS:publicationTitle}"/>
									<input type="button" class="actionButton" value="Generate Publication" onclick="javascript:openWindow('Publish.xqy?{$CONSTANTS:publicationTitle}=' + document.getElementById('{$CONSTANTS:publicationTitle}').value)"/>
									<a onClick="javascript:navigateWithFormSubmission('Default.xqy?{$CONSTANTS:paramOperation}={$OPERATIONS:reset}', '{$CONSTANTS:hiddenForm}')" style="margin-left:130px" class="link">
										<img src="/Images/cross.png" title="Remove all" width="50"/>
									</a>
								</h3>
									{
									for $item in $selection/item
										let $article := MODEL:getXMLFromID($item/text())
										return	
										<div style="overflow:auto;">
											{if($item[@type="section"]) then
													<div class="resultsLeftDiv"><p class="article summary">{MODEL:getArticleTitle($article)}[Section: {MODEL:getArticleSectionTitle($article, $item/@id)}]</p></div>
												else
													<div class="resultsLeftDiv"><p class="article summary">{MODEL:getArticleTitle($article)}</p></div>
											}
											<div class="resultsRightDiv">
											<a onClick="javascript:navigateWithFormSubmission('Default.xqy?{$CONSTANTS:paramOperation}={$OPERATIONS:removeArticleOp}&amp;{$CONSTANTS:articleId}={$item/@id}', '{$CONSTANTS:hiddenForm}')" class="link">
												<img src="/Images/remove_article.png" title="remove article" width="50"/>
											</a>
											<a onClick="javascript:navigateWithFormSubmission('Default.xqy?{$CONSTANTS:paramOperation}={$OPERATIONS:upArticleOp}&amp;{$CONSTANTS:articleId}={$item/@id}', '{$CONSTANTS:hiddenForm}')" class="link">
												<img src="/Images/up_article.png" title="up article" width="50"/>
											</a>
											<a onClick="javascript:navigateWithFormSubmission('Default.xqy?{$CONSTANTS:paramOperation}={$OPERATIONS:downArticleOp}&amp;{$CONSTANTS:articleId}={$item/@id}', '{$CONSTANTS:hiddenForm}')" class="link">
												<img src="/Images/down_article.png" title="down article" width="50"/>
											</a>
											</div>
										</div>
									}
							</div>	
						else
							()
				}		
				</div>
			</div>
			else
				()
			}<!-- From the resultsLeftDiv -->
		</div><!-- From the containerDiv -->
		<form name="{$CONSTANTS:hiddenForm}" method="post">
			<input type="hidden" name="{$CONSTANTS:searchTerm}" value="{xdmp:get-request-field($CONSTANTS:searchTerm)}"/>
			<input type="hidden" name="{$CONSTANTS:searchResultPage}" value="{xdmp:get-request-field($CONSTANTS:searchResultPage, "1")}"/>
		</form>
	</body>
</html>