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
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace dhq = "http://www.digitalhumanities.org/ns/dhq";

declare %rest:path("DocSketch")
        %output:method("xhtml")
        %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
        %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
        %output:omit-xml-declaration("no")
  function page:docsketch-home() {

  let $title        := 'Document Sketch (DOCSKETCH)'
  let $html         := document {
  <html>
    { sk:docsketch-html-head($title)}
    <body>
      { sk:docsketch-masthead($title)}
      <div>
        <h4><a href="DocSketch/JATS-view/Aging_(Albany_NY)/start.html">JATS maps - Aging (Albany) [from PMC Open Access]</a></h4>
        <h4><a href="DocSketch/DHQ-query/start.html">Digital Humanities Quarterly</a></h4>
        <h4><a href="DocSketch/OHCO/frankenstein.html">The case of&#xA0;<i>Frankenstein: or, the Modern Prometheus</i></a></h4>
      </div>
    </body>
  </html> }
  return sk:run-xslt($html,(sk:fetch-xslt('xhtml-ns.xsl')),()) (: cast HTML into XHTML namespace before delivering... :)
};



declare %rest:path("DocSketch/DHQ-query/start.html")
        %output:method("xhtml")
        %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
        %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
        %output:omit-xml-declaration("no")
  function page:dhq-query-docsketch() {

  let $title        := 'DOCSKETCH: DHQ article query'
  let $html         := document {
  <html>
    { sk:docsketch-html-head($title)}
    <body>
      { sk:docsketch-masthead($title)}
      { sk:dhq-query-request-form('') }
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
declare
  %rest:path("DocSketch/DHQ-query/request.html")
  %rest:POST
  %rest:form-param("query","{$query}", "(no message)")
  %rest:header-param("User-Agent", "{$agent}")
  %output:method("xhtml")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
        %output:omit-xml-declaration("no")
  function page:return-dhq-query-request(
    $query as xs:string,
    $agent   as xs:string*)
    as document-node()
{
  let $title   := 'DocSketch: DHQ document map'
  let $docs    := sk:execute-dhq-query($query)[. instance of node()]/root()
  let $nonDocs := sk:execute-dhq-query($query)[not(. instance of node())]                     (: $sk:testDoc :)
  let $xslt    := sk:dhq-query-graph-xslt($query)
  let $html    := document {
  
  <html>
    { sk:docsketch-html-head($title)}
    <body>
      { sk:docsketch-masthead($title)}
      { if (exists($docs/EXCEPTION))
          then
            (<h4>Sorry, your query did not succeed. Its syntax is not correct, or there is a wiring problem
            in back.</h4>,
             sk:dhq-query-request-form($query) )
          else
            (sk:dhq-query-request-form($query),
      
        <div style="margin-top:1ex; border-top: medium solid black">
          <h4>Query:</h4>
          <pre style="max-width:80%">{ $query }</pre>
          { if (exists($nonDocs)) then
            <pre style="max-width:80%">{ string-join($nonDocs ! string(.), '&#xA;') }</pre>
            else () }
          <h4 style="font-style:italic">{ count($docs) }
            {()} document{if (count($docs) eq 1) then '' else 's'} returned</h4>  
        { for $doc in $docs
          let $articleNo := $doc//tei:idno[@type='DHQarticle-id']/string(.)
          (:let $journal := TEI/teiHeader/fileDesc/titleStmt/title
          group by $journal:)
          return
          <div class="article">
             <h4 class="articleTitle">
             <a href="{$articleNo}/map.html">{
                   string-join($doc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title,':') }</a>
                   { $doc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt[exists(dhq:authorInfo/dhq:author_name/dhq:family)]/
                     (' [' || sk:and-sequence(dhq:authorInfo/dhq:author_name/dhq:family) || ']') }
               </h4>
            <p class="docLocation">{ document-uri($doc) }</p>
            <div class="svg-graph">
              { sk:run-xslt-pipeline($doc,$xslt,()) }
            </div>
          </div> }
        </div> ) }
    </body>
  </html> }
  return sk:run-xslt($html,(sk:fetch-xslt('xhtml-ns.xsl')),())
  (: cast HTML into XHTML namespace before delivering... :)
};


declare %rest:path("DocSketch/DHQ-query/{$article}/map.html")
        %output:method("xhtml")
        %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
        %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
        %output:omit-xml-declaration("no")
  function page:dhq-map-docsketch($article as xs:string) {
    
                                       

  let $title   := 'DOCSKETCH: DHQ article view'
  let $doc     := $sk:dhqArticles[matches(document-uri(/),($article || '.xml$'))]
  let $viewSVG := sk:run-xslt-pipeline($doc,
                    $sk:requestPipelines/request[@name='DHQ-map']/xslt/sk:fetch-xslt(.),
                    () )
  let $html         := document {
  <html>
    { sk:docsketch-html-head($title)}
    <body>
     { sk:docsketch-masthead($title)}
     
       
       <div>
            <h4 class="articleTitle">{
               string-join($doc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title,':') }
            </h4>
            <p class="docLocation">{ document-uri($doc) }</p>
            <div class="dhq-view">
              { $viewSVG }
            </div>
            <div class="tinyText">
              { sk:run-xslt-pipeline($doc,
                  $sk:requestPipelines/request[@name='DHQ-tinyText']/xslt/sk:fetch-xslt(.),
                  ()) }
            </div>
            
          </div>
          
          
          <h5><a href="../start.html">Return (new query)</a></h5>
    </body>
  </html> }
 
  return sk:run-xslt($html,(sk:fetch-xslt('xhtml-ns.xsl')),())
  (: cast HTML into XHTML namespace before delivering... :)
};



declare %rest:path("DocSketch/OHCO/frankenstein.html")
        %output:method("xhtml")
        %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
        %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
        %output:omit-xml-declaration("no")
  function page:frankenstein-docsketch-html() as document-node()
{
  let $title        := 'Document Sketch: Frankenstein'
  let $doc          := db:open("LMNL-library","Frankenstein.xlmnl")
  let $xsltPipeline := $sk:requestPipelines/request[@name='frankenstein']/xslt/sk:fetch-xslt(.)
  let $html         := document {
  
  <html>
    { sk:docsketch-html-head($title)}
    <body>
      { sk:docsketch-masthead($title)}
      <div style="margin-top:1ex; border-top: medium solid black">
        { sk:run-xslt-pipeline($doc,$xsltPipeline,()) }
      </div>
    </body>
  </html> }
  return sk:run-xslt($html,(sk:fetch-xslt('xhtml-ns.xsl')),())
  (: cast HTML into XHTML namespace before delivering... :)
};

declare %rest:path("DocSketch/OHCO/lmnl/{$item}/bubblemap.svg")
        %output:method("xml")
        %output:media-type("image/svg+xml")
        %output:doctype-public("-//W3C//DTD SVG 1.1//EN")
        %output:doctype-system("http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd")
        %output:omit-xml-declaration("no")
  function page:lmnl-docsketch-svg($item as xs:string) as document-node()
{
  
let $index := map {
   "Frankenstein-1818ed"              :=
      'Frankenstein1818.xlmnl' ,
   "Frankenstein-1831ed" :=
      'Frankenstein1831.xlmnl', 
   "Frankenstein" :=
      'Frankenstein.xlmnl' }
  
  let $xsltPipeline := $sk:requestPipelines/request[@name='frankenstein']/xslt/sk:fetch-xslt(.)
  let $doc          := 
    map:get($index,$item) ! db:open("LMNL-library",.)
  
  return sk:run-xslt-pipeline($doc,$xsltPipeline,())
};

  
(: for $file in map:keys($fileSet) :)

declare %rest:path("DocSketch/OHCO/frankenstein.svg")
        %output:method("xml")
        %output:media-type("image/svg+xml")
        %output:doctype-public("-//W3C//DTD SVG 1.1//EN")
        %output:doctype-system("http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd")
        %output:omit-xml-declaration("no")
  function page:frankenstein-docsketch-svg() as document-node()
{
  let $xsltPipeline := $sk:requestPipelines/request[@name='frankenstein']/xslt/sk:fetch-xslt(.)
  let $doc          := db:open("LMNL-library","Frankenstein-as-published.xlmnl")
  
  return sk:run-xslt-pipeline($doc,$xsltPipeline,())
};

declare %rest:path("DocSketch/OHCO/frankenstein1818.svg")
        %output:method("xml")
        %output:media-type("image/svg+xml")
        %output:doctype-public("-//W3C//DTD SVG 1.1//EN")
        %output:doctype-system("http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd")
        %output:omit-xml-declaration("no")
  function page:frankenstein1818-docsketch-svg() as document-node()
{
  let $xsltPipeline := $sk:requestPipelines/request[@name='frankenstein']/xslt/sk:fetch-xslt(.)
  let $doc          := db:open("LMNL-library","Frankenstein1818.xlmnl")
  
  return sk:run-xslt-pipeline($doc,$xsltPipeline,())
};

declare %rest:path("DocSketch/OHCO/frankenstein.xlmnl")
        %output:method("xml")
        %output:omit-xml-declaration("no")
  function page:frankenstein-xlmnl() as document-node() {
     db:open("LMNL-library","Frankenstein1831.xlmnl") };


(: http://cypress:8984/DocSketch/DHQ-query/000004/resources/images/figure03.jpg :)
declare %rest:path("DocSketch/DHQ-query/{$articleNo}/resources/{$resource}")
        %output:method("raw")
  function page:dhq-resource($articleNo as xs:string, $resource as xs:string) {
    let $path := $sk:dhq-articlesPath ||
                 $articleNo || '/resources/' || $resource
    return
  file:read-binary($path) 
};

declare %rest:path("DocSketch/DHQ-query/{$articleNo}/resources/images/{$resource}")
        %output:method("raw")
  function page:dhq-image-resource($articleNo as xs:string, $resource as xs:string) {
    let $path := $sk:dhq-articlesPath ||
                 $articleNo || '/resources/images/' || $resource
    return
  file:read-binary($path) 
};

declare %rest:path("DocSketch/DHQ-query/debug.xml")
        %output:method("xml")
        %output:omit-xml-declaration("no")
  function page:dhq-debug() {
 sk:dhq-query-graph-xslt('//testQuery')   
};