<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/2000/svg"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:dsk="http://wendellpiez.com/docsketch/xslt/util"
  
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  
  exclude-result-prefixes="#all"
  version="2.0">

<xsl:import href="docsketch-map.xsl"/>
<!--  
  
  ==== Generic document sketch map discriminates between textual (including mixed) content,
       and element only content.
       Extents are calculated for text-bearing elements, while the sizing of element containers
       is expected to "wrap" these.
       
       So, not for making bows indicating relative position, but boxes or containers indicating structure.
       
       <e gi="div">
         <e gi="p" extent="101"/>
         <e gi="p" extent="102"/>
       </e>

  -->
  <!--<xsl:variable name="squeeze"    select="0.005"/>
  <xsl:variable name="inter"      select="2"/>
  <xsl:variable name="headExtent" select="15"/>
  <xsl:variable name="indent"     select="15"/>-->
  
  <!--<xsl:variable name="squeeze"    select="0.005"/>-->
  <!--<xsl:variable name="inter"      select="2"/>-->
  
  <xsl:variable name="headExtent" select="80"/>
  
  <xsl:output indent="yes"/>
    <!--doctype-public="-//W3C//DTD SVG 1.0//EN"
    doctype-system="http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd"/>-->

  <!--<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.0//EN" "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">-->


  <xsl:template match="tei:head" mode="label">
    <dsk:label extent="{$headExtent}">
      <xsl:apply-templates/>
    </dsk:label>
  </xsl:template>

  <xsl:template match="*[dsk:wrapper(.)]" mode="box">
    <dsk:e gi="{name()}">
      <xsl:apply-templates select="." mode="label"/>
      <xsl:apply-templates select="node()" mode="box"/>
    </dsk:e>
  </xsl:template>
  
  <!-- matches elements that are not designated as wrappers -->
  <xsl:template match="text()[normalize-space(.)]" mode="box">
    <dsk:text extent="{string-length(.)}"/>
  </xsl:template>
  
  <xsl:function name="dsk:wrapper" as="xs:boolean">
    <xsl:param name="e" as="element()"/>
    <xsl:sequence select="exists($e/* | $e/text()[normalize-space(.)])"/>
  </xsl:function>
  
  
  
  
  
  <xsl:template as="xs:decimal" mode="extent" match="tei:head" priority="2" 
   >
    <xsl:sequence select="$headExtent"/>
  </xsl:template>
  
</xsl:stylesheet>