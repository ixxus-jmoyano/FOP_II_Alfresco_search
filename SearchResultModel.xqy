module namespace SEARCHRESULT = "http://ixxus.com/searchresult";
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";

declare function getTotalResults($xml){
	$xml/@total
};

declare function getResultItems($xml){
	$xml/search:result
};

declare function getResultUri($result){
	$result/@uri
};