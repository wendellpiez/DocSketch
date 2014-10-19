<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tm="http://www.datenverdrahten.de/tm"
  exclude-result-prefixes="fn tm xs">

<!--
    Routinen für XSLT/XPath 2.0 by Dr. Thomas Meinike 01/07...03/10
    Hinweis: Die Genauigkeit der Reihenentwicklungen lässt sich über den Wert der Variable $max steuern.
-->

<xsl:variable name="pi"   as="xs:double"  select="3.141592653589793"/><!-- Wert von Pi als globale Variable (Konstante) -->
<xsl:variable name="ln10" as="xs:double"  select="2.302585092994046"/><!-- natürlicher Logarithmus von 10 (Konstante) -->
<xsl:variable name="max"  as="xs:integer" select="15"/><!-- Anzahl der Glieder für Reihenentwicklungen -->


<!-- Fakultät -->
<xsl:function name="tm:fact" as="xs:double">
  <xsl:param name="n" as="xs:integer"/>

  <xsl:value-of select="if($n eq 0 or $n eq 1) then 1 else $n * tm:fact($n - 1)"/>
</xsl:function>


<!-- Potenz x^n für nichtnegative ganzzahlige n -->
<xsl:function name="tm:pow" as="xs:double">
  <xsl:param name="x" as="xs:double"/>
  <xsl:param name="n" as="xs:integer"/>

  <xsl:value-of select="if($n eq 0) then 1 else $x * tm:pow($x, $n - 1)"/>
</xsl:function>


<!-- Exponential-Funktion e^x (Reihenentwicklung) -->
<xsl:function name="tm:exp" as="xs:double">
  <xsl:param name="x" as="xs:double"/>

  <xsl:variable name="sum_seq" as="item()*" select="for $n in (0 to $max) return fn:number(tm:pow($x, $n) div tm:fact($n))"/>
  <xsl:value-of select="fn:round-half-to-even(fn:sum($sum_seq), 8)"/>
</xsl:function>


<!-- Sinus-Funktion (Reihenentwicklung) -->
<xsl:function name="tm:sin" as="xs:double">
  <xsl:param name="arg" as="xs:double"/>

  <xsl:variable name="x" as="xs:double" select="if($arg ge 2 * $pi) then $arg - fn:floor($arg div (2 * $pi)) * 2 * $pi else(if($arg le -2 * $pi) then $arg + fn:floor($arg div (-2 * $pi)) * 2 * $pi else $arg)"/>
  <xsl:variable name="sum_seq" as="item()*" select="for $n in (0 to $max) return fn:number(tm:pow(-1, $n) * tm:pow($x, 2 * $n + 1) div tm:fact(2 * $n + 1))"/>
  <xsl:value-of select="fn:round-half-to-even(fn:sum($sum_seq), 8)"/>
</xsl:function>


<!-- Cosinus-Funktion (Reihenentwicklung) -->
<xsl:function name="tm:cos" as="xs:double">
  <xsl:param name="arg" as="xs:double"/>

  <xsl:variable name="x" as="xs:double" select="if($arg ge 2 * $pi) then $arg - fn:floor($arg div (2 * $pi)) * 2 * $pi else(if($arg le -2 * $pi) then $arg + fn:floor($arg div (-2 * $pi)) * 2 * $pi else $arg)"/>
  <xsl:variable name="sum_seq" as="item()*" select="for $n in (0 to $max) return fn:number(tm:pow(-1, $n) * tm:pow($x, 2 * $n) div tm:fact(2 * $n))"/>
  <xsl:value-of select="fn:round-half-to-even(fn:sum($sum_seq), 8)"/>
</xsl:function>


<!-- Umrechnung vom Gradmaß ins Bogenmaß -->
<xsl:function name="tm:deg2rad" as="xs:double">
  <xsl:param name="deg" as="xs:double"/>

  <xsl:value-of select="$deg * $pi div 180"/>
</xsl:function>


<!-- Umrechnung vom Bogenmaß ins Gradmaß -->
<xsl:function name="tm:rad2deg" as="xs:double">
  <xsl:param name="rad" as="xs:double"/>

  <xsl:value-of select="$rad * 180 div $pi"/>
</xsl:function>


