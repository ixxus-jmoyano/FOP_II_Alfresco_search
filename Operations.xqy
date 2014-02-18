module namespace OPERATIONS = "http://ixxus.com/operations";
import module namespace mem = "http://xqdev.com/in-mem-update" at "in-mem-update.xqy";
import module namespace CONSTANTS = "http://ixxus.com/constants" at "Constants.xqy";
import module namespace CONFIG = "http://ixxus.com/ManageConfigs" at "ManageConfigs.xqy";
import module namespace MODEL = "http://ixxus.com/articlemodel" at "ArticleModel.xqy";

(: Operation reset selection :)
declare variable $reset as xs:string := "reset";

(: Operation Add Article to the composed Article :)
declare variable $searchOp as xs:string := "search";

(: Operation change Alfresco Credentials :)
declare variable $changeCredentials as xs:string := "changeAlfrescoCredentials";

(: Operation Add Article to the composed Article :)
declare variable $addArticleOp as xs:string := "addArticle";

(: Operation Remove Article to the composed Article :)
declare variable $removeArticleOp as xs:string := "removeArticle";

(: Operation change the position of the article by giving it a higher position :)
declare variable $upArticleOp as xs:string := "upArticle";

(: Operation change the position of the article by giving it a lower position :)
declare variable $downArticleOp as xs:string := "downArticle";

(: Operation get next result page :)
declare variable $nextResultPage as xs:string := "nextResultPage";

(: Operation get previous result page :)
declare variable $previousResultPage as xs:string := "previousResultPage";

(: Operation Parse Unsigned Long :)
declare variable $parseUnsignedLong as xs:string := "parseUnsignedLong";

declare private function getItem($articleUri, $id){
	let $item := if($id) then 
					<item type="section" id="{$id}">{$articleUri}</item>
				 else
					<item type="article" id="{MODEL:getArticleId(MODEL:getXMLFromID($articleUri))}">{$articleUri}</item>
	let $log := xdmp:log(fn:concat("Item Added [", $item,"->type:", $item/@type,"->id:",$item/@id, "]"))
	return
		$item
};

declare function getMaxResultPage(){
	let $totalResults as xs:unsignedLong := xdmp:get-session-field($CONSTANTS:searchTotalResults)
	let $maxPage as xs:unsignedLong := fn:ceiling(($totalResults div $CONSTANTS:pageSize))
		return
			$maxPage
};

