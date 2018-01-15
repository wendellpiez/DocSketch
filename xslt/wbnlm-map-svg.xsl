<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/2000/svg"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:dsk="http://wendellpiez.com/docsketch/xslt/util"
  exclude-result-prefixes="#all"
  version="2.0">
  

  <xsl:param name="querySet" select="()"/>
  
  <xsl:variable name="squeeze" select="0.005"/>
  <xsl:variable name="vertical-margin"  select="6"/>

  <xsl:variable name="page-width" select="800"/>
  

  <xsl:output indent="yes"/>
    <!--doctype-public="-//W3C//DTD SVG 1.0//EN"
    doctype-system="http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd"/>-->

  <!--<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.0//EN" "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">-->

  <xsl:template match="/book">
    <xsl:apply-templates select="$range-map"/>
    
    <!--<xsl:copy-of select="$range-map"/>-->
  </xsl:template>
  
  <!-- $range-map must be a document node so we can key in. -->
  <xsl:variable name="range-map">
    <dsk:ranges>
      <xsl:apply-templates mode="ranges" select="/*">
        <xsl:with-param name="offset" tunnel="yes" select="0"/>
      </xsl:apply-templates>
    </dsk:ranges>
  </xsl:variable>
  
  
  <xsl:template name="continue">
    <xsl:param tunnel="yes" name="offset" required="yes"/>
    <xsl:apply-templates select="node()[1]" mode="ranges"/>
    <xsl:apply-templates select="following-sibling::node()[1]" mode="ranges">
      <xsl:with-param tunnel="yes" name="offset" select="$offset + string-length(.)"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="* | text()" mode="ranges">
    <xsl:call-template name="continue"/>
  </xsl:template>
  
  <xsl:template match="comment() | processing-instruction()" mode="ranges">
    <xsl:apply-templates select="following-sibling::node()[1]" mode="ranges"/>
  </xsl:template>
  
  <xsl:template match="*" mode="ranges" priority="2">
    <!-- $in designates an arbitrary value for any node with ancestor::*/@metadata-key=$in -->
    <xsl:param tunnel="yes" name="offset" required="yes"/>
    <dsk:mark offset="{$offset}" length="{string-length(.)}" generated-id="{generate-id(.)}"
      depth="{count(ancestor::*)}" name="{name(.)}">
      <xsl:copy-of select="@id | (@metadata-key except /*/@metadata-key)"/>
      <!-- We are in the same chunk if a link target has more than an ancestor,
           not the document element /*, with the same @metadata-key -->
      <xsl:for-each select="ancestor-or-self::*[exists(@metadata-key)][1]/@metadata-key">
        <xsl:attribute name="chunk" select="."/>
      </xsl:for-each>
      <!--  This should be factored out into another template matching xref and generating an element
      (another mark) not just attributes; then factor out the calling side as well. -->
      
      <!-- <xsl:if test="key('element-by-id',@rid)/(ancestor-or-self::* except /book)/@metadata-key
          = (ancestor-or-self::* except /book)/@metadata-key">
        <xsl:attribute name="xref">same</xsl:attribute>
      </xsl:if>-->
      
    </dsk:mark>
    <xsl:next-match/>
  </xsl:template>
  
  
  
  <xsl:template match="book" mode="ranges" priority="3">
    <xsl:param tunnel="yes" name="offset" required="yes"/>
    <dsk:axis offset="{$offset}" length="{string-length(.)}" name="{name(.)}"/>
    <xsl:next-match/>
  </xsl:template>

  <xsl:template mode="ranges" priority="3"
    match="p//* | title//* | fig//* | sig-block//* | boxed-text//* | label//* | attrib//* | 
           list//* | table-wrap//* | disp-quote//* | caption//* | graphic//* | def-list//* | 
           fn-group//* | fn//* | ref-list//*">
    <xsl:call-template name="continue"/>
  </xsl:template>

  <xsl:template match="xref" mode="ranges" priority="4">
    <xsl:param tunnel="yes" name="offset" required="yes"/>
    <dsk:xref offset="{$offset}">
      <xsl:copy-of select="@rid"/>
      <xsl:attribute name="chunk-link-type">
        <xsl:choose>
          <xsl:when test="key('element-by-id',@rid)/(ancestor-or-self::* except /book)/@metadata-key
            = (ancestor-or-self::* except /book)/@metadata-key">intra</xsl:when>
          <xsl:otherwise>inter</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </dsk:xref> 
    <xsl:next-match/>
  </xsl:template>

  <xsl:key name="element-by-id" match="*[@id]" use="@id"/>
  
  <!--<xsl:template match="*[dsk:hit(.)]" mode="ranges" priority="3">
    <xsl:param tunnel="yes" name="offset" required="yes"/>
    <dsk:hit offset="{$offset}" length="{string-length(.)}" name="{name(.)}"/>
    <xsl:next-match/>
  </xsl:template>-->
  
  <!--  <xsl:template match="xref" mode="ranges">
    <xsl:param tunnel="yes" name="offset" required="yes"/>
    <xsl:for-each select="tokenize(@rid,'\s+')">
      <dsk:xref offset="{$offset}" target="{.}"/>
    </xsl:for-each>
    <xsl:call-template name="continue"/>
  </xsl:template>
  
  <xsl:key name="xref-by-rid" match="xref[@rid]" use="tokenize(@rid,'\s+')"/>
  
  <xsl:template match="*[exists(key('xref-by-rid',@id))]" mode="ranges">
    <xsl:param tunnel="yes" name="offset" required="yes"/>
    <dsk:target offset="{$offset}" length="{string-length(.)}" id="{@id}" name="{name(.)}"/>
    <xsl:call-template name="continue"/>
  </xsl:template>-->
  
  <xsl:template match="dsk:ranges">
    <xsl:variable name="height" select="dsk:round-and-format((2 * $vertical-margin) + dsk:scale(dsk:axis/@length))"/>
    <svg version="1.1"
      viewBox="0 0 {$page-width} {$height}" height="{$height}" width="{$page-width}">
      <rect height="{$height}" width="{$page-width}" fill="white"
        stroke="black"/>
      <g transform="translate(50 {$vertical-margin})">
        <xsl:apply-templates select="dsk:axis, dsk:mark, dsk:xref, dsk:hit"/>
        
        <xsl:variable name="yTop" select="20"/>
        <!--<xsl:variable name="lineHeight"   select="(number($height) - (2* $yTop)) div count(distinct-values(*/@metadata-key))"/>-->
        <xsl:variable name="lineHeight" as="xs:decimal">60</xsl:variable>
        <xsl:for-each-group select="dsk:mark/@metadata-key/.." group-by="@metadata-key">
          <xsl:variable name="pos" select="position()"/>
          <xsl:variable name="y"   select="$yTop + ($pos * $lineHeight)"/>
          <circle cx="{$keyAxis + 20}" cy="{$y}" r="1" fill="none" stroke-width="0.2" stroke="black"/>
          <text    x="{$keyAxis + 22}"  y="{$y}" font-size="4">
            <xsl:value-of select="current-grouping-key()"/>
          </text>
          <!-- now iterating over the marks with each @metadata-key -->
          <xsl:for-each select="current-group()">
            <line x1="{$keyAxis}" x2="{$keyAxis + 20}"
              y1="{dsk:round-and-format(dsk:scale(@offset + (@length div 2)))}"
              y2="{$y}" stroke="black" stroke-width="0.2"/>
          </xsl:for-each>
        </xsl:for-each-group>
          
      </g>
    </svg>
  </xsl:template>
  
  <xsl:template match="dsk:axis">
    <line y1="0" y2="{dsk:round-and-format(dsk:scale(@length))}" x1="0" x2="0"
      stroke="grey" stroke-width="0.1"/>
  </xsl:template>
  
  <xsl:key name="mark-by-id" match="dsk:mark[exists(@id)]" use="@id"/>

  <xsl:variable name="keyAxis" select="170"/>
  
  <xsl:template match="dsk:mark">
    <xsl:variable select="." name="here"/>
    <xsl:variable name="y" select="dsk:round-and-format(dsk:scale($here/@offset))"/>
    <xsl:variable name="yExtent" select="dsk:round-and-format(dsk:scale($here/@length))"/>
    <xsl:variable name="yCenter" select="dsk:round-and-format(dsk:scale(@offset + (@length div 2)))"/>
    
    <ellipse cx="0" cy="{$yCenter}" title="{@name}"
      rx="{dsk:round-and-format(dsk:scale(@length div 2))}"
      ry="{dsk:round-and-format(dsk:scale(@length div 2))}">
      <xsl:apply-templates select="." mode="format"/>
    </ellipse>
    
    <!--<!-\- drawing arcs from any elements pointing here (they should represent xrefs) -\->
    <xsl:for-each select="key('mark-by-id',@id)">
     <xsl:variable name="toY" select="dsk:round-and-format(dsk:scale(@offset))"/>
      <!-\- first drawing an arc for the xref to the target ($here) -\->
      <xsl:variable name="sameChunk" select="@xref='in-chunk'"/>
      <xsl:variable name="reach" select="45 - (number($sameChunk) * 10)"/>
      <path d="M 0 {$y} C {$reach} {$y} {$reach} {$toY} 0 {$toY}">
        <xsl:apply-templates select="." mode="format"/>
        <xsl:attribute name="fill">none</xsl:attribute>        
      </path>
    </xsl:for-each>-->
      
      <!-- Next drawing a box for any element with an @id -->
    <xsl:if test="exists(@id)">
      <xsl:variable name="x" select="50 + (5 * $here/@depth)"/>
      <xsl:variable name="xExtent" select="5 * $here/@depth"/>
      <rect title="{@name}" x="{$x}" y="{$y}" width="{$xExtent}" height="{$yExtent}">
        <xsl:apply-templates select="$here" mode="format"/>
        <xsl:attribute name="stroke-width">0.5</xsl:attribute>
      </rect><!--
      <path d="M {$x} {$y} L {$xExtent} {$y} L {$xExtent} {$yExtent}">-->
    </xsl:if>
    
    <!-- And a vertical bar for any element with a @metadata key -->
    <xsl:if test="exists(@metadata-key)">
      <rect title="{@name}" x="160" width="20" y="{$y}" height="{$yExtent}">
        <xsl:apply-templates select="$here" mode="format"/>
      </rect>
      <circle cx="{$keyAxis}" cy="{$yCenter}" r="1">
        <xsl:apply-templates select="$here" mode="format"/>
      </circle>
    </xsl:if>
    
      <!--</path>-->
      
  </xsl:template>
  
  <xsl:template match="dsk:xref">
    <xsl:variable name="xref" select="."/>
    <xsl:variable name="y" select="dsk:round-and-format(dsk:scale(@offset))"/>
    <!--<xsl:variable name="yEnd" select="dsk:round-and-format(dsk:scale($here/(@offset + @length)))"/>-->
    <!--<xsl:variable name="yExtent" select="dsk:round-and-format(dsk:scale($here/@length))"/>-->
    <!--<xsl:variable name="yCenter" select="dsk:round-and-format(dsk:scale(@offset + (@length div 2)))"/>-->
    
    
    <!-- drawing an arc to the target  -->
    <xsl:for-each select="key('mark-by-id',@rid)">
      <xsl:variable name="toY" select="dsk:round-and-format(dsk:scale(@offset))"/>
      <!-- first drawing an arc for the xref to the target ($here) -->
      <xsl:variable name="sameChunk" select="$xref/@chunk-link-type='intra'"/>
      <xsl:variable name="reach" select="-50 + (number($sameChunk) * 100)"/>
      <path class="xref-arc" d="M 0 {$toY}
        C {$reach} {$toY} {$reach} {$y} 0 {$y}">
        <xsl:apply-templates select="$xref" mode="format"/>
        <!--<xsl:attribute name="fill">none</xsl:attribute>-->
        <!--<xsl:if test="not($sameChunk)">
          <xsl:attribute name="class" select="concat('dangler-',@chunk)"/>
        </xsl:if>-->
      </path>
    </xsl:for-each>
  </xsl:template>
  
  
  <!--<xsl:template match="dsk:mark" mode="elaborate"/>-->
  
  <!--<xsl:template match="dsk:mark[name='xref']">
    <xsl:variable name="y" select="dsk:round-and-format(dsk:scale(@offset + (@length div 2)))"/>
    <ellipse cx="0" cy="{$y}" title="{@name}"
      rx="{dsk:round-and-format(dsk:scale(@length div 2))}"
      ry="{dsk:round-and-format(dsk:scale(@length div 2))}">
      <xsl:apply-templates select="." mode="format"/>
    </ellipse>
    <!-\-<line y1="-110" y2="10" stroke="darkgrey" stroke-width="1"
      x1="{dsk:round-and-format(dsk:scale(@offset))}"
      x2="{dsk:round-and-format(dsk:scale(@offset))}"/>
    <line y1="-110" y2="10" stroke="darkgrey" stroke-width="1"
      x1="{dsk:round-and-format(dsk:scale(@offset + @length))}"
      x2="{dsk:round-and-format(dsk:scale(@offset +  @length))}"/>-\->
  </xsl:template>-->
  

  <!--<xsl:template match="dsk:hit">
    <xsl:variable name="y" select="dsk:round-and-format(dsk:scale(@offset))"/>
    <xsl:variable name="width" select="dsk:round-and-format(dsk:scale(@length))"/>
    <rect x="-50" y="{$y}" width="100" height="{if (@length &gt; 1) then $width else 1}"
      stroke="green" stroke-width="1" fill="gold" fill-opacity="0.1"/>
  </xsl:template>-->
  
  <!--<xsl:template match="dsk:target">
    <xsl:variable name="here" select="."/>
    <xsl:variable name="x" select="dsk:round-and-format(dsk:scale(@offset + (@length div 2)))"/>
    <ellipse cy="0" cx="{$x}" title="{@name}"
      rx="{dsk:round-and-format(dsk:scale(@length div 2))}"
      ry="{dsk:round-and-format(dsk:scale(@length div 2))}">
      <xsl:apply-templates select="." mode="format"/>
    </ellipse>
    <xsl:for-each select="../dsk:xref[@target=$here/@id]">
      <xsl:variable name="toX" select="dsk:round-and-format(dsk:scale(@offset))"/>
      <path d="M {$x} 0 L {$toX} -100 L {$toX} -110">
         <xsl:apply-templates select="$here" mode="format"/>
         <xsl:attribute name="fill">none</xsl:attribute>        
      </path>
    </xsl:for-each>
  </xsl:template>-->
  
  
  <xsl:template match="dsk:mark" mode="format" priority="10">
    <xsl:attribute name="stroke-width">0.4</xsl:attribute>
    <xsl:attribute name="stroke-opacity">0.5</xsl:attribute>
    <xsl:attribute name="stroke">black</xsl:attribute>
    <xsl:attribute name="fill">white</xsl:attribute>
    <xsl:attribute name="fill-opacity">0.01</xsl:attribute>
    <xsl:next-match/>
  </xsl:template>

  <xsl:template match="dsk:mark" mode="format"/>
  
  <xsl:template match="dsk:mark[@name=('book','book-meta')]" mode="format">
    <xsl:attribute name="stroke">grey</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:mark[@name=('xref')]" mode="format">
    <xsl:attribute name="stroke">darkgreen</xsl:attribute>
    <xsl:attribute name="fill">green</xsl:attribute>
    <xsl:attribute name="fill-opacity">0.01</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:xref" mode="format">
    <xsl:attribute name="stroke">darkgreen</xsl:attribute>
    <xsl:attribute name="fill">none</xsl:attribute>
    <xsl:attribute name="fill-opacity">0</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:mark[@name=('citation')]" mode="format">
    <xsl:attribute name="stroke">purple</xsl:attribute>
    <xsl:attribute name="fill">lavender</xsl:attribute>
    <xsl:attribute name="fill-opacity">0.01</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:mark[@name=('book-part','book-part-meta')]" mode="format">
    <!--<xsl:attribute name="stroke-dasharray">1 1</xsl:attribute>-->
    <xsl:attribute name="fill">lavender</xsl:attribute>
    <xsl:attribute name="fill-opacity">0.05</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:mark[@name=('body','front','back')]" mode="format">
    <xsl:attribute name="stroke-dasharray">2 2</xsl:attribute>
    <xsl:attribute name="stroke">midnightblue</xsl:attribute>
    <xsl:attribute name="fill">lightsteelblue</xsl:attribute>
    <xsl:attribute name="fill-opacity">0.01</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:mark[@name='sec']" mode="format">
    <xsl:attribute name="stroke-dasharray">1 1</xsl:attribute>
    <xsl:attribute name="stroke">purple</xsl:attribute>
    <xsl:attribute name="fill">orchid</xsl:attribute>
    <xsl:attribute name="fill-opacity">0.01</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:mark[@name='fig']" mode="format">
    <xsl:attribute name="stroke">darkgreen</xsl:attribute>
    <xsl:attribute name="fill">green</xsl:attribute>
    <xsl:attribute name="fill-opacity">0.01</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:mark[@name='table-wrap']" mode="format">
    <xsl:attribute name="stroke">saddlebrown</xsl:attribute>
    <xsl:attribute name="fill">darkorange</xsl:attribute>
    <xsl:attribute name="fill-opacity">0.01</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:mark[@name='boxed-text']" mode="format">
    <xsl:attribute name="stroke">darkred</xsl:attribute>
    <xsl:attribute name="fill">pink</xsl:attribute>
    <xsl:attribute name="fill-opacity">0.01</xsl:attribute>
  </xsl:template>

  <xsl:template match="dsk:mark[@name='ref-list']" mode="format">
    <xsl:attribute name="stroke">purple</xsl:attribute>
    <xsl:attribute name="fill">orchid</xsl:attribute>
    <xsl:attribute name="fill-opacity">0.01</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:mark[@name='fn-group']" mode="format">
    <xsl:attribute name="stroke">purple</xsl:attribute>
    <xsl:attribute name="fill">orchid</xsl:attribute>
    <xsl:attribute name="fill-opacity">0.01</xsl:attribute>
  </xsl:template>
  
  

  <xsl:function name="dsk:scale" as="xs:double">
    <xsl:param name="measure" as="xs:double"/>
    <xsl:sequence select="$measure * $squeeze"/>
  </xsl:function>
  
  <xsl:function name="dsk:round-and-format" as="xs:string">
    <xsl:param name="value" as="xs:double"/>
    <xsl:value-of select="format-number($value,'0.00000')"/>
  </xsl:function>
  
  <xsl:function name="dsk:hit" as="xs:boolean">
    <xsl:param name="e" as="element()"/>
    <xsl:sequence select="exists($e intersect $querySet)"/>
  </xsl:function>
  
  
</xsl:stylesheet>