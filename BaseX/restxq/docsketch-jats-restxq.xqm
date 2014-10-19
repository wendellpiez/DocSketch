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
declare %rest:path("DocSketch/JATS-view/{$journal}/start.html")
        %output:method("xhtml")
        %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
        %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
        %output:omit-xml-declaration("no")
  function page:docsketch-jatsview-toc($journal as xs:string) {

  let $title := 'Document Sketch: JATS View - ' || $journal
  let $db    := db:open($journal)
  let $html  := document {
  <html>
    { sk:docsketch-html-head($title)}
    <body>
      { sk:docsketch-masthead($title)}
      <div>
      <h4>{ count($db)} articles</h4>
      <ul>
      { for $volumeArticles in $db/article
        where ($volumeArticles/front/article-meta/volume castable as xs:integer and
               $volumeArticles/front/article-meta/issue  castable as xs:integer)
        order by number($volumeArticles/front/article-meta/volume),
                 number($volumeArticles/front/article-meta/issue)
        let $volumeNo := $volumeArticles/front/article-meta/volume/number()
        group by $volumeNo
        return <li><p style="margin: 0px">Volume { $volumeNo }</p>
        <ul>
        {
         for $issueArticles in $volumeArticles
         let $issueNo := $issueArticles/front/article-meta/issue/number()
         group by $issueNo
         return <li><span class="issue">Issue { $issueNo }&#xA0;({ count($issueArticles)} articles)</span>
         &#xA0;<a class="maplink" href="../JATS-element-map/{$journal}/{$volumeNo}/{$issueNo}">[Element map]</a>
          &#xA0;<a class="maplink" href="../JATS-xref-graph/{$journal}/{$volumeNo}/{$issueNo}">[xref graph]</a></li>
        }
        </ul></li> }
        </ul>
      </div>
    </body>
  </html> }
  return sk:run-xslt($html,(sk:fetch-xslt('xhtml-ns.xsl')),()) (: cast HTML into XHTML namespace before delivering... :)
};

declare %rest:path("DocSketch/JATS-view/{$view}/{$journal}/{$volume}/{$issue}")
        %output:method("xhtml")
        %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
        %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
        %output:omit-xml-declaration("no")
  function page:docsketch-jatsview-toc($view    as xs:string,
                                       $journal as xs:string,
                                       $volume  as xs:string,
                                       $issue   as xs:string) {

  let $title    := 'Document Sketch: JATS View - ' || $journal
  let $articles := db:open($journal)
                     [(article/front/article-meta/volume = $volume) and
                      (article/front/article-meta/issue  = $issue)]
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
};


declare %rest:path("DocSketch/JATS-element-map/start.html")
        %output:method("xhtml")
        %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
        %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
        %output:omit-xml-declaration("no")
  function page:pmc-oa-docsketch() {

  let $title        := 'Document Sketch: JATS element map'
  let $html         := document {
  <html>
    { sk:docsketch-html-head($title)}
    <body>
      { sk:docsketch-masthead($title)}
      { sk:pmc-oa-request-form('') }
    </body>
  </html> }
  return sk:run-xslt($html,(sk:fetch-xslt('xhtml-ns.xsl')),()) (: cast HTML into XHTML namespace before delivering... :)
};


(:~
 : This function returns the result of a form request.
 : @param  $message  message to be included in the response
 : @param $agent  user agent string
 : @return response element 
 :)
declare
  %rest:path("DocSketch/JATS-element-map/request.html")
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
  let $docs         := sk:execute-pmc-query($query)
                       (: $sk:testDoc :)
  let $xsltPipeline := $sk:requestPipelines/request[@name='JATS-element-map']/xslt/sk:fetch-xslt(.)
  let $html         := document {
  
  <html>
    { sk:docsketch-html-head($title)}
    <body>
      { sk:docsketch-masthead($title)}
      { if (exists($docs/EXCEPTION))
          then
            (<h4>Sorry, your query is not well-formed</h4>,
             sk:pmc-oa-request-form($query) )
          else
            (sk:pmc-oa-request-form($query),
      
        <div style="margin-top:1ex; border-top: medium solid black">
          <h4>Query:</h4>
          <pre style="max-width:80%">{ $query }</pre>
          <h4 style="font-style:italic">{ count($docs) }
            {()} document{if (count($docs) eq 1) then '' else 's'} returned</h4>  
        { for $journalDocs in $docs
          let $journal := $journalDocs/*/front/journal-meta/descendant::journal-title[1]
          group by $journal
          return
          <div class="journalGroup">
            <h3 class="journalTitle">{ $journal }</h3>
            { for $doc in $journalDocs return 
              <div class="article">
                <h4 class="articleTitle">{
                   string-join($doc/*/front/article-meta/title-group/article-title,':') }
                </h4>
                <p class="docLocation">{ document-uri($doc) }</p>
                <div class="svg">
                  { sk:run-xslt-pipeline($doc,$xsltPipeline,()) }
                </div>
              </div> }
          </div> }
        </div> ) }
    </body>
  </html> }
  return sk:run-xslt($html,(sk:fetch-xslt('xhtml-ns.xsl')),())
  (: cast HTML into XHTML namespace before delivering... :)
};

