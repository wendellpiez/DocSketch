<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:td="http://www.mulberrytech.com/svg/topdowntree"
  xmlns:box="http://www.mulberrytech.com/svg/nestedboxes"
  xmlns:toon="http://www.mulberrytech.com/svg/cartoontree"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/2000/svg"
  xmlns:xp="http://mulberrytech.com/xpath/util"
  exclude-result-prefixes="#all"
version="2.0">
  
  <xsl:import href="draw-page.xsl"/>
  
  <xsl:param name="context" select="/descendant::article-categories"/>
        
  <xsl:param name="selected" select="()"/>
  
  <xsl:param name="label" select="'parent::node()'"/>
  
  <xsl:param name="page-width" select="780"/>
  <xsl:param name="page-height" select="1000"/>
 
  <xsl:variable name="svg-contents">
    <!--<rect fill="lavender" stroke="black" width="100%" height="100%"/>-->

    <g transform="translate(40 20)">
      <xsl:apply-templates select="/" mode="marked-tree">
        <xsl:with-param name="context" select="$context"/>
        <xsl:with-param name="selected" select="$selected"/>
        </xsl:apply-templates>
      <!--<text y="250">step 1: <tspan font-family="monospace" font-weight="bold" font-size="16">div</tspan></text>-->
    </g>

    <g transform="translate(300 125)" font-size="16" font-weight="bold">
      <text>starting context:</text>
      <text y="20"><tspan font-family="monospace">/descendant::article-categories</tspan></text>
      
      <g font-size="11" transform="translate(0 50)">
      <text x="20">context node</text>
      <!--<text x="20" y="30">node(s) selected</text>-->
      <circle stroke="black" stroke-width="2" stroke-dasharray="1 2" fill="none"
           cx="10" cy="0" r="8"/>
      <!--<path stroke="darkred" stroke-width="3" transform="translate(10 30)"
           d="M -5 5 L 5 -5 M -5 -5 L 5 5"/>-->
      </g>
      <!--<g transform="translate(0 116)">
        <text>evaluating</text>
        <text y="28" font-size="24" fill="midnightblue"
        font-weight="bold" font-family="monospace">
          <xsl:value-of select="$label"/>
        </text>
      </g>-->
    </g>
    
  </xsl:variable>
</xsl:stylesheet>