<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="group5.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
    
    <%
    	if (session == null || session.getAttribute("username") == null) {
    		response.sendRedirect("LandingPage.jsp");
    	}
    
    	if (request.getParameter("auctionID") == null) {
    		response.sendRedirect("HomePage.jsp");
    	}
    %>

<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Auction <%out.print(request.getParameter("auctionID"));%>></title>
	</head>
	<body>		
    <% 
		try {
    		//Get the database connection
   			ApplicationDB db = new ApplicationDB();	
   			Connection con = db.getConnection();
			
   			
   		 	// Get the auction ID from the request parameter
            // Query to get auction details including end_time
            String auctionQuery = "SELECT end_time <= CURRENT_TIMESTAMP() FROM auction WHERE auction_id = ?";
            PreparedStatement auctionPs = con.prepareStatement(auctionQuery);
            auctionPs.setInt(1, Integer.valueOf(request.getParameter("auctionID")));

            ResultSet auctionRs = auctionPs.executeQuery();
            boolean showBiddingForms = true;

            if (auctionRs.next() && auctionRs.getBoolean(1)) {
            	// Query to find the highest bidder for the auction
            	showBiddingForms = false;
                String winnerQuery = "UPDATE auction a, bid b SET a.buyer_username = b.bidder_username WHERE a.auction_id = ? AND a.current_price >= a.hidden_minimum_price AND b.bid_id = (SELECT MAX(b2.bid_id) FROM bid b2 WHERE b2.auction_id = a.auction_id)";

				PreparedStatement winnerPs = con.prepareStatement(winnerQuery);
                winnerPs.setInt(1, Integer.valueOf(request.getParameter("auctionID")));

                winnerPs.executeUpdate();
                winnerPs.close();

            }

            auctionRs.close();
            auctionPs.close();
   			
   			
   			
   			
   			String query = "SELECT * FROM auction JOIN clothes USING (manufacture_id)  WHERE auction_id = ?";

			PreparedStatement ps = con.prepareStatement(query);	
			//prepare the statements
			ps.setInt(1, Integer.valueOf(request.getParameter("auctionID")));
			
			// Execute the querys
			ResultSet rs = ps.executeQuery();
			
			int category = -1;
			
			if (rs.next()) {
				String subcategoryQuery = "SELECT * FROM top WHERE manufacture_id = ?";
				ps = con.prepareStatement(subcategoryQuery);
				ps.setInt(1, rs.getInt("manufacture_id"));
				ResultSet scrs = ps.executeQuery();
				
				if (!scrs.next()) {
					subcategoryQuery = "SELECT * FROM bottoms WHERE manufacture_id = ?";
					ps = con.prepareStatement(subcategoryQuery);
					ps.setInt(1, rs.getInt("manufacture_id"));
					scrs = ps.executeQuery();
					
					if (!scrs.next()) {
						subcategoryQuery = "SELECT * FROM footwear WHERE manufacture_id = ?";
						ps = con.prepareStatement(subcategoryQuery);
						ps.setInt(1, rs.getInt("manufacture_id"));
						scrs = ps.executeQuery();
						
						if (!scrs.next()) {
							response.sendRedirect("HomePage.jsp");
						}
						else {
							category = 3;
						}
					}
					else {
						category = 2;
					}
				}
				else {
					category = 1;
				}					
	%>		
		<table>
				<tr>    
					<td>Seller</td><td><%="<a href='ParticipationHistory.jsp?username=" + rs.getString("seller_username") + "'>" + rs.getString("seller_username") + "</a>"%></td>
				</tr>
	<%
				String buyer = "<a href='ParticipationHistory.jsp?username=" + rs.getString("buyer_username") + "'>" + rs.getString("buyer_username") + "</a>";
				if (showBiddingForms) {
					buyer = "Auction has not eded yet!";
				} 
				else if (buyer == null) {
					buyer = "Item not sold! Auction Ended!";
				}
	%>
				<tr>    
					<td>Buyer</td><td><%=buyer%></td>
				</tr>
	<%
					if (category == 1) {
	%>
				<tr>
					<td>Category</td><td>Top</td>
				</tr>
				<tr>
					<td>Neck Type</td><td><%=scrs.getString("Neck_type")%></td>
				</tr>
				<tr>
					<td>Size</td><td><%=scrs.getString("size")%></td>
				</tr>
				<tr>
					<td>Sleeve Length</td><td><%=scrs.getString("sleeve_length")%></td>
				</tr>
	<%
					}
					else if (category == 2) {
	%>
				<tr>
					<td>Category</td><td>Bottom</td>
				</tr>
				<tr>
					<td>Type</td><td><%=scrs.getString("type")%></td>
				</tr>
				<tr>
					<td>Waist Length</td><td><%=scrs.getString("waist_length")%></td>
				</tr>
				<tr>
					<td>Rise Type</td><td><%=scrs.getString("rise_type")%></td>
				</tr>
	<%
					}
					else {
	%>
				<tr>
					<td>Category</td><td>Footwear</td>
				</tr>
				<tr>
					<td>Type of Footwear</td><td><%=scrs.getString("type_of_footwear")%></td>
				</tr>
				<tr>
					<td>Size</td><td><%=scrs.getString("size")%></td>
				</tr>
				<tr>
					<td>Lace Color</td><td><%=scrs.getString("lace_color")%></td>
				</tr>
	<%
					}
	%>
				<tr>
					<td>Brand</td><td><%=rs.getString("brand")%></td>
				</tr>
				<tr>
					<td>Gender</td><td><%=rs.getString("gender")%></td>
				</tr>
				<tr>
					<td>Age</td><td><%=rs.getString("age")%></td>
				</tr>
				<tr>
					<td>Start Time</td><td><%=rs.getTimestamp("start_time").toString()%></td>
				</tr>
				<tr>
					<td>End Time</td><td><%=rs.getTimestamp("end_time").toString()%></td>
				</tr>
				<tr>
					<td>Current Price</td><td><%=rs.getDouble("current_price")%></td>
				</tr>
				<tr>
					<td>Minimum Bid Increment</td><td><%=rs.getDouble("minimum_bid_increment")%></td>
				</tr>
		</table>
		
		<br><br>
		<form method="post" action="AuctionBidHistory.jsp">
        	<input type="hidden" name="auctionID" value=<%=request.getParameter("auctionID")%>>
        	<input type="submit" value="View Bid History">       
    	</form>
    	<br>
		<form method="post" action="SimilarItemAuction.jsp">
        	<input type="hidden" name="auctionID" value=<%=request.getParameter("auctionID")%>>
        	<input type="submit" value="View Similar">       
    	</form>
    	<br>
    	<form method="post" action="AllAuctions.jsp">
        	<input type="hidden" name="auctionID" value=<%=request.getParameter("auctionID")%>>
        	<input type="submit" value="Back">       
    	</form>
    	
    	
		
	<%
	
	if (!rs.getString("seller_username").equals(session.getAttribute("username")) && showBiddingForms) {
	
	%>
		
		<br><br>
		<h2>Place a Bid!</h2>
    	<form method="post" action="InsertBid.jsp">
        	<label for="amount">Amount:</label>
        	<input type="number" id="amount" name="amount" step="0.01" min="0.01" required><br>
        	<input type="hidden" name="auctionID" value=<%=request.getParameter("auctionID")%>>
        	<input type="submit" value="Bid">       
    	</form>
    	
    <%
    	String bidSettingQuery = "SELECT * FROM bidsetting WHERE auction_id = ? AND bidder_username = ?";
    	ps = con.prepareStatement(bidSettingQuery);
    	ps.setInt(1, Integer.valueOf(request.getParameter("auctionID")));
    	ps.setString(2, session.getAttribute("username").toString());
    	rs = ps.executeQuery();
    	
    	boolean autobiddingORnot, anonymousORnot;
    	autobiddingORnot = anonymousORnot = false;
    	double autobid_upper_limit = 0.01;
    	int flag = -1;
    	
    	if (rs.next()) {
    		anonymousORnot = rs.getBoolean("anonymousORnot");
    		autobiddingORnot = rs.getBoolean("autobiddingORnot");
    		autobid_upper_limit = rs.getDouble("autobid_upper_limit");
    		flag = 1;
    	}
    
    %> 	
    	
    	<!-- 
    	<h2>Current Bid Setting!</h2>
    	The user is <% if (!anonymousORnot) {%> not <% } %> an anonymous bidder. Auto-bidding is turned <% if (autobiddingORnot) { %> on with an upper limit of $<%=autobid_upper_limit%>. <% } else { %> off. <% } %>
    	-->
    	
    	<h2>Change Bid Setting!</h2>
    	<form method="post" action="InsertBidSetting.jsp">
    		<input type="checkbox" id="anonymousORnot" name="anonymousORnot" value="true" <% if (anonymousORnot) {%> checked <% } %>>
        	<label for="anonymousORnot">Anonymous</label>
        	<input type="checkbox" id="autobiddingORnot" name="autobiddingORnot" value="true" <% if (autobiddingORnot) {%> checked <% } %>>
        	<label for="autobiddingORnot">Auto Bidding</label>
        	<label for="autobid_upper_limit">Auto Bidding Upper Limit:</label>
        	<input type="number" id="autobid_upper_limit" name="autobid_upper_limit" step="0.01" min="0.01" value="<%=autobid_upper_limit%>" required><br>
        	<input type="hidden" name="auctionID" value=<%=request.getParameter("auctionID")%>>
        	<input type="hidden" name="existence" value=<%=flag%>>
        	<input type="submit" value="Bid">       
    	</form>
    	
    	<br><br>
    	
    	<form action="HomePage.jsp" method = "post">
		<input type="submit" value="Home Page">
		</form>
    <%
	}
	
		//Start Bid History Below
	
	
	
	
	
	
			}
			else {
				response.sendRedirect("HomePage.jsp");
			}
		}
		catch (Exception e) {
			out.print(e);
		}
	%>
	</body>
</html>