<!-- Quadratwurzel -->
<xsl:function name="tm:sqrt" as="xs:double">
  <xsl:param name="arg" as="xs:double"/>

  <xsl:if test="$arg ge 0">
    <xsl:value-of select="tm:nroot($arg, 2)"/>
  </xsl:if>

  <xsl:if test="$arg lt 0">
    <xsl:value-of select="fn:number('NaN')"/>
  </xsl:if>
</xsl:function>


<!-- n-te Wurzel -->
<xsl:function name="tm:nroot" as="xs:double">
  <xsl:param name="arg" as="xs:double"/>
  <xsl:param name="n" as="xs:integer"/>

  <xsl:if test="$arg ge 0 and $n ge 1">
    <xsl:call-template name="root_iterator">
      <xsl:with-param name="n" as="xs:integer" select="$n"/>
      <xsl:with-param name="x" as="xs:double" select="$arg"/>
      <xsl:with-param name="y" as="xs:double" select="0"/>
      <xsl:with-param name="yn" as="xs:double" select="$arg"/>
    </xsl:call-template>
  </xsl:if>

  <xsl:if test="$arg lt 0 or $n lt 1">
    <xsl:value-of select="fn:number('NaN')"/>
  </xsl:if>
</xsl:function>


<!-- Iterative Wurzelberechnung (Heron-Verfahren) -->
<xsl:template name="root_iterator">
  <xsl:param name="n"/>
  <xsl:param name="x"/>
  <xsl:param name="y"/>
  <xsl:param name="yn"/>

  <xsl:choose>
    <xsl:when test="fn:abs($y - $yn) gt 1E-8">
      <xsl:variable name="akt_y" select="$yn"/>
      <xsl:variable name="akt_yn" select="1 div $n * (($n - 1) * $akt_y + $x div tm:pow($akt_y, $n - 1))"/>
      <xsl:call-template name="root_iterator">
        <xsl:with-param name="n" as="xs:integer" select="$n"/>
        <xsl:with-param name="x" as="xs:double" select="$x"/>
        <xsl:with-param name="y" as="xs:double" select="$akt_y"/>
        <xsl:with-param name="yn" as="xs:double" select="$akt_yn"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="fn:round-half-to-even($yn, 8)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- Natürlicher Logarithmus -->
<xsl:function name="tm:ln" as="xs:double">
  <xsl:param name="arg" as="xs:double"/>

  <xsl:if test="$arg gt 0">
    <xsl:variable name="argm" as="xs:double" select="$arg - 1"/>
    <xsl:variable name="argp" as="xs:double" select="$arg + 1"/>
    <xsl:variable name="sum_seq" as="item()*" select="for $n in (1 to 4 * $max)[. mod 2 = 1] return fn:number(tm:pow($argm, $n) div ($n * tm:pow($argp, $n)))"/>
    <xsl:value-of select="fn:round-half-to-even(2 * fn:sum($sum_seq), 8)"/>
  </xsl:if>

  <xsl:if test="$arg eq 0">
    <xsl:value-of select="fn:number('-INF')"/>
  </xsl:if>

  <xsl:if test="$arg lt 0">
    <xsl:value-of select="fn:number('NaN')"/>
  </xsl:if>
</xsl:function>


<!-- Dekadischer Logarithmus -->
<xsl:function name="tm:lg" as="xs:double">
  <xsl:param name="arg" as="xs:double"/>

  <xsl:if test="$arg gt 0">
    <xsl:value-of select="fn:round-half-to-even(tm:ln($arg) div $ln10, 8)"/>
  </xsl:if>

  <xsl:if test="$arg eq 0">
    <xsl:value-of select="fn:number('-INF')"/>
  </xsl:if>

  <xsl:if test="$arg lt 0">
    <xsl:value-of select="fn:number('NaN')"/>
  </xsl:if>
</xsl:function>


<!-- Fibonacci-Zahlen -->
<xsl:function name="tm:fibo" as="xs:integer">
  <xsl:param name="n" as="xs:integer"/>

  <xsl:value-of select="if($n eq 0) then 0 else if($n eq 1 or $n eq 2) then 1 else tm:fibo($n - 1) + tm:fibo($n - 2)"/>
</xsl:function>

</xsl:stylesheet>