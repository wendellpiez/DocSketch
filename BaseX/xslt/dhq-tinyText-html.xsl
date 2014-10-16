<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/2000/svg"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
  
  xmlns:dsk="http://wendellpiez.com/docsketch/xslt/util"
  exclude-result-prefixes="#all"
  version="2.0">

  <xsl:import href="dhq2html.xsl"/>
  
  <xsl:param name="bioFile" select="''"/>
  
  <xsl:template match="/">
    <!--<html>
      <head>
        <title>
          <xsl:text>[PREVIEW] DHQ: Digital Humanities Quarterly: </xsl:text>
          <xsl:value-of select="/tei:TEI/tei:text/tei:body/tei:head"/>
        </title>
        <!-\-<link href="../../common/css/dhq.css" type="text/css" rel="stylesheet"/>
        <link href="../../common/css/dhq_screen.css" media="screen" type="text/css" rel="stylesheet"/>
        <link href="../../common/css/dhq_print.css" media="print" type="text/css" rel="stylesheet"/>-\->
        <style type="text/css">
          #mainContent {
          float: none;
          padding-top: 2em;
          padding-left: 4em;
          padding-right: 4em;
          margin-left: 225px;
          
          }</style>
        <script src="../../common/js/javascriptLibrary.js" type="text/javascript"/>
      </head>
      <body>-->
        <div id="mainContent">
          <xsl:apply-templates/>
        </div>
      <!--</body>
    </html>-->
  </xsl:template>
  
  <xsl:template name="pubInfo">
    <div id="pubInfo">
      <xsl:text>Preview</xsl:text>
      <br/>
      <xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt">
        <xsl:for-each select="tei:idno[@type='volume']">
          <xsl:text>Volume&#160;</xsl:text>
          <xsl:value-of select="."/>
        </xsl:for-each>
        <xsl:for-each select="tei:idno[@type='issue']">
          <xsl:text>&#160;Number&#160;</xsl:text>
          <xsl:value-of select="."/>
        </xsl:for-each>
      </xsl:for-each>
    </div>
  </xsl:template>
  
  <xsl:template name="toolbar_top"/>
  
  <xsl:template name="toolbar">
    <!--<div class="toolbar">
      <a href="#">
        <xsl:text>Preview</xsl:text>
      </a> &#x00a0;|&#x00a0; <span style="color: grey">
        <xsl:text>XML</xsl:text>
      </span> |&#x00a0; <a href="#" onclick="javascript:window.print();"
        title="Click for print friendly version">Print Article</a>
    </div>-->
  </xsl:template>
  
  <xsl:template name="toolbar_with_tapor">
    <xsl:call-template name="toolbar"/>
  </xsl:template>
  
  <xsl:template match="tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo">
    <!-- Using lower-case of author's last name + first initial to sort [CRB] -->
    <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
    <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
    <xsl:variable name="bios">
      <xsl:value-of
        select="translate(concat(translate(dhq:author_name/dhq:family,' ',''),'_',substring(normalize-space(dhq:author_name),1,1)),$upper,$lower)"
      />
    </xsl:variable>
    <div class="author">
      <span style="color: grey">
        <xsl:apply-templates select="dhq:author_name"/>
      </span>
      <xsl:if test="normalize-space(child::dhq:affiliation)">
        <xsl:apply-templates select="tei:email" mode="author"/>
        <xsl:text>,&#160;</xsl:text>
      </xsl:if>
      <xsl:apply-templates select="dhq:affiliation"/>
    </div>
  </xsl:template>
  
  
</xsl:stylesheet>