declare function doOperations($operation)
{	
	let $selectionsFile := xdmp:get-session-field($CONSTANTS:selectionsFile, "NONE")
	let $articleUri := xdmp:get-request-field($CONSTANTS:articleUri, "NONE")
	let $log := xdmp:log(fn:concat("Operation: [",$operation,"] Article Uri [",$articleUri,"], generatedDocument[",$selectionsFile, "]"))
	return 
		if($operation = $addArticleOp) then 
			(
			let $sectionId := xdmp:get-request-field($CONSTANTS:articleSection)
			return
				if($selectionsFile = "NONE") then
					let $save := xdmp:set-session-field($CONSTANTS:selectionsFile, <sessionwrapper>{OPERATIONS:getItem($articleUri, $sectionId)}</sessionwrapper>) 	
						return
						()
				else
					let $itemToInsert := OPERATIONS:getItem($articleUri, $sectionId)
					return
						if($selectionsFile/item[@id=($itemToInsert/@id)]) then
							let $log := xdmp:log(fn:concat("The Item ", $itemToInsert, " has already been added"))
							return
								()
						else
							let $insert :=  mem:node-insert-child( $selectionsFile,$itemToInsert)
							let $log := xdmp:log(fn:concat("Document Generated [",$insert,"]"))
							let $save := xdmp:set-session-field($CONSTANTS:selectionsFile, $insert) 		
							return
								()
			)
		else
		let $articleId := xdmp:get-request-field($CONSTANTS:articleId, "NONE")
		return
			if($operation = $removeArticleOp) then 
				(
				if(cts:contains($selectionsFile/item/@id, $articleId)) then
					(
					let $save := xdmp:set-session-field($CONSTANTS:selectionsFile, mem:node-delete($selectionsFile/item[@id=$articleId])) 
						return
						()
					)
				else
					()
				)
			else
			if($operation = $upArticleOp) then 
				(
				let $node := $selectionsFile/item[@id=$articleId]
				let $upperNode := $node/preceding-sibling::item[1]
				return
					if($upperNode) then
						let $selectionsFile := mem:node-delete($node)
						let $upperNode := $selectionsFile/item[@id=$upperNode/@id]
						let $selectionsFile := mem:node-insert-before($upperNode, $node)
						let $save := xdmp:set-session-field($CONSTANTS:selectionsFile, $selectionsFile) 		
						return
							()
					else
						()
				)
			else
			if($operation = $downArticleOp) then 
				(
				let $node := $selectionsFile/item[@id=$articleId]
				let $nextNode := $node/following-sibling::item[1]
				return
					if($nextNode) then
						let $selectionsFile := mem:node-delete($node)
						let $nextNode := $selectionsFile/item[@id=$nextNode/@id]
						let $selectionsFile := mem:node-insert-after($nextNode, $node)
						let $save := xdmp:set-session-field($CONSTANTS:selectionsFile, $selectionsFile) 		
						return
							()
					else
						()
				)
			else
			if($operation = $reset) then 
				let $save := xdmp:set-session-field($CONSTANTS:selectionsFile, "NONE") 
						return
						()
			else
			if ($operation=$changeCredentials) then
				let $save := CONFIG:setData(xdmp:get-request-field("UserName"), 
							   xdmp:get-request-field("Password"),
							   xdmp:get-request-field("SendXMLURL"))
				return
					()
			else
			if ($operation=$searchOp) then
				let $initPage as xs:unsignedLong := 0
				let $save := xdmp:set-session-field($CONSTANTS:searchResultPage, $initPage)
				return
					()
			else
			if ($operation = $nextResultPage) then
				let $page := xdmp:get-session-field($CONSTANTS:searchResultPage)
				return
					if(($page+1) < getMaxResultPage()) then
						let $save := xdmp:set-session-field($CONSTANTS:searchResultPage, $page + 1)
						return
							()
					else
						()
			else
			if ($operation=$previousResultPage) then
				let $initPage as xs:unsignedLong := 0
				let $page := xdmp:get-session-field($CONSTANTS:searchResultPage, $initPage)
				return
					if($page > 0) then
						let $save := xdmp:set-session-field($CONSTANTS:searchResultPage, $page - 1)
						return
							()
					else
						()
			else
			  ()			  
};

(: NOT CURRENTLY USED :)
declare function parseUnsignedLong($string){
	fn:sum(OPERATIONS:parseUnsignedLongSecuence($string))
};

declare private function parseUnsignedLongSecuence($string){
	let $stringSize := fn:string-length($string)
	let $result as xs:unsignedLong :=0
		return
		for $position in (1 to $stringSize)
			let $number := fn:substring($string, $position, 1)
			let $numberValue := math:pow(10, $stringSize - $position)
			let $result := if($number = "1") then
							  (1 * $numberValue)
							else
							if($number = "2") then
							 (2 * $numberValue)
							else
							if($number = "3") then
							 (3 * $numberValue)
							else
							if($number = "4") then
							   (4 * $numberValue)
							else
							if($number = "5") then
							 $result  + (1 * $numberValue)
							else
							if($number = "1") then
							  (5 * $numberValue)
							else
							if($number = "6") then
							 (6 * $numberValue)
							else
							if($number = "7") then
							  $result  + (7 * $numberValue)
							else
							if($number = "8") then
							  $result  + (8 * $numberValue)
							else
							if($number = "9") then
							  $result  + (9 * $numberValue)
							else
							  0
			return 
				$result
};