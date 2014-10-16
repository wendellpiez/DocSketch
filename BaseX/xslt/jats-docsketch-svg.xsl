<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/2000/svg"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:dsk="http://wendellpiez.com/docsketch/xslt/util"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:variable name="squeeze"    select="0.005"/>
  <xsl:variable name="inter"      select="2"/>
  <xsl:variable name="drop"       select="7"/>
  
  <xsl:output indent="yes"/>
    <!--doctype-public="-//W3C//DTD SVG 1.0//EN"
    doctype-system="http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd"/>-->

  <!--<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.0//EN" "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">-->

  <xsl:template match="/">
    <!--<xsl:copy-of select="$boxes"/>-->
    <xsl:variable as="element()" name="buffered">
      <xsl:apply-templates select="*" mode="buffer"/>
    </xsl:variable>
    <!--<test>-->
    <!--<xsl:copy-of select="$buffered"/>-->
    <xsl:apply-templates select="$buffered" mode="draw"/>
    <!--</test>-->
  </xsl:template>
  
  <!-- 'buffer' mode appends information to the tree for extra
       spacing; each box gets extra buffering for its descendant boxes.
       (This can be calculated dynamically, but it is expensive.) -->
  <xsl:template match="*" mode="buffer">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:variable name="brood" select="dsk:e"/>
      <xsl:if test="exists($brood)">
        <xsl:attribute name="buffer" select="count($brood) + 1"/>
      </xsl:if>
      <xsl:apply-templates mode="buffer"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="dsk:hierarchy" mode="draw">
    <!--<xsl:variable name="height" select="dsk:e/@height + (2 * $headExtent)"/>-->
    <xsl:variable name="svgContents">
      <xsl:apply-templates mode="#current"/>
    </xsl:variable>
    
    <xsl:variable name="width" select="(max($svgContents//@dsk:xBound))
      + (2 * $inter)"/>
    <xsl:variable name="height" select="(max($svgContents//@dsk:yBound))
      + (2 * $inter)"/>
    
    <!--<svg version="1.1"
      viewBox="0 0 800 {$height}" width="800" height="{$height}">-->
    <svg version="1.1"
      viewBox="0 0 {$width} {$height}" height="{$height}" width="{$width}">
      
      <!--<defs>
        <linearGradient id="fade-text" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%"   stop-opacity="0.8" stop-color="lightsteelblue"/>
          <stop offset="100%" stop-opacity="0"   stop-color="lightsteelblue"/>
        </linearGradient>
        <linearGradient id="fade-div" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%"   stop-opacity="0.8" stop-color="slateblue"/>
          <stop offset="100%" stop-opacity="0"   stop-color="slateblue"/>
        </linearGradient>
      </defs>-->
      
      <g transform="translate({$inter} {$inter})">
        <xsl:apply-templates select="$svgContents" mode="scrub"/>
      </g>
    </svg>
  </xsl:template>
  
  <!-- Scrub mode removes anything with dsk namespace from results -->
  <xsl:template match="node() | @*" mode="scrub">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="scrub"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="node() | @*" mode="scrub">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="scrub"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="dsk:*" mode="scrub">
    <xsl:apply-templates select="node() | @*" mode="scrub"/>
  </xsl:template>
  
  <xsl:template match="@dsk:*" mode="scrub"/>
    
  
  <!--<xsl:template match="dsk:e[@gi='head']" mode="draw">
    <xsl:variable name="x" select="count(ancestor::*) * $indent"/>
    <text x="{$x}" y="{number(@y) + 12}" font-size="12">
      <xsl:apply-templates select="dsk:text"/>
    </text>
  </xsl:template>-->
  
  <xsl:template match="dsk:text" mode="draw"/>
  
  <xsl:variable name="divHeight" select="120"/>
  
  <xsl:variable name="textBoxWidth" select="60"/>
  
  <!--<xsl:template match="dsk:e[@gi=('front','body','back','sec')]" mode="draw">
    <xsl:variable name="yExtent" select="$divHeight"/>
    <!-\-<xsl:variable name="x1" select="count(ancestor::*) * $indent"/>
    <xsl:variable name="x2" select="$x1 + $xExtent"/>
    <xsl:variable name="y1" select="number(@y)"/>
    <xsl:variable name="y2" select="$y1 + number(@height)"/>-\->
    <xsl:variable name="y1" select="count(ancestor::*) * $indent"/>
    <xsl:variable name="y2" select="$y1 + $yExtent"/>
    <xsl:variable name="x1" select="number(@y)"/>
    <xsl:variable name="x2" select="$x1 + number(@extent)"/>
    <path d="M {$x2} {$y1} L {$x1} {$y1}
      L {$x1} {$y2} 
      L {$x2} {$y2}"
      stroke="black" stroke-width="1" fill="url(#fade-{@gi})"/>
    <!-\-Q {$x1 - $reach} {$y1} {$x1 - $reach} {$y2}-\->
    <xsl:apply-templates mode="#current"/>
    
  </xsl:template>-->
  
  <xsl:template match="dsk:e" mode="draw">
    <!--<xsl:variable name="xExtent" select="$textBoxWidth"/>
    <xsl:variable name="x" select="count(ancestor::*) * $indent"/>-->
    <!--<rect x="{$x}" y="{@y}" width="{$xExtent}" height="{@height}"
      stroke="black" stroke-width="1" fill="white"/>-->
    <!-- truncating the height if @extent is 1 (the element is empty) -->
    <xsl:variable name="yExtent" select="$textBoxWidth div (if (@extent = 1) then 2 else 1)"/>
    <xsl:variable name="depth" select="count(ancestor::*) * $drop"/>
    <xsl:variable name="predecessors" select="ancestor::*|preceding::*"/>
    <xsl:variable name="inset"
      select="(sum(ancestor-or-self::*/preceding-sibling::*//@extent) * $squeeze) +
              (count(ancestor-or-self::*/(.|preceding-sibling::*)) * $inter) +
              (sum(preceding::*/@buffer) * $inter)"/>
    <xsl:variable name="xExtent"
      select="(sum(.//@extent) * $squeeze) + (sum(.//@buffer) * $inter)"/>
    <rect x="{$inset}" y="{$depth}" height="{$yExtent}" width="{$xExtent}"
      stroke="black" stroke-width="1" fill="white" title="{@gi}"
      dsk:xBound="{$inset + $xExtent}" dsk:yBound="{$depth + $yExtent}">
    <!--Q {$x1 - $reach} {$y1} {$x1 - $reach} {$y2}-->
      <xsl:apply-templates select="." mode="box-style"/>
    </rect>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <!--<xsl:template match="dsk:e/dsk:text" mode="draw">
    <xsl:variable name="which" select="position()"/>
    <text class="head">
      <xsl:apply-templates/>
    </text>
  </xsl:template>-->
  
  

  <xsl:template match="dsk:e[@gi='front']" mode="box-style">
    <xsl:attribute name="fill">gold</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:e[@gi='back']" mode="box-style">
    <xsl:attribute name="fill">skyblue</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:e[@gi='ref-list']" mode="box-style">
    <xsl:attribute name="stroke">darkred</xsl:attribute>
    <xsl:attribute name="fill">pink</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:e[@gi='fig']" mode="box-style">
    <xsl:attribute name="fill">lightgreen</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:e[@gi='graphic']" mode="box-style">
    <xsl:attribute name="fill">green</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:e[@gi='supplementary-material']" mode="box-style">
    <xsl:attribute name="fill">orange</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:e[@gi=('mml:math','math:math','m:math','math')]" mode="box-style">
    <xsl:attribute name="fill">purple</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="dsk:e" mode="box-style"/>
  
</xsl:stylesheet>