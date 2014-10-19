<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/2000/svg"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:dsk="http://wendellpiez.com/docsketch/xslt/util"
  exclude-result-prefixes="#all"
  version="2.0">
  

  <xsl:variable name="squeeze" select="0.02"/>
  <xsl:variable name="margin"  select="6"/>
  
  <xsl:output indent="yes"/>
    <!--doctype-public="-//W3C//DTD SVG 1.0//EN"
    doctype-system="http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd"/>-->

  <!--<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.0//EN" "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">-->

  <xsl:template match="/article">
    <xsl:apply-templates select="$ranges"/>
  </xsl:template>
  
  <xsl:variable name="ranges">
    <dsk:ranges>
      <xsl:apply-templates mode="ranges" select="/*">
        <xsl:with-param name="offset" tunnel="yes" select="0"/>
      </xsl:apply-templates>
    </dsk:ranges>
  </xsl:variable>
  
  <xsl:template match="* | text()" mode="ranges">
    <xsl:call-template name="continue"/>
  </xsl:template>
  
  <xsl:template match="comment() | processing-instruction()" mode="ranges">
    <xsl:apply-templates select="following-sibling::node()[1]" mode="ranges"/>
  </xsl:template>
  
  <xsl:template name="continue">
    <xsl:param tunnel="yes" name="offset" required="yes"/>
    <xsl:apply-templates select="node()[1]" mode="ranges"/>
    <xsl:apply-templates select="following-sibling::node()[1]" mode="ranges">
      <xsl:with-param tunnel="yes" name="offset" select="$offset + string-length(.)"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="article" mode="ranges" priority="2">
    <xsl:param tunnel="yes" name="offset" required="yes"/>
    <dsk:axis offset="{$offset}" length="{string-length(.)}" name="{name(.)}"/>
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="front | body | back" mode="ranges" priority="2">
    <xsl:param tunnel="yes" name="offset" required="yes"/>
    <dsk:span offset="{$offset}" length="{string-length(.)}" name="{name(.)}"/>
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="xref" mode="ranges">
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
  </xsl:template>
  
  <xsl:template match="dsk:ranges">
    <xsl:variable name="width" select="dsk:round-and-format((2 * $margin) + dsk:scale(dsk:axis/@length))"/>
    <xsl:variable name="height" select="200"/>
    <svg version="1.1"
      viewBox="0 0 {$width} {$height}" height="{$height}" width="{$width}">
      <g transform="translate({$margin} 150)">
        <xsl:apply-templates select="dsk:axis, dsk:span, dsk:target"/>
      </g>
    </svg>
  </xsl:template>
  
  <xsl:template match="dsk:axis">
    <line x1="0" x2="{dsk:round-and-format(dsk:scale(@length))}" y1="-100" y2="-100"
      stroke="grey" stroke-width="4"/>
    <line x1="0" x2="{dsk:round-and-format(dsk:scale(@length))}" y1="0" y2="0"
      stroke="grey" stroke-width="4"/>
  </xsl:template>

  <xsl:template match="dsk:span">
    <line y1="-110" y2="10" stroke="darkgrey" stroke-width="1"
      x1="{dsk:round-and-format(dsk:scale(@offset))}"
      x2="{dsk:round-and-format(dsk:scale(@offset))}"/>
    <line y1="-110" y2="10" stroke="darkgrey" stroke-width="1"
      x1="{dsk:round-and-format(dsk:scale(@offset + @length))}"
      x2="{dsk:round-and-format(dsk:scale(@offset +  @length))}"/>
  </xsl:template>
  
  <xsl:template match="dsk:target">
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
  </xsl:template>
  
  
  <xsl:template match="dsk:target" mode="format" priority="10">
    <xsl:attribute name="stroke">black</xsl:attribute>
    <xsl:attribute name="stroke-width">1</xsl:attribute>
    <xsl:attribute name="fill">gold</xsl:attribute>
    <xsl:attribute name="fill-opacity">0.4</xsl:attribute>
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="dsk:target[@name='front']" mode="format">
    <xsl:attribute name="fill">gold</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:target[@name='back']" mode="format">
    <xsl:attribute name="fill">skyblue</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:target[@name='ref']" mode="format">
    <xsl:attribute name="stroke">darkred</xsl:attribute>
    <xsl:attribute name="fill">pink</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:target[@name='fig']" mode="format">
    <xsl:attribute name="stroke">green</xsl:attribute>
    <xsl:attribute name="fill">lightgreen</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:target[@name=('table-wrap','table')]" mode="format">
    <xsl:attribute name="stroke">midnightblue</xsl:attribute>
    <xsl:attribute name="fill">lightsteelblue</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:target[@name='supplementary-material']" mode="format">
    <xsl:attribute name="fill">orange</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:target[@name=('mml:math','math:math','m:math','math')]" mode="format">
    <xsl:attribute name="fill">purple</xsl:attribute>
  </xsl:template>
  
  
  <xsl:function name="dsk:scale" as="xs:double">
    <xsl:param name="measure" as="xs:double"/>
    <xsl:sequence select="$measure * $squeeze"/>
  </xsl:function>
  
  <xsl:function name="dsk:round-and-format" as="xs:string">
    <xsl:param name="value" as="xs:double"/>
    <xsl:value-of select="format-number($value,'0.00000')"/>
  </xsl:function>
  
</xsl:stylesheet>