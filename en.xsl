<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" encoding="utf-8"/>

<xsl:param name="lang" select="'en'"/>
<xsl:param name="localeUrl" select="'Resources.resx'"/>

<xsl:variable name="maxcols">10</xsl:variable>
<xsl:variable name="fontsize">+1</xsl:variable>
<xsl:variable name="week">7</xsl:variable>
<xsl:variable name="scale"><xsl:value-of select="//bahnhof/maszstab"/></xsl:variable>
<xsl:variable name="locolength">20</xsl:variable>
<xsl:variable name="meanaxlelength">5</xsl:variable>
<xsl:template match="/">
<html>
	<head>
		<title><xsl:value-of select="bahnhof/name"/></title>
		<meta http-equiv="Content-Style-Type" content="text/css" />
		<link rel="stylesheet" type="text/css" href="style.css" />
	</head>
	<body>
		<xsl:for-each select="bahnhof">
			<div id="main-capt">station</div>
			<h1><xsl:value-of select="name"/></h1>
			<table class="head">
				<tr>
					<td><xsl:text disable-output-escaping="yes">Short: </xsl:text><span><xsl:value-of select="kuerzel"/></span></td>
					<td>Type: <span><xsl:value-of select="typ"/></span></td>
					<td><xsl:text disable-output-escaping="yes">Scale: </xsl:text><span>1:<xsl:value-of select="maszstab"/></span></td>
					<td>Module ID: <span><xsl:value-of select="modulnr"/></span></td>
				</tr>
				<tr>
					<td colspan="4"><xsl:apply-templates select="plan"/></td>
				</tr>
			</table>

			<xsl:apply-templates select="gleise"/>
			<xsl:apply-templates select="pv"/>
			<xsl:apply-templates select="gv"/>
			<xsl:call-template name="caroutput"/>
			<xsl:apply-templates select="bemerkung"/>

		</xsl:for-each>
	</body>
</html>
</xsl:template>

<xsl:template name="leerzeile">
	<tr><td colspan="{$maxcols}"><xsl:text disable-output-escaping="yes">&#160;</xsl:text></td></tr>
</xsl:template>

<!-- berechnet rekursiv die Laenge aller Ladestellen aufsummiert -->
<xsl:template name="produkt_summe">
	<xsl:param name="summe" />
	<xsl:param name="i" />
	<xsl:param name="max" />
	<xsl:choose>
		<xsl:when test="$i &lt;= $max">
		   <xsl:variable name="lattri" select="ladestelle[$i]/laenge/attribute::einheit"/>
			<xsl:variable name="produkt">
				<xsl:choose>
					<xsl:when test="$lattri='cm'">
						<xsl:value-of select="floor( (ladestelle[$i]/laenge * 2 div 10) div 2)*2"/>
					</xsl:when>
					<xsl:when test="$lattri='achsen'">
						<xsl:value-of select="ladestelle[$i]/laenge"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="floor((ladestelle[$i]/laenge div 10 * 2 div 10 ) div 2)*2"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:call-template name="produkt_summe">
				<xsl:with-param name="summe" select="$summe + $produkt"/>
				<xsl:with-param name="i" select="$i + 1"/>
				<xsl:with-param name="max" select="$max"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$summe"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Achslaenge fuer die Haupt- und Nebengleise -->
<xsl:template name="achslaenge">
	<xsl:param name="nlaenge"/>
	<xsl:param name="lattri" select="$nlaenge/attribute::einheit" />
	<xsl:param name="cmscale" select="$scale div 100" />
	<xsl:param name="mmscale" select="$scale div 1000" />
	<xsl:param name="whichtracktype" select="name(..)" /><!-- hgleise oder ngleise -->
	<xsl:if test="not($lattri) or $lattri='mm'">
	<xsl:choose>
			<xsl:when test="$whichtracktype='ngleise'">
				<xsl:value-of select="floor( ( ( ($nlaenge div 10) * 2) div 10 ) div 2)*2"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="floor( ( (($nlaenge*$mmscale)-$locolength) div ($meanaxlelength) ) div 2)*2"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
	<xsl:if test="$lattri='cm'">
	   <xsl:choose>
			<xsl:when test="$whichtracktype='ngleise'">
				<xsl:value-of select="floor( ( ( ($nlaenge*2)) div 10 ) div 2)*2"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="floor( ( (($nlaenge*$cmscale)-$locolength) div ($meanaxlelength) ) div 2)*2"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
	<xsl:if test="$lattri='achsen'">
	   <xsl:value-of select="floor($nlaenge)"/>
	</xsl:if>
