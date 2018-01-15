(:
 : 
 
 To do:
   Wire up db map: db title to BaseX db
   Implement db directory
   SVG XSLT per document via links
   SVG map of document set(s)
 
 :)
module namespace page = 'http://basex.org/modules/web-page';

import module namespace sk = "http://wendellpiez.com/ns/DocSketch" at "../xquery/docsketch.xqm";

(: declare default element namespace "http://www.w3.org/1999/xhtml"; :)
declare namespace svg = "http://www.w3.org/2000/svg";

(: declare %rest:path("DocSketch/WB-NLM/start.html")
        %output:method("xhtml")
        %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
        %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
        %output:omit-xml-declaration("no")
  function page:docsketch-jatsview-toc() {

  let $title := 'Document Sketch: WB-NLM View - '
  let $db    := db:open('WBNLM-Samples')
  let $html  := document {
  <html>
    { sk:docsketch-html-head($title)}
    <body>
      { sk:docsketch-masthead($title)}
      <div>
      <h4>{ count($db)} books</h4>
      <!-- 
 <ul>
      { for $book in $db/book
        let $bookTitle := $book/book-meta/book-title-group/book-title/normalize-space(.)
        let $bookId    := $book/book-meta/book-id[@pub-id-type='doi']/substring-after(.,'10.1596/')
        return
         <li><span class="issue">{ $bookTitle }</span>
          
         </li> }
        </ul> -->
      </div>
      {  for $doc in $db
         return 
            <div class="book">
                <h4 class="bookTitle">{ $doc/book/book-meta/book-title-group/book-title/normalize-space(.) }
                </h4>
                <h5>{ $doc/*/name() }</h5>
                <div class="svgx">
                { sk:run-xslt-pipeline($doc,
                  $sk:requestPipelines/request[@name='WB-NLM-graph']/xslt/sk:fetch-xslt(.),
                  ()) }
                </div>
              </div> }
    </body>
  </html> }
  return sk:run-xslt($html,(sk:fetch-xslt('xhtml-ns.xsl')),()) (: cast HTML into XHTML namespace before delivering... :)
}; :)

(: declare %rest:path("DocSketch/WB-NLM-element-map/{$bookID}")
        %output:method("xhtml")
        %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
        %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
        %output:omit-xml-declaration("no")
  function page:docsketch-wbnlmView-toc($bookId as xs:string) {
  
  let $book := db:open('WBNLM-Samples')/book[ book-meta/book-id[@pub-id-type='doi'] = ( '10.1596/' || $bookId ) ]
  let $title    := 'Document Sketch: JATS View - ' || $book/book-meta/book-title-group/book-title/normalize-space(.)
  let $xsltPipeline := $sk:requestPipelines/request[@name=$view]/xslt/sk:fetch-xslt(.)
  let $html  := document {
  <html>
    { sk:docsketch-html-head($title)}
    <body>
      { sk:docsketch-masthead($title)}
      <div>
      <p><a href="../../../{$journal}/start.html">Back to journal page</a></p></div>
      <div style="clear:both">
      <h3>{ count($articles)} articles</h3>
      { for $article in $articles return 
              <div class="article">
                <h4 class="articleTitle">{
                   string-join($article/*/front/article-meta/title-group/article-title,':') }
                </h4>
                <p class="docLocation">{ document-uri($article) }</p>
                <div class="svg">
                  { sk:run-xslt-pipeline($article,$xsltPipeline,()) }
                </div>
              </div> }

      </div>
    </body>
  </html> }
  return sk:run-xslt($html,(sk:fetch-xslt('xhtml-ns.xsl')),()) (: cast HTML into XHTML namespace before delivering... :)
}; :)


declare %rest:path("DocSketch/WBNLM/start.html")
        %output:method("xhtml")
        %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
        %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
        %output:omit-xml-declaration("no")
  function page:wbnlm-docsketch() {

  let $title        := 'Document Sketch: WBNLM element map'
  let $html         := document {
  <html>
    { sk:docsketch-html-head($title)}
    <body>
      { sk:docsketch-masthead($title)}
      { sk:wbnlm-query-request-form('/book') }
    </body>
  </html> }
  return sk:run-xslt($html,(sk:fetch-xslt('xhtml-ns.xsl')),()) (: cast HTML into XHTML namespace before delivering... :)
};


