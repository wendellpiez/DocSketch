<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:td="http://www.mulberrytech.com/svg/topdowntree"
  xmlns:box="http://www.mulberrytech.com/svg/nestedboxes"
  xmlns:toon="http://www.mulberrytech.com/svg/cartoontree"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/2000/svg"
  xmlns:xp="http://mulberrytech.com/xpath/util"
  exclude-result-prefixes="#all"
  version="2.0">

  <xsl:output indent="yes"/>

  <xsl:strip-space elements="*"/>

  <xsl:template match="/">
    <xsl:call-template name="plot-svg"/>
  </xsl:template>

  <xsl:param name="page-width" select="1024"/>
  <xsl:param name="page-height" select="768"/>
  
  <xsl:template name="plot-svg">
    
    <svg width="{$page-width}" height="{$page-height}">
    <!-- <svg width="625" height="1000"> -->
      <defs>
        <style type="text/css">
          <xsl:copy-of select="$css-styles"/>
        </style>
      </defs>
      <rect width="100%" height="100%" fill="lavender"/>
      <xsl:copy-of select="$svg-contents"/>
    </svg>
  </xsl:template>

  <xsl:variable name="svg-contents">
    <!-- lay out contents -->

   <g transform="translate(20 10)">
     <xsl:apply-templates select="/" mode="xml-write"/>
   </g>
   
   <g transform="translate(220 25)">
      <xsl:apply-templates select="/" mode="topdown-tree"/>
   </g>
    
   <!--<g transform="translate(20 15)">
      <xsl:apply-templates select="/" mode="boxes"/>
   </g>-->
   
    
    <!--<g transform="translate(300 80) scale(1.2)">
      <xsl:apply-templates select="/" mode="cartoon-tree"/>
    </g>-->
    <!--<g transform="translate(120 160) scale(1.2)">
      <xsl:apply-templates select="/" mode="xml-write"/>
    </g>-->
    
    <!--<g transform="translate(40 20)">
      <xsl:apply-templates select="/" mode="marked-tree">
        <xsl:with-param name="context" select="/xp:chapter"/>
        <xsl:with-param name="selected" select="/xp:chapter/xp:div"/>
      </xsl:apply-templates>
      <text y="250">step 1: <tspan font-family="monospace" font-weight="bold" font-size="16">div</tspan></text>
    </g>
    <g transform="translate(220 20)">
      <xsl:apply-templates select="/" mode="marked-tree">
        <xsl:with-param name="context" select="/xp:chapter/xp:div"/>
        <xsl:with-param name="selected" select="/xp:chapter/xp:div/xp:para"/>
      </xsl:apply-templates>
      <text y="250">step 2: <tspan font-family="monospace" font-weight="bold" font-size="16">para</tspan></text>
    </g>
    
    <g transform="translate(320 125)" font-size="16" font-weight="bold">
      <text x="20">context node</text>
      <text x="20" y="30">node(s) selected</text>
      <circle stroke="black" stroke-width="2" stroke-dasharray="1 2" fill="none"
           cx="10" cy="0" r="8"/>
      <path stroke="darkred" stroke-width="3" transform="translate(10 30)"
           d="M -5 5 L 5 -5 M -5 -5 L 5 5"/>
      
    </g>-->
    <!--<g transform="translate(500 20)">
      <xsl:apply-templates select="/" mode="boxes"/>
    </g>-->

  </xsl:variable>
  
  <xsl:variable name="css-styles">
    text.lit-xml { font-weight: bold; font-family: monospace; font-size: 12 }
    
    path.topdown { stroke: darkgrey; fill: none; stroke-width: 2 }
    
    text.topdown { font-family: sans-serif; font-size: 16 }
    
    text.topdown-text { font-family: monospace; font-size: 11 }
    
    text.element-box { font-family: sans-serif; font-size: 11; fill: midnightblue}
  
    text.text-box { font-family: sans-serif; font-size: 10; fill: black }
    
    text.comment-box { font-family: sans-serif; font-size: 10; fill: dimgray }
    
    text.PI-box { font-family: sans-serif; font-size: 10; fill: darkred }

    <!--text.lit-xml { font-weight: bold; font-family: monospace; font-size: 12 }
    
    path.topdown { stroke: darkgrey; fill: none; stroke-width: 2 }
    
    text.topdown { font-family: sans-serif; font-size: 13 }
    
    text.cartoon { font-family: sans-serif; font-size: 9; fill: black }

    text.topdown-text { font-family: serif; font-size: 12 }
    
    tspan.topdown-attribute { font-family: sans-serif; font-size: 12; fill: darkgreen }
    
    text.element-box { font-family: sans-serif; font-size: 11; fill: midnightblue}
  
    text.text-box { font-family: sans-serif; font-size: 10; fill: black }
    
    text.comment-box { font-family: sans-serif; font-size: 10; fill: dimgray }
    
    text.PI-box { font-family: sans-serif; font-size: 10; fill: darkred }-->
  
  </xsl:variable>

  <!-- ============================================================== -->
  <!-- XML writing - writes XML code -->
  <!-- ============================================================== -->

  <xsl:variable name="lit-dx" select="12"/>

  <xsl:variable name="lit-dy" select="15"/>

  <xsl:variable name="lit-font-size" select="12"/>

  <xsl:template match="/" mode="xml-write">
    <!-- writes literal XML code out as SVG text -->
    <text class="lit-xml">
      <xsl:apply-templates mode="xml-write"/>
    </text>
  </xsl:template>

  <xsl:template match="*" mode="xml-write">
    <tspan x="{count(ancestor::*) * $lit-dx}" dy="{$lit-dy}">
      <xsl:text>&#160;</xsl:text>
    </tspan>
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:apply-templates select="@*" mode="xml-write"/>
    <xsl:if test="empty(node())">/</xsl:if>
    <xsl:text>&gt;</xsl:text>
    <xsl:apply-templates mode="xml-write"/>
    <xsl:if test="exists(node())">
      <xsl:choose>
        <xsl:when test="node()[last()][self::text()]">
          <xsl:text>&lt;/</xsl:text>
          <xsl:value-of select="name()"/>
          <xsl:text>&gt;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <tspan x="{count(ancestor::*) * $lit-dx}" dy="{$lit-dy}">
            <xsl:text>&#160;</xsl:text>
          </tspan>
          <xsl:text>&lt;/</xsl:text>
          <xsl:value-of select="name()"/>
          <xsl:text>&gt;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="text()[preceding-sibling::node()]" mode="xml-write">
    <tspan x="{(count(ancestor::*) - 1) * $lit-dx}" dy="{$lit-dy}">
      <xsl:text>&#160;</xsl:text>
    </tspan>
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="comment()" mode="xml-write">
    <tspan x="{count(ancestor::*) * $lit-dx}" dy="{$lit-dy}">
      <xsl:text>&#160;</xsl:text>
    </tspan>
    <xsl:text>&lt;!--</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>--></xsl:text>
  </xsl:template>

  <xsl:template match="processing-instruction()" mode="xml-write">
    <tspan x="{count(ancestor::*) * $lit-dx}" dy="{$lit-dy}">
      <xsl:text>&#160;</xsl:text>
    </tspan>
    <xsl:text>&lt;?</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:if test="normalize-space()">
      <xsl:text> </xsl:text>
      <xsl:value-of select="."/>
    </xsl:if>
    <xsl:text>?></xsl:text>
  </xsl:template>


  <xsl:template match="@*" mode="xml-write">
    <xsl:text>&#160;</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>="</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <!-- ============================================================== -->
  <!-- Cartoon tree -->
  <!-- ============================================================== -->

  <xsl:variable name="toon:dx" select="30"/>

  <xsl:variable name="toon:dy" select="18"/>

  <xsl:template match="/" mode="cartoon-tree">
    <xsl:apply-templates select="*" mode="toon-paths"/>
    <xsl:apply-templates select="/" mode="toon-icons"/>
    <xsl:apply-templates select="/" mode="toon-labels"/>
  </xsl:template>

  <xsl:template match="node()" mode="toon-paths">
    <xsl:variable name="start-x" select="toon:x(..)"/>
    <xsl:variable name="start-y" select="toon:y(..)"/>
    <xsl:variable name="end-x" select="toon:x(.)"/>
    <xsl:variable name="end-y" select="toon:y(.)"/>
    <path class="cartoon" fill="none" stroke="darkred" stroke-width="3"
        d="M {$start-x} {$start-y} Q {$end-x} {$start-y} {$end-x} {$end-y}" />
    <xsl:apply-templates mode="toon-paths"/>
  </xsl:template>

  <xsl:template match="/" mode="toon-icons">
    <xsl:variable name="height" select="$toon:dy * 0.6"/>
    <xsl:variable name="width" select="$toon:dx * 0.6"/>
    <path
      d="M 0 0
      Q 0 {$height} {$width} {$height}
      L {0 - $width} {$height}
      Q 0 {$height} 0 0
      Z"
      stroke-width="3" stroke="brown" fill="brown"
      transform="translate({toon:x(.)} {toon:y(.) - 3})"/>
    <xsl:apply-templates mode="toon-icons"/>
  </xsl:template>


  <xsl:template match="*" mode="toon-icons">
    <circle cx="{toon:x(.)}" cy="{toon:y(.)}"
      r="6" fill="lightgreen" stroke="forestgreen"/>
    <xsl:apply-templates mode="toon-icons"/>
  </xsl:template>

  <xsl:template match="text()" mode="toon-icons">
    <xsl:variable name="height" select="$toon:dy * 0.6"/>
    <xsl:variable name="width" select="$toon:dx * 0.6"/>
      <path class="text-marker"
      d="M 0 {0 - $height}
      C {$width} {$height}
      {0 - $width} {$height}
      0 {0 - $height}
      Z" transform="translate({toon:x(.)} {toon:y(.)}) rotate(24)"
      stroke="green" fill="lightgreen"/>