</xsl:template>

<!-- Achslaenge fuer die Ladestellen -->
<xsl:template name="achslaenge1">
	<xsl:param name="nlaenge"/>
	<!-- anders kommt man an den Attributwert nicht heran! -->
	<xsl:param name="lattri" select="$nlaenge/attribute::einheit" />
	<xsl:param name="cmscale" select="$scale div 100" />
	<xsl:param name="mscale" select="$scale div 1000" />
	<!-- hinweis: es wurde gerechnet floor(x/2)*2 damit eine gerade Zahl herauskommt -->
	<xsl:if test="not($lattri) or $lattri='mm'">
				<xsl:value-of select="floor( ( ( ($nlaenge div 10) *2 ) div 10 ) div 2)*2"/>
	</xsl:if>
	<xsl:if test="$lattri='cm'">
				<xsl:value-of select="floor( ( ( ($nlaenge div 1) *2 ) div 10 ) div 2)*2"/>
	</xsl:if>
	<xsl:if test="$lattri='achsen'">
	   <xsl:value-of select="floor($nlaenge)"/>
	</xsl:if>
</xsl:template>

<!-- So hier schauen wir mal ob wir etwas formatieren müssen  -->
<xsl:template name="recurse_break">
	<xsl:param name="idlist"/>
	<xsl:variable name="normidlist" select="concat(normalize-space($idlist),' ')"/>
	<xsl:variable name="firstid" select="substring-before($normidlist,'[br]')"/>
	<xsl:variable name="restidlist" select="substring-after($normidlist,'[br]')"/>
	<xsl:choose>
		<xsl:when test="$firstid != ''">
			<xsl:value-of select="$firstid"/><br/>
			<xsl:if test="$restidlist != ''">
				<xsl:call-template name="recurse_break">
					<xsl:with-param name="idlist" select="$restidlist"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$normidlist"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="plan">
	<img src="{@src}" />
</xsl:template>

<xsl:template match="gleise">
	<table class="section">
	<tr><td>
	<h2>Tracks</h2>
	<h3>Main tracks</h3>

	<table class="tracks">
		<tr>
			<th>Track</th>
			<th>Length</th>
			<th>Axles</th>
			<th>Remarks</th>
		</tr>

		<xsl:for-each select="hgleise/gleis">
			<xsl:call-template name="ugleis"/>
		</xsl:for-each>
	</table>

	<!-- zaehle die vorhandenen Nebengleise -->
	<!-- Wenn es welche gibt dann gebe sie aus -->
	<xsl:variable name="content"><xsl:value-of select="count(ngleise/*)"/></xsl:variable>
	<xsl:if test="$content &gt; 0">
		<table class="tracks">
			<tr>
				<th>Track</th>
				<th>Length</th>
				<th>Axles</th>
			<th>Remarks</th>
			</tr>

			<h3>Side tracks</h3>
			<xsl:for-each select="ngleise/gleis">
				<xsl:call-template name="ugleis" />
			</xsl:for-each>
		</table>
	</xsl:if>

	</td></tr><tr><td class="mitte">
		<xsl:text disable-output-escaping="yes">Note: Calculation of effective length based on assumptions: 10 cm effective length correspond to 2 axles.</xsl:text>
	</td></tr></table>
</xsl:template>