declare
  %rest:path("DocSketch/WBNLM/request.html")
  %rest:POST
  %rest:form-param("query","{$query}", "(no message)")
  %rest:header-param("User-Agent", "{$agent}")
  %output:method("xhtml")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
        %output:omit-xml-declaration("no")
  function page:return-wbnlm-query-request(
    $query as xs:string,
    $agent   as xs:string*)
    as document-node()
{
  let $title   := 'DocSketch: WBNLM document map'
  let $docs    := sk:execute-wbnlm-query($query)[. instance of node()]/root()
  let $nonDocs := sk:execute-wbnlm-query($query)[not(. instance of node())]                     (: $sk:testDoc :)
  let $xslt    := sk:wbnlm-query-graph-xslt($query)
  let $html    := document {
  
  <html>
    { sk:docsketch-html-head($title)}
    <body>
      { sk:docsketch-masthead($title)}
      { if (exists($docs/EXCEPTION))
          then
            (<h4>Sorry, your query did not succeed. Its syntax is not correct, or there is a wiring problem
            in back.</h4>,
             sk:wbnlm-query-request-form($query) )
          else
            (sk:wbnlm-query-request-form($query),
      
        <div style="margin-top:1ex; border-top: medium solid black">
          <h4>Query:</h4>
          <pre style="max-width:80%">{ $query }</pre>
          { if (exists($nonDocs)) then
            <pre style="max-width:80%">{ string-join($nonDocs ! string(.), '&#xA;') }</pre>
            else () }
          <h4 style="font-style:italic">{ count($docs) }
            {()} document{if (count($docs) eq 1) then '' else 's'} returned</h4>  
          { for $doc in $docs
            let $bookTitle := $doc/book/book-meta/book-title-group/book-title/normalize-space(.)
            let $bookId    := $doc/book/book-meta/book-id[@pub-id-type='doi']/substring-after(.,'10.1596/')
            return
            <div class="book">
              <h4 class="bookTitle">
                 <a href="{$bookId}/map.html">{ $bookTitle }
                 </a></h4>
              <p class="docLocation">{ document-uri($doc) }</p>
              <div class="svg-graph">{ sk:run-xslt-pipeline($doc,$xslt,()) }</div>
            </div> }
              </div> ) }
    </body>
  </html> }
  return sk:run-xslt($html,(sk:fetch-xslt('xhtml-ns.xsl')),())
  (: cast HTML into XHTML namespace before delivering... :)
};

declare %rest:path("DocSketch/WBNLM/{$bookId}/map.html")
        %output:method("xhtml")
        %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
        %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
        %output:omit-xml-declaration("no")
  function page:dhq-map-docsketch($bookId as xs:string) {
    
                                       

  let $title   := 'DOCSKETCH: WBNLM article view'
  let $doc     := db:open('WBNLM-Samples')[/book/book-meta/book-id[@pub-id-type='doi']/substring-after(.,'10.1596/') eq $bookId]
  let $viewSVG := sk:run-xslt-pipeline($doc,
                    $sk:requestPipelines/request[@name='WBNLM-map']/xslt/sk:fetch-xslt(.),
                    () )
  let $html         := document {
  <html>
    { sk:docsketch-html-head($title)}
    <body>
     { sk:docsketch-masthead($title)}
     
       
       <div>
            <h4 class="articleTitle">{
               $doc/book/book-meta/book-title-group/book-title/normalize-space(.) }
            </h4>
            <p class="docLocation">{ document-uri($doc) }</p>
            <div class="svg-view">
              { $viewSVG }
            </div>
            
          </div>
          
          
          <h5><a href="../start.html">Return (new query)</a></h5>
    </body>
  </html> }
  return sk:run-xslt($html,(sk:fetch-xslt('xhtml-ns.xsl')),())
  (: cast HTML into XHTML namespace before delivering... :)
};





(:~
 : This function returns the result of a form request.
 : @param  $message  message to be included in the response
 : @param $agent  user agent string
 : @return response element 
 :)
(: declare
  %rest:path("DocSketch/WBNLM/request.html")
  %rest:POST
  %rest:form-param("query","{$query}", "(no message)")
  %rest:header-param("User-Agent", "{$agent}")
  %output:method("xhtml")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
        %output:omit-xml-declaration("no")
  function page:return-pmc-oa-request(
    $query as xs:string,
    $agent   as xs:string*)
    as document-node()
{
  let $title        := 'Document Sketch: JATS Element Map'
  let $docs         := sk:execute-wbnlm-query($query)
                       
  let $xsltPipeline := $sk:requestPipelines/request[@name='WB-NLM-graph']/xslt/sk:fetch-xslt(.)
  let $html         := document {
  
  <html>
    { sk:docsketch-html-head($title)}
    <body>
      { sk:docsketch-masthead($title)}
      { if (exists($docs/EXCEPTION))
          then
            (<h4>Sorry, your query is not well-formed</h4>,
             sk:wbnlm-request-form($query) )
          else
            (sk:wbnlm-request-form($query),
      
        <div style="margin-top:1ex; border-top: medium solid black">
          <h4>Query:</h4>
          <pre style="max-width:80%">{ $query }</pre>
          <h4 style="font-style:italic">{ count($docs) }
            {()} document{if (count($docs) eq 1) then '' else 's'} returned</h4>  
        { for $doc in $docs
          let $bookTitle := $doc/book/book-meta/book-title-group/book-title/normalize-space(.)
          let $bookId    := $doc/book/book-meta/book-id[@pub-id-type='doi']/substring-after(.,'10.1596/')
          return
              <div class="book">
                <h4 class="bookTitle">{ $bookTitle }</h4>
                <p class="docLocation">{ document-uri($doc) }</p>
                <div class="svg">
                  { sk:run-xslt-pipeline($doc,$xsltPipeline,()) }
                </div>
              </div> }
              </div>
    </body>
  </html> }
  return sk:run-xslt($html,(sk:fetch-xslt('xhtml-ns.xsl')),()) : )
  ( : cast HTML into XHTML namespace before delivering... : )
}; :)
