<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="murach.business.Cart, murach.business.LineItem" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Murach's Java Servlets and JSP</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="styles/main.css" type="text/css"/>
    </head>
    <body>
        <h1>Your cart</h1>
        
        <table>
            <tr>
                <th>Quantity</th>
                <th>Description</th>
                <th class="right">Price</th>
                <th class="right">Amount</th>
                <th>&nbsp;</th>
            </tr>
            <%
                Cart cart = (Cart) session.getAttribute("cart");
                if (cart != null && cart.getItems() != null && !cart.getItems().isEmpty()) {
                    for (LineItem item : cart.getItems()) {
            %>
            <tr>
                <td>
                    <form action="cart" method="post">
                        <input type="hidden" name="productCode" value="<%= item.getProduct().getCode() %>">
                        <input type="text" name="quantity" value="<%= item.getQuantity() %>" size="2">
                        <input type="submit" value="Update">
                    </form>
                </td>
                <td><%= item.getProduct().getDescription() %></td>
                <td class="right"><%= item.getProduct().getPriceCurrencyFormat() %></td>
                <td class="right"><%= item.getTotalCurrencyFormat() %></td>
                <td>
                    <form action="cart" method="post">
                        <input type="hidden" name="productCode" value="<%= item.getProduct().getCode() %>">
                        <input type="hidden" name="quantity" value="0">
                        <input type="submit" value="Remove Item">
                    </form>
                </td>
            </tr>
            <%
                    }
                } else {
            %>
            <tr>
                <td colspan="5" style="text-align: center;">Your cart is empty.</td>
            </tr>
            <%
                }
            %>
        </table>
        
        <p><b>To change the quantity</b>, enter the new quantity and click on the Update button.</p>
        
        <div class="btn-group">
            <form action="cart" method="post">
                <input type="hidden" name="action" value="shop">
                <input type="submit" value="Continue Shopping">
            </form>
            <br>
            <form action="cart" method="post">
                <input type="hidden" name="action" value="checkout">
                <input type="submit" value="Checkout">
            </form>
        </div>
    </body>
</html>