<xsl:template match="laenge">
	<xsl:value-of select="."/>
	<xsl:text disable-output-escaping="yes">&#160;</xsl:text>
	<xsl:choose>
		<xsl:when test="@einheit">
			<xsl:choose>
				<xsl:when test="@einheit='achsen'">axles</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@einheit"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>mm</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="ugleis">
	 <tr>
		<td>Track <strong><xsl:value-of select="name"/></strong></td>
			<td class="rechts"><xsl:apply-templates select="laenge"/></td>
			<td class="rechts">
				<xsl:call-template name="achslaenge1">
					<xsl:with-param name="nlaenge" select="laenge" />
				</xsl:call-template>
			</td>
			<td>
				<xsl:text disable-output-escaping="yes">&#160;</xsl:text>
				<xsl:value-of select="bemerkung"/>
			</td>
	</tr>
</xsl:template>

<xsl:template match="pv">
	<table class="section">
	<tr><td>
	<h2>Passenger traffic</h2>

		<table class="platforms">
			<tr>
				<th>Platform</th>
				<th>Track</th>
				<th>Length</th>
				<th></th>
				<th>Remarks to passenger traffic</th>
			</tr>

			<xsl:apply-templates select="bahnsteig"/>
		</table>

	</td></tr>
	</table>
</xsl:template>

<xsl:template match="bahnsteig[1]">
	<tr>
		<td>Platform <strong><xsl:value-of select="name"/></strong></td>
		<td class="mitte">
			<xsl:call-template name="recurse_id">
				<xsl:with-param name="key" select="'gleise'"/>
				<xsl:with-param name="idlist" select="@gleis"/>
			</xsl:call-template>
		</td>
		<td class="rechts"><xsl:apply-templates select="laenge"/></td>

		<td></td>
		<td rowspan="{count(../bahnsteig)}">
			<xsl:call-template name="recurse_break">
				<xsl:with-param name="idlist" select="bemerkung"/>
			</xsl:call-template>
		</td>
	</tr>
</xsl:template>

<xsl:template match="bahnsteig">
	<tr>
		<td>Platform <strong><xsl:value-of select="name"/></strong></td>
		<td class="mitte">
			<xsl:call-template name="recurse_id">
				<xsl:with-param name="key" select="'gleise'"/>
				<xsl:with-param name="idlist" select="@gleis"/>
			</xsl:call-template>
		</td>
		<td class="rechts"><xsl:apply-templates select="laenge"/></td>
	</tr>
</xsl:template>

<xsl:key name="gleise" match="gleis" use="@id"/>
<xsl:key name="ladestellen" match="ladestelle" use="@id"/>

<xsl:template name="recurse_id">
	<xsl:param name="key"/>
	<xsl:param name="idlist"/>
	<xsl:variable name="normidlist" select="concat(normalize-space($idlist),' ')"/>
	<xsl:variable name="firstid" select="substring-before($normidlist,' ')"/>
	<xsl:variable name="restidlist" select="substring-after($normidlist,' ')"/>
	<xsl:if test="$firstid != ''">
			<xsl:value-of select="key($key,$firstid)/name"/>
			<xsl:if test="$restidlist != ''">
				<xsl:text disable-output-escaping="yes">, </xsl:text>
				<xsl:call-template name="recurse_id">
					<xsl:with-param name="key" select="$key"/>
					<xsl:with-param name="idlist" select="$restidlist"/>
				</xsl:call-template>
		</xsl:if>
	</xsl:if>
</xsl:template>

<xsl:template match="gv">
	<table class="section">
	<tr><td>
	<h2>Cargo traffic</h2>
	<h3>Loading places</h3>

	<table class="cplaces">
	<tr>
		<th>Loading place</th>
		<th>Track</th>
		<th>Length</th>
		<th>Axles</th>
		<th></th>
		<th>Remarks to cargo traffic</th>
	</tr>

	<xsl:apply-templates select="ladestelle"/>

	<tr style="font-weight: bold">
		<td>Sum:</td>
		<td></td>
		<td></td>
		<td class="rechts">
		<xsl:call-template name="produkt_summe">
			<xsl:with-param name="summe" select="0"/>
			<xsl:with-param name="i" select="1"/>
			<xsl:with-param name="max" select="count(ladestelle)"/>
		</xsl:call-template>
		</td>
	</tr>
	</table>

	<table class="goods">
		<h3>Goods</h3>
		<tr>
			<th>Distributor / Receiver</th>
			<th>D/R</th>
			<th>Goods</th>
			<th>Car type</th>
			<th>Loading place</th>
			<th>Car quantity</th>
		</tr>
		<xsl:apply-templates select="verlader"/>
	</table>

	</td></tr>
	</table>
