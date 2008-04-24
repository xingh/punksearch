<%@page import="org.punksearch.web.statistics.FileTypeStatistics"%>
<%@page import="org.punksearch.common.PunksearchProperties"%>
<%@page import="org.apache.lucene.index.IndexReader"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.DateFormat"%>
<%@page import="java.util.Map"%>
<%@page import="org.jfree.data.general.DefaultPieDataset"%>
<%@page import="org.jfree.chart.JFreeChart"%>
<%@page import="org.jfree.chart.ChartFactory"%>
<%@page import="java.text.NumberFormat" %>

	<div id="statistics">
		<h2>Index Statistics</h2>
		<%
			String indexDir = PunksearchProperties.resolveIndexDirectory();
			IndexReader ir = IndexReader.open(indexDir);
			NumberFormat nf = NumberFormat.getNumberInstance();
			NumberFormat nfPercent = NumberFormat.getPercentInstance();
			nfPercent.setMaximumFractionDigits(2);
			//nfPercent.setMinimumIntegerDigits(2);
			
			Long totalSize = FileTypeStatistics.totalSize();
			int totalCount = ir.numDocs();

		%>
		<table align="center" class="data">
			<tr>
				<th width="50%">Path to Index Directory</th>
				<td width="50%"><%= indexDir %></td>
			</tr>
			<tr>
				<th>Last Modified</th>
				<td><%= new Date(IndexReader.lastModified(indexDir)).toString() %></td>
			</tr>
			<tr>
				<th>Total Count of Indexed Items</th>
				<td><%= nf.format(totalCount) %></td>
			</tr>
			<tr>
				<th>Total Size of Indexed Data</th>
				<td><%= nf.format(totalSize) %> bytes</td>
			</tr>
		</table>
		
		<%
		
		Map<String, Long> countValues = FileTypeStatistics.count();
		JFreeChart countChart = ChartFactory.createPieChart("Count Distribution (items/type) *", FileTypeStatistics.makePieDataset(countValues, totalCount), false, true, false);
		session.setAttribute("countChart", countChart);
		
		Map<String, Long> sizeValues = FileTypeStatistics.size();
		JFreeChart sizeChart = ChartFactory.createPieChart("Size Distribution (bytes/type) *", FileTypeStatistics.makePieDataset(sizeValues, totalSize), false, true, false);
		session.setAttribute("sizeChart", sizeChart);

		%>
		<table align="center">
			<tr>
				<td>
					<img src="chart/countChart" height="300" width="480" /><br/>
				</td>
				<td>
					<img src="chart/sizeChart" height="300" width="480" /><br/>
				</td>
			</tr>
			<!--tr>
				<td><a href="javascript:toggleTable('count_table')">toggle table</a></td>
				<td><a href="javascript:toggleTable('size_table')">toggle table</a></td>
			</tr-->
			<tr>
				<td>
					<table id="count_table" class="data" cellspacing="1" style="background-color: gray; width: 100%;">
						<tr><th width="30%">type</th><th width="30%">%</th><th width="30%">count</th></tr>
						<%
						int sum = 0;
						for (String key : countValues.keySet()) {
						sum += countValues.get(key);
						%>
						<tr><td><%= key %></td><td align="right" ><%= nfPercent.format(countValues.get(key) / (totalCount + 0.0)) %></td><td align="right" ><%= nf.format(countValues.get(key)) %></td></tr>
						<% } %>
						<tr><td>other</td><td align="right" ><%= nfPercent.format((totalCount - sum) / (totalCount + 0.0)) %></td><td align="right" ><%= nf.format(totalCount - sum) %></td></tr>
					</table>
				</td>
				<td>
					<table id="size_table" class="data" cellspacing="1" style="background-color: gray; width: 100%;">
						<tr><th width="30%">type</th><th width="30%">%</th><th width="30%">size in bytes</th></tr>
						<tr><td>directory</td><td align="right" >0.00%</td><td align="right" >0</td></tr>
						<%
						long sumSize = 0;
						for (String key : sizeValues.keySet()) {
						sumSize += sizeValues.get(key);
						%>
						<tr><td><%= key %></td><td align="right" ><%= nfPercent.format(sizeValues.get(key) / (totalSize + 0.0)) %></td><td align="right" ><%= nf.format(sizeValues.get(key)) %></td></tr>
						<% } %>
						<tr><td>other</td><td align="right" ><%= nfPercent.format((totalSize - sumSize) / (totalSize + 0.0)) %></td><td align="right" ><%= nf.format(totalSize - sumSize) %></td></tr>
					</table>
				</td>
			</tr>
		</table>
		<span id="hint">
		* assuming filetypes.conf defines disjunct file sets
		</span>
	</div>