</xsl:template>

  <xsl:template match="*" mode="toon-labels">
    <text transform="translate({toon:x(.)} {toon:y(.) + 3}) rotate(-25)" class="cartoon">
      <xsl:value-of select="name()"/>
    </text>
    <xsl:apply-templates mode="toon-labels"/>
  </xsl:template>

  <xsl:template match="text()" mode="toon-labels">
    <text transform="translate({toon:x(.)} {toon:y(.) + 3}) rotate(-25)" class="cartoon">
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:function name="toon:x">
    <xsl:param name="n" as="node()"/>
    <xsl:variable name="tree-squeeze" select="0.3"/>
    <xsl:variable name="v"
       select="$toon:dx *
       (count($n/preceding::*[not(*|text())]|$n/preceding::text()) + 1) +
       (($toon:dx * $tree-squeeze) *
        (count($n/descendant-or-self::*[not(*|text())] |
        $n/descendant-or-self::text() )) )"/>
  <xsl:value-of select="round($v * 100) div 100"/>
  </xsl:function>

  <xsl:variable name="tree-drop" select="$toon:dy * max(//node()/count(ancestor-or-self::node()))"/>
  
  <xsl:function name="toon:y">
    <xsl:param name="n" as="node()"/>
    <xsl:variable name="v"
       select="($tree-drop) -
                ((count($n/ancestor-or-self::node()) *
                $toon:dy))"/>
    <xsl:value-of select="round($v * 100) div 100"/>
  </xsl:function>

  <!-- ============================================================== -->
  <!-- Top-down tree -->
  <!-- ============================================================== -->

  <xsl:variable name="td:dx" select="12"/>

  <xsl:variable name="td:dy" select="18"/>

  <xsl:template match="/ | *" mode="topdown-tree">
    <xsl:apply-templates select="child::node()" mode="td-paths"/>
    <xsl:apply-templates select="." mode="td-icons"/>
    <xsl:apply-templates select="." mode="td-labels"/>
  </xsl:template>

  <xsl:template match="/" mode="marked-tree">
    <xsl:param name="context" select="()"/>
    <xsl:param name="selected" select="()"/>
    <xsl:apply-templates select="*" mode="td-paths"/>
    <xsl:apply-templates select="/" mode="td-icons"/>
    <xsl:apply-templates select="/" mode="td-markers">
      <xsl:with-param name="context" select="$context"/>
      <xsl:with-param name="selected" select="$selected"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="/" mode="td-labels">
      <xsl:with-param name="show-attributes" select="true()" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="node()" mode="td-paths">
    <xsl:variable name="start-x" select="td:x(..)"/>
    <xsl:variable name="start-y" select="td:y(..)"/>
    <xsl:variable name="end-x" select="td:x(.)"/>
    <xsl:variable name="end-y" select="td:y(.)"/>
    <path class="topdown"
      d="M {$start-x} {$start-y} v {$end-y - $start-y} h {$end-x - $start-x}"/>
    <xsl:apply-templates mode="td-paths"/>
  </xsl:template>

  <xsl:template match="/" mode="td-icons">
    <path fill="blue" d="M -6 -4 l 6 8 l 6 -8 z"
      transform="translate({td:x(.)} {td:y(.)})"/>
    <xsl:apply-templates mode="td-icons"/>
  </xsl:template>

  <xsl:template match="*" mode="td-icons">
    <circle cx="{td:x(.)}" cy="{td:y(.)}" r="5" fill="lightgreen" stroke="darkgreen"/>
    <xsl:apply-templates mode="td-icons"/>
  </xsl:template>

  <xsl:template match="text()|comment()|processing-instruction()"
    mode="td-icons"/>

  <xsl:template match="node() | /" mode="td-markers">
    <xsl:param name="context" select="()"/>
    <xsl:param name="selected" select="()"/>
    <xsl:if test=". intersect $context">
      <circle stroke="black" stroke-width="2" stroke-dasharray="1 2" fill="none"
        cx="{td:x(.)}" cy="{td:y(.)}" r="8"/>
    </xsl:if>
    <xsl:if test=". intersect $selected">
      <path stroke="darkred" stroke-width="3"
        transform="translate({td:x(.)} {td:y(.)})"
        d="M -5 5 L 5 -5 M -5 -5 L 5 5"/>
    </xsl:if>
    <xsl:apply-templates mode="td-markers">
      <xsl:with-param name="context" select="$context"/>
      <xsl:with-param name="selected" select="$selected"/>
    </xsl:apply-templates>
  </xsl:template>


  <xsl:template match="*" mode="td-labels">
    <xsl:param name="show-attributes" select="false()" tunnel="yes"/>
    <text x="{td:x(.) + 10}" y="{td:y(.) + 4}" class="topdown">
      <xsl:value-of select="name()"/>
      <xsl:if test="exists(@*)">
        <tspan dy="-2" font-size="85%" class="topdown-attribute">
          <xsl:apply-templates select="@*[$show-attributes]" mode="td-labels"/>
        </tspan>
      </xsl:if>
    </text>
    <xsl:apply-templates mode="td-labels"/>
  </xsl:template>

  <xsl:template match="@*" mode="td-labels">
    <xsl:text> </xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>="</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="text()" mode="td-labels">
    <text x="{td:x(.) + 4}" y="{td:y(.) + 3}" class="topdown-text">
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:template match="comment()" mode="td-labels">
    <text x="{td:x(.) + 4}" y="{td:y(.) + 3}" class="topdown">
      <xsl:text>&lt;!-- </xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>--></xsl:text>
    </text>
  </xsl:template>

  <xsl:template match="processing-instruction()" mode="td-labels">
    <text x="{td:x(.) + 4}" y="{td:y(.) + 3}" class="topdown">
      <xsl:text>&lt;?</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:if test="normalize-space()">
        <xsl:text> </xsl:text>
        <xsl:value-of select="."/>
      </xsl:if>
      <xsl:text>?></xsl:text>
    </text>
  </xsl:template>

  <xsl:template match="/" mode="td-labels">
    <text x="{td:x(.) + 15}" y="{td:y(.) + 3}" class="topdown">/</text>
    <xsl:apply-templates mode="td-labels"/>
  </xsl:template>

  <xsl:function name="td:x">
    <xsl:param name="n" as="node()"/>
    <xsl:value-of select="(count($n/ancestor::node()) * $td:dx)"/>
  </xsl:function>

  <xsl:function name="td:y">
    <xsl:param name="n" as="node()"/>
    <xsl:value-of
      select="(count($n/preceding::node() | $n/ancestor::node()) * $td:dy)"/>
  </xsl:function>


  <!-- ============================================================== -->
  <!-- Nested boxes -->
  <!-- ============================================================== -->

  <xsl:variable name="box:dx" select="4"/>

  <xsl:variable name="box:dy" select="4"/>

  <!--<xsl:variable name="box:ly" select="12"/>-->

  <xsl:variable name="box:leaf-width" select="45"/>

  <xsl:variable name="box:label-height" select="16"/>

  <xsl:variable name="box:max-nested"
    select="max(for $d in /descendant-or-self::* return count($d/ancestor::*))"/>

  <xsl:template match="/" mode="boxes">
    <xsl:apply-templates mode="box-draw"/>
    <xsl:apply-templates mode="box-label"/>
  </xsl:template>

  <xsl:template match="node()" mode="box-draw">
    <xsl:variable name="seatroom"
      select="($box:max-nested - count(ancestor::*)) * (2 * $box:dx)"/>
    <xsl:variable name="legroom"
      select="$box:label-height + (count(descendant::node()) * ($box:label-height + $box:dy))
    + (count(descendant-or-self::*[exists(node())]) * $box:dy)"/>
    <rect x="{box:x(.)}" y="{box:y(.)}" width="{$box:leaf-width + $seatroom}"
      height="{$legroom}">
    <xsl:apply-templates select="." mode="box-color"/>
      </rect>
    <xsl:apply-templates mode="box-draw"/>
  </xsl:template>

  <xsl:template match="*" mode="box-color">
    <xsl:attribute name="stroke">blue</xsl:attribute>
    <xsl:attribute name="stroke-width">2</xsl:attribute>
    <xsl:attribute name="fill">skyblue</xsl:attribute>
    <xsl:attribute name="fill-opacity">0.1</xsl:attribute>
  </xsl:template>
  <xsl:template match="*[text()]" mode="box-color">
    <xsl:attribute name="stroke">cornflowerblue</xsl:attribute>
    <xsl:attribute name="stroke-width">2</xsl:attribute>
    <xsl:attribute name="fill">skyblue</xsl:attribute>
    <xsl:attribute name="fill-opacity">0.1</xsl:attribute>
  </xsl:template>
  <xsl:template match="text()" mode="box-color">
    <xsl:attribute name="stroke">steelblue</xsl:attribute>
    <xsl:attribute name="stroke-width">1</xsl:attribute>
    <xsl:attribute name="fill">skyblue</xsl:attribute>
    <xsl:attribute name="fill-opacity">0.1</xsl:attribute>
  </xsl:template>
  <xsl:template match="comment()" mode="box-color">
    <xsl:attribute name="stroke">black</xsl:attribute>
    <xsl:attribute name="stroke-width">1</xsl:attribute>
    <xsl:attribute name="stroke-dasharray">1 1</xsl:attribute>
    <xsl:attribute name="fill">white</xsl:attribute>
    <xsl:attribute name="fill-opacity">0.1</xsl:attribute>
  </xsl:template>
  <xsl:template match="processing-instruction()" mode="box-color">
    <xsl:attribute name="stroke">darkorange</xsl:attribute>
    <xsl:attribute name="stroke-width">1</xsl:attribute>
    <xsl:attribute name="fill">gold</xsl:attribute>
    <xsl:attribute name="fill-opacity">0.1</xsl:attribute>
  </xsl:template>

  <xsl:template match="node()" mode="box-label">
    <text x="{box:x(.) + 4}" y="{box:y(.) + 11}">
      <xsl:apply-templates select="." mode="label-box"/>
    </text>
    <xsl:apply-templates mode="box-label"/>
  </xsl:template>

  <xsl:template match="*" mode="label-box">
    <xsl:attribute name="class">element-box</xsl:attribute>
    <xsl:value-of select="name()"/>
  </xsl:template>

  <xsl:template match="text()" mode="label-box">
    <xsl:attribute name="class">text-box</xsl:attribute>
    <xsl:text>[text]</xsl:text>
  </xsl:template>

  <xsl:template match="comment()" mode="label-box">
    <xsl:attribute name="class">comment-box</xsl:attribute>
    <xsl:text>[comment]</xsl:text>
  </xsl:template>

  <xsl:template match="processing-instruction()" mode="label-box">
    <xsl:attribute name="class">PI-box</xsl:attribute>
    <xsl:text>[PI]</xsl:text>
  </xsl:template>

   

  <xsl:function name="box:x">
    <xsl:param name="n" as="node()"/>
    <xsl:value-of select="(count($n/ancestor::node()) * $box:dx)"/>
  </xsl:function>

  <xsl:function name="box:y">
    <xsl:param name="n" as="node()"/>
    <xsl:value-of
      select="(count($n/preceding::node() | $n/ancestor::*) * ($box:dy + $box:label-height))
            + (count($n/preceding::*[exists(node())]) * $box:dy)"
    />
  </xsl:function>



</xsl:stylesheet>
