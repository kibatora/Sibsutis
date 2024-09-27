<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:template match="/">
<html>
	<head>
		<title>РГЗ</title>
	</head>
	<body>
		<h2>РГЗ</h2>
		<h3>Выполнил: Зырянов Иван Александрович</h3>
		<h3>Группа: ИА-231</h3>
		<h3>Вариант: 1</h3>
		<hr/>
		<xsl:apply-templates/>
	</body>
</html>
</xsl:template>
<xsl:template match="hiblock">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="page">
	
	<h2>Страница <xsl:value-of select="@num"/></h2>
	<xsl:if test="@num=0">
	<h3>Числа Фибоначчи</h3>
	<table border="1" cellspacing="0" cellpadding="10">
	<xsl:for-each select="variants/sequence">
		<xsl:if test="@variant=1">
		<tr>
			<th>N</th>
			<xsl:for-each select="items/item">
			     <td style="color:white;background-color:{num/@color};"><xsl:value-of select="num" /></td>
			</xsl:for-each>	
		</tr>		
        <tr>
			<th>Значение</th>
			<xsl:for-each select="items/item">
				<td> <xsl:value-of select="val" /> </td>
			</xsl:for-each>
		</tr>
		</xsl:if>
	</xsl:for-each>
	</table>
	</xsl:if>
	<xsl:if test="@num=1">
	<hr/>
	<tr>пикча</tr>
	<table cellspacing="0" cellpadding="0">
		<xsl:variable name="redfive" select="table/@row-size"/>
		<tr>
			<xsl:for-each select="table/item">
				<xsl:sort select="order" order="descending" data-type="number"/>
					<xsl:if test="(order mod $redfive)=0">
						<tr> </tr>
					
	</xsl:if>
	<td><img src="{url}"/></td>
	</xsl:for-each> </tr> </table>
	<hr/>
	</xsl:if>
	<xsl:if test="@num=2">
	<hr/>
	<xsl:value-of select="name"/>
	<table border="1" cellspacing="0" cellpadding="10">
	<xsl:for-each select="countries/country">
		<xsl:sort select="id" data-type="number"/>
		<tr>
		<td><h4><xsl:value-of select="id" /></h4></td>
		<td><h4><xsl:value-of select="uf_name" /></h4></td>
		<td><img src="{uf_icon}"/></td>
		</tr>
	</xsl:for-each>	
	</table>
	</xsl:if>
	<xsl:if test="@num=3">
	<h3><xsl:value-of select="name" /></h3>
			<hr/>
					<xsl:variable name="rgz" select="students/student"/>
		            <xsl:variable name="infor" select="groups/group"/>
		                <xsl:for-each select="subjects/subject">
		                    <div style="float: left;
										padding:20px;
										margin:20px;">
		                        <h4><xsl:value-of select="name"/></h4>
		                        <xsl:variable name="sprite" select="@id"/>
		                        <table border="1" cellspacing="0" cellpadding="5">
		                            <xsl:for-each select="$rgz">
		                                <xsl:sort select="lname" data-type="text"/>
		                                <xsl:if test="subjects/subject = $sprite">
		                                <tr>
		                                    <th>
		                                        <xsl:value-of select="lname"/>
		                                        <xsl:text> </xsl:text>
		                                        <xsl:value-of select="substring (fname,1,1)"/>
		                                        <xsl:text>.</xsl:text>
		                                        <xsl:value-of select="substring (sname,1,1)"/>
		                                        <xsl:text>.</xsl:text>
		                                    </th>
		                                    <td>
		                                        <xsl:variable name="it" select="group"/>
		                                        <xsl:value-of select="$infor[@id = $it]/name"/>
		                                    </td>
		                                </tr>
		                                </xsl:if>
		                            </xsl:for-each>
		                        </table>
		                    </div>
		                </xsl:for-each>
		                <div style="float: left;
										padding:20px;
										margin:20px;">
		                        <h4>Не участвующие студенты</h4>
		                <table border="1" cellspacing="0" cellpadding="5">
		                <xsl:for-each select="students/student">
		                	<xsl:sort select="lname" data-type="text"/>
		                	<xsl:if test="subjects = ''">
		                		
		                                <tr>
		                                    <th>
		                                        <xsl:value-of select="lname"/>
		                                        <xsl:text> </xsl:text>
		                                        <xsl:value-of select="substring (fname,1,1)"/>
		                                        <xsl:text>.</xsl:text>
		                                        <xsl:value-of select="substring (sname,1,1)"/>
		                                        <xsl:text>.</xsl:text>
		                                    </th>
		                                    <td>
		                                        <xsl:variable name="pit" select="group"/>
		                                        <xsl:value-of select="$infor[@id = $it]/name"/>
		                                    </td>
		                                </tr>
		                	</xsl:if>
		                </xsl:for-each>
		            	</table>
		                </div>
	</xsl:if>
</xsl:template>

</xsl:stylesheet>
