module namespace CONSTANTS = "http://ixxus.com/constants";

(: Var used to recover the article composition selected by the user :)
declare variable $paramOperation as xs:string := "operation";

(: Var used to recover the article composition selected by the user :)
declare variable $selectionsFile as xs:string := "article";

(: Var used to recover the article composition selected by the user :)
declare variable $publicationFile as xs:string := "publication";

(: Var used to recover the article title set by the user :)
declare variable $publicationTitle as xs:string := "publicationTitle";

(: Var used to recover the parameter article URI :)
declare variable $articleUri as xs:string := "articleUri";

(: Var used to recover the parameter article Id :)
declare variable $articleId as xs:string := "articleId";

(: Var used to recover the parameter article Section :)
declare variable $articleSection as xs:string := "articleSection";

(: Var used to specify the search type :)
declare variable $searchType as xs:string := "searchType";

(: Var used to specify the search term :)
declare variable $searchTerm as xs:string := "searchTerm";

(: Var used to specify the hidden formId :)
declare variable $hiddenForm as xs:string := "hiddenForm";

(: Var used to specify the result Page :)
declare variable $searchResultPage as xs:string := "searchResultPage";

(: Var used to specify the total results of the search Page :)
declare variable $searchTotalResults as xs:string := "searchTotalResults";

(: Var used to specify the number of results per Page :)
declare variable $pageSize as xs:unsignedLong := 10;