</xsl:template>

<xsl:template match="ladestelle[1]">
	<tr>
		<td><xsl:value-of select="name"/></td>
			<td class="mitte">
		<xsl:call-template name="recurse_id">
			<xsl:with-param name="key" select="'gleise'"/>
				<xsl:with-param name="idlist" select="@gleis"/>
		</xsl:call-template>
			</td>
		<td class="rechts"><xsl:apply-templates select="laenge"/></td>
			<td class="rechts">
				<xsl:call-template name="achslaenge1">
					<xsl:with-param name="nlaenge" select="laenge" />
				</xsl:call-template>
			</td>

		<td></td>

		<td rowspan="{count(../ladestelle)+1}">
					<xsl:call-template name="recurse_break">
						<xsl:with-param name="idlist" select="bemerkung"/>
					</xsl:call-template>
		</td>

	</tr>
</xsl:template>

<xsl:template match="ladestelle">
	<tr>
		<td><xsl:value-of select="name"/></td>
		<td class="mitte">
		<xsl:call-template name="recurse_id">
			<xsl:with-param name="key" select="'gleise'"/>
				<xsl:with-param name="idlist" select="@gleis"/>
		</xsl:call-template>
		</td>
		<td class="rechts"><xsl:apply-templates select="laenge"/></td>
			<td class="rechts">
				<xsl:call-template name="achslaenge1">
					<xsl:with-param name="nlaenge" select="laenge" />
				</xsl:call-template>
			</td>
	</tr>
</xsl:template>


<xsl:template match="verlader">
		<!-- Verschoben nach Versand|Empfang wegen Darstellungsweise mit der Tabelle -->
		<xsl:if test="count(versand/ladegut)+count(empfang/ladegut) = 0">
		<tr>
			<td rowspan="{count(versand/ladegut)+count(empfang/ladegut)+1}"><xsl:value-of select="name"/></td>
			<td colspan="5"></td>
		</tr>
		</xsl:if>

		<xsl:apply-templates select="versand|empfang">
			<xsl:with-param name="lsumme" select="count(versand/ladegut)+count(empfang/ladegut)"/>
		</xsl:apply-templates>
</xsl:template>

<xsl:template match="versand|empfang">
		<xsl:param name="lsumme" />
		<xsl:for-each select="ladegut">
		 <tr>
			<xsl:if test="local-name(../preceding-sibling::*[1])='name' and position()='1'">
					<td rowspan="{$lsumme}">
						<xsl:value-of select="../preceding-sibling::*[1]"/>
					</td>
				</xsl:if>
				<td class="mitte">
				<xsl:choose>
					<xsl:when test="local-name(..)='empfang'">R</xsl:when>
					<xsl:otherwise>D</xsl:otherwise>
				</xsl:choose>
				</td>
				<td><xsl:value-of select="name"/></td>
				<td class="mitte"><xsl:value-of select="gattung"/></td>
			<td class="mitte">
				<xsl:call-template name="recurse_id">
				<xsl:with-param name="key" select="'ladestellen'"/>
				<xsl:with-param name="idlist" select="@ladestelle"/>
			 </xsl:call-template><!--</xsl:text>-->
				</td>
				<td nowrap="nowrap"><xsl:apply-templates select="wagen"/></td>
			</tr>
	</xsl:for-each>
</xsl:template>

<xsl:template match="wagen">
	<xsl:value-of select="."/>
	<xsl:text disable-output-escaping="yes">&#160;</xsl:text>/<xsl:text disable-output-escaping="yes">&#160;</xsl:text>
	<xsl:choose>
		<xsl:when test="@zeitraum">
			<xsl:choose>
			<xsl:when test="@zeitraum='tag'">day</xsl:when>
					<xsl:when test="@zeitraum='woche'">week</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>week</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="bemerkung">
	<table class="section">
	<tr><td>
		<h2>General remarks to station</h2>
			<xsl:call-template name="recurse_break">
				<xsl:with-param name="idlist" select="."/>
			</xsl:call-template>
		</td></tr>
	</table>
