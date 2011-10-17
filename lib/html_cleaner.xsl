<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="UTF-8"/>

<!--
  <xsl:strip-space elements="*"/>
-->


<!-- some helpers to output tags and their attributes -->
<xsl:template name="opening_tag">
  <xsl:text disable-output-escaping="yes">&lt;</xsl:text>
  <xsl:value-of select="name()" />
  <xsl:for-each select="@*"><xsl:text> </xsl:text><xsl:value-of select="name()"/>="<xsl:value-of select="."/>"</xsl:for-each>
  <xsl:text disable-output-escaping="yes">&gt;</xsl:text>
</xsl:template>

<xsl:template name="closing_tag">
  <xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="local-name()" /><xsl:text disable-output-escaping="yes">&gt;</xsl:text></xsl:template>


<!-- copy recursively -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>


<!-- copy without decending into child nodes, thus leaving inner html as is -->
<xsl:template match="dl|h1|h2|h3|h4|h5|h6|hr|ol|p|pre|table|ul">
  <xsl:copy-of select="."/>
</xsl:template>

<!-- replace linebreaks inside with br and p tags -->
<xsl:template match="*">
  <xsl:call-template name="opening_tag" />
  <xsl:apply-templates select="node()" />
  <xsl:call-template name="closing_tag" />
</xsl:template>



</xsl:stylesheet>