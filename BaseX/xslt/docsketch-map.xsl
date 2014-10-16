<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/2000/svg"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:dsk="http://wendellpiez.com/docsketch/xslt/util"
  exclude-result-prefixes="#all"
  version="2.0">
  
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
  <xsl:variable name="headExtent" select="15"/>
  
  <xsl:output indent="yes"/>
    <!--doctype-public="-//W3C//DTD SVG 1.0//EN"
    doctype-system="http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd"/>-->

  <!--<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.0//EN" "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">-->

  <xsl:template match="/">
    <dsk:hierarchy>
      <xsl:apply-templates mode="box"/>
    </dsk:hierarchy>
  </xsl:template>

  
<!-- 'box' mode specifies the dimensions of the nested boxes.
     Override these templates from an importing stylesheet to get
     behavior customized to a document type. -->
  
  <!-- By default, an element that has only element content will specify
       a box including contained boxes. -->
  <xsl:template match="*[dsk:wrapper(.)]" mode="box">
    <dsk:e gi="{name()}">
      <xsl:apply-templates select="." mode="label"/>
      <xsl:apply-templates select="*" mode="box"/>
    </dsk:e>
  </xsl:template>
  
  <!-- matches elements that are not designated as wrappers -->
  <xsl:template match="*" mode="box">
    <dsk:e gi="{name()}" extent="{dsk:extent(.)}">
      <xsl:apply-templates select="." mode="label"/>
    </dsk:e>
  </xsl:template>
  
  <xsl:template match="*" mode="label"/>
  
  <!-- dsk:wrapper returns true for elements with element contents,
       i.e. element children (not terminal), but no text either (not mixed)
       Their extents are determined by looking at the extents of their
       descendants, not by their (unprocessed) text contents.
  -->
  <xsl:function name="dsk:wrapper" as="xs:boolean">
    <xsl:param name="e" as="element()"/>
    <xsl:sequence select="exists($e/*) and empty($e/text()[normalize-space(.)])"/>
  </xsl:function>
  
  <xsl:function name="dsk:extent" as="xs:decimal">
    <xsl:param name="e" as="element()"/>
    <xsl:apply-templates select="$e" mode="extent"/>
  </xsl:function>
  
  <xsl:template as="xs:decimal" mode="extent" match="*">
    <!-- Adding 1 so empty elements get an extent too. -->
    <xsl:sequence select="string-length(.) + 1"/>
  </xsl:template>
  
  <!--<xsl:template as="xs:decimal" mode="extent" match="*[empty(text()[normalize-space(.)])]" priority="2">
    <xsl:sequence select="sum(*/dsk:extent(.)) + (count(*) * $inter) + $inter"/>
  </xsl:template>-->
  
  <xsl:template as="xs:decimal" mode="extent" match="head" priority="2">
    <xsl:sequence select="$headExtent"/>
  </xsl:template>
  
</xsl:stylesheet>