</xsl:template>

<xsl:template name="caroutput">
	<table class="section">
	<tr><td>
	<h2>Summary</h2>

	<table class="sum">

		<!-- diesen wert nehmen und dann je nachdem ob Tag oder Woche ist mit 1 oder 5,5 multiplizieren und addieren -->
		<!-- Wichtig zu wissen!!!
			  laut Definition ist als Zeitraum "Woche" angenommen, wenn kein Zeitraum explizit angegeben wird!
			  das bedeutet fuer die Rechnerei, dass man die Gesamtwagenmenge nimmt:
			  sum(gv/verlader/versand/ladegut/wagen)
			  und von dieser Gesamtmenge die Tagesmenge abzieht:
			  sum(gv/verlader/versand/ladegut/wagen[@zeitraum='tag'])
			  somit erhaelt man die Wochenmenge, wobei egal ist ob beim Zeitraum Woche angegeben ist oder nicht!
			  Man erhaelt auf diese Weise IMMER die richtige Menge am Ende!
		-->
		<tr>
			<th>Cars-\Quantity</th>
			<th>per day</th>
			<th>per week</th>
		</tr>
		<tr>
			<td><xsl:text>Receiving</xsl:text></td>
			<td><xsl:value-of select="format-number(sum(gv/verlader/empfang/ladegut/wagen[@zeitraum='tag'])+((sum(gv/verlader/empfang/ladegut/wagen)-sum(gv/verlader/empfang/ladegut/wagen[@zeitraum='tag'])) div $week),'###.#')"/></td>
			<td><xsl:value-of select="($week* sum(gv/verlader/empfang/ladegut/wagen[@zeitraum='tag']))+(sum(gv/verlader/empfang/ladegut/wagen)-sum(gv/verlader/empfang/ladegut/wagen[@zeitraum='tag']))"/></td>
		</tr>
		<tr>
			<td><xsl:text>Distribution</xsl:text></td>
			<td><xsl:value-of select="format-number(sum(gv/verlader/versand/ladegut/wagen[@zeitraum='tag'])+((sum(gv/verlader/versand/ladegut/wagen)-sum(gv/verlader/versand/ladegut/wagen[@zeitraum='tag'])) div $week),'###.#')"/></td>
			<td><xsl:value-of select="($week* sum(gv/verlader/versand/ladegut/wagen[@zeitraum='tag']))+(sum(gv/verlader/versand/ladegut/wagen)-sum(gv/verlader/versand/ladegut/wagen[@zeitraum='tag']))"/></td>
		</tr>
		<tr>
			<td><xsl:text>Total</xsl:text></td>
			<td><xsl:value-of select="format-number(sum(gv/verlader/empfang/ladegut/wagen[@zeitraum='tag'])+sum(gv/verlader/versand/ladegut/wagen[@zeitraum='tag'])+((sum(gv/verlader/empfang/ladegut/wagen)+sum(gv/verlader/versand/ladegut/wagen)-sum(gv/verlader/empfang/ladegut/wagen[@zeitraum='tag'])-sum(gv/verlader/versand/ladegut/wagen[@zeitraum='tag'])) div $week),'###.#')"/></td>
			<td><xsl:value-of select="($week* ( sum(gv/verlader/empfang/ladegut/wagen[@zeitraum='tag'])+sum(gv/verlader/versand/ladegut/wagen[@zeitraum='tag']) ))+(sum(gv/verlader/empfang/ladegut/wagen)+sum(gv/verlader/versand/ladegut/wagen)-sum(gv/verlader/empfang/ladegut/wagen[@zeitraum='tag'])-sum(gv/verlader/versand/ladegut/wagen[@zeitraum='tag']))"/></td>
		</tr>
	</table>
	</td></tr>
		<tr><td class="mitte" colspan="{$maxcols}"><xsl:text disable-output-escaping="yes">Note: The results are calculated based on assumptions: 7 days a week and no reloading of empty cars!</xsl:text></td></tr>
	  </table>
	</xsl:template>
</xsl:stylesheet>
