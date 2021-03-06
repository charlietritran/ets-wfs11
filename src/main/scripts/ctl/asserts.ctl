<?xml version="1.0" encoding="UTF-8"?>
<ctl:package
 xmlns="http://www.w3.org/2001/XMLSchema"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:ctl="http://www.occamlab.com/ctl"
 xmlns:parsers="http://www.occamlab.com/te/parsers"
 xmlns:p="http://teamengine.sourceforge.net/parsers"
 xmlns:saxon="http://saxon.sf.net/"
 xmlns:wfs="http://www.opengis.net/wfs"
 xmlns:gml="http://www.opengis.net/gml"
 xmlns:ows="http://www.opengis.net/ows"
 xmlns:xlink="http://www.w3.org/1999/xlink"
 xmlns:xi="http://www.w3.org/2001/XInclude"
 xmlns:xsd="http://www.w3.org/2001/XMLSchema">

  <!-- subsidiary validation tests available to test groups -->
  <ctl:test name="wfs:GetFeatureById-KVP">
    <ctl:param name="wfs.GetFeature.get.url"/>
    <ctl:param name="id"/>
    <ctl:param name="empty.response"/>
    <ctl:assertion>Attempts to fetch a feature by identifier using the GetFeature/GET binding.</ctl:assertion>
    <ctl:comment>
      If empty.response = 'false', then test passes if the response contains the
      matching feature as a child of either gml:featureMember or gml:featureMembers.
      Otherwise the test passes only if the response is empty.
    </ctl:comment>
    <ctl:code>
      <xsl:variable name="response">
        <ctl:request>
          <ctl:url>
            <xsl:value-of select="$wfs.GetFeature.get.url"/>
          </ctl:url>
          <ctl:method>GET</ctl:method>
          <ctl:param name="service">WFS</ctl:param>
          <ctl:param name="version">1.1.0</ctl:param>
          <ctl:param name="request">GetFeature</ctl:param>
          <ctl:param name="featureid"><xsl:value-of select="encode-for-uri($id)"/></ctl:param>
          <p:XMLValidatingParser.GMLSF1/>
        </ctl:request>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="not($response//wfs:FeatureCollection)">
          <ctl:message>FAILURE: Expected valid wfs:FeatureCollection in response.</ctl:message>
          <ctl:fail/>
        </xsl:when>
        <xsl:when test="$empty.response = 'false'">
          <xsl:variable name="fid">
            <xsl:value-of select="$response//gml:featureMember/*[1]/@gml:id"/>
          </xsl:variable>
          <xsl:variable name="fid.alt">
            <xsl:value-of select="$response//gml:featureMembers/*[1]/@gml:id"/>
          </xsl:variable>
          <xsl:if test="($fid != $id) and ($fid.alt != $id)">
            <ctl:message>FAILURE: Did not get feature with matching gml:id (<xsl:value-of select="$id"/>).</ctl:message>
            <ctl:fail/>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="(count($response//gml:featureMember) + count($response//gml:featureMembers/*)) > 0">
            <ctl:message>FAILURE: Expected empty GetFeature response.</ctl:message>
            <ctl:fail/>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </ctl:code>
  </ctl:test>

  <ctl:test name="wfs:GetFeatureByName">
    <ctl:param name="wfs.GetFeature.post.url"/>
    <ctl:param name="type"/>
    <ctl:param name="name.value"/>
    <ctl:param name="empty.response"/>
    <ctl:assertion>Attempt to fetch a feature by name using the GetFeature/POST binding.</ctl:assertion>
    <ctl:comment>
      If empty.response = 'false', then the test passes if the response contains
      at least one matching feature as a child of either gml:featureMember or
      gml:featureMembers. Otherwise the test passes only if the response is empty.
    </ctl:comment>
    <ctl:code>
      <xsl:variable name="response">
        <ctl:request>
          <ctl:url>
            <xsl:value-of select="$wfs.GetFeature.post.url"/>
          </ctl:url>
          <ctl:method>POST</ctl:method>
          <ctl:body>
            <foo:GetFeature xmlns:foo="http://www.opengis.net/wfs"
                      service="WFS" version="1.1.0">
              <foo:Query xmlns:sf="http://cite.opengeospatial.org/gmlsf" typeName="{$type}">
                <ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
                  <ogc:PropertyIsEqualTo>
                    <ogc:PropertyName xmlns:gml="http://www.opengis.net/gml">gml:name</ogc:PropertyName>
                    <ogc:Literal><xsl:value-of select="$name.value"/></ogc:Literal>
                  </ogc:PropertyIsEqualTo>
                </ogc:Filter>
              </foo:Query>
            </foo:GetFeature>
          </ctl:body>
          <p:XMLValidatingParser.GMLSF1/>
        </ctl:request>
      </xsl:variable>
      <xsl:variable name="featureCount" select="count($response//gml:featureMember) + count($response//gml:featureMembers/*)" />
      <xsl:choose>
        <xsl:when test="not($response//wfs:FeatureCollection)">
          <ctl:message>FAILURE: Expected valid wfs:FeatureCollection in response.</ctl:message>
          <ctl:fail/>
        </xsl:when>
        <xsl:when test="$empty.response = 'false'">
          <xsl:if test="$featureCount = 0">
            <ctl:message>FAILURE: GetFeature response is empty. Expected feature(s) with gml:name="<xsl:value-of select="$name.value"/>"</ctl:message>
            <ctl:fail/>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="$featureCount > 0">
            <ctl:message>FAILURE: Expected empty GetFeature response (where gml:name="<xsl:value-of select="$name.value"/>")</ctl:message>
            <ctl:fail/>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </ctl:code>
  </ctl:test>

</ctl:package>