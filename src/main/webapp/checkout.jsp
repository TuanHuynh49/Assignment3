<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="murach.business.Cart, murach.business.LineItem, murach.util.CookieUtil" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Murach's Java Servlets and JSP</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="styles/main.css" type="text/css"/>
    </head>
    <body>
        <h1>Checkout</h1>
        
        <%
            String userEmail = (String) session.getAttribute("userEmail");
            if (userEmail == null || userEmail.isEmpty()) {
                userEmail = CookieUtil.getCookieValue(request.getCookies(), "userEmail");
            }
        %>
        
        <% if (userEmail != null && !userEmail.isEmpty()) { %>
            <p>Welcome back, <b><%= userEmail %></b>! (Loaded from Cookie)</p>
            <form action="cart" method="post" style="display:inline;">
                <input type="hidden" name="action" value="deleteCookie">
                <input type="submit" value="Forget Me (Delete Cookie)">
            </form>
            <br><br>
        <% } else { %>
            <form action="cart" method="post" style="margin-bottom: 1em;">
                <input type="hidden" name="action" value="saveUser">
                <label for="email">Enter your email to remember your session (Save Cookie):</label><br>
                <input type="text" id="email" name="email" style="width: 200px; text-align: left;" placeholder="you@example.com" required>
                <input type="submit" value="Save Email">
            </form>
        <% } %>
        
        <table>
            <tr>
                <th>Quantity</th>
                <th>Description</th>
                <th class="right">Price</th>
                <th class="right">Amount</th>
            </tr>
            <%
                Cart cart = (Cart) session.getAttribute("cart");
                double total = 0.0;
                if (cart != null && cart.getItems() != null && !cart.getItems().isEmpty()) {
                    for (LineItem item : cart.getItems()) {
                        total += item.getTotal();
            %>
            <tr>
                <td class="center"><%= item.getQuantity() %></td>
                <td><%= item.getProduct().getDescription() %></td>
                <td class="right"><%= item.getProduct().getPriceCurrencyFormat() %></td>
                <td class="right"><%= item.getTotalCurrencyFormat() %></td>
            </tr>
            <%
                    }
                } else {
            %>
            <tr>
                <td colspan="4" style="text-align: center;">No items in cart.</td>
            </tr>
            <%
                }
            %>
        </table>
        
        <form action="cart" method="post">
            <input type="hidden" name="action" value="shop">
            <input type="submit" value="Continue Shopping">
        </form>
    </body>
</html>
