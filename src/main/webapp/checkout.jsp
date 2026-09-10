<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="murach.business.Cart, murach.business.LineItem" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Checkout - Murach's Java Servlets and JSP</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="styles/main.css" type="text/css"/>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <div class="header-title-group">
                    <div class="header-icon">💳</div>
                    <div>
                        <h1>Checkout Summary</h1>
                        <div class="subtitle">Review your order details stored in Session</div>
                    </div>
                </div>
            </div>
            
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th class="center" style="width: 80px;">Qty</th>
                            <th>Description</th>
                            <th class="right">Price</th>
                            <th class="right">Amount</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Cart cart = (Cart) session.getAttribute("cart");
                            double total = 0.0;
                            if (cart != null && cart.getItems() != null && !cart.getItems().isEmpty()) {
                                for (LineItem item : cart.getItems()) {
                                    total += item.getTotal();
                        %>
                        <tr>
                            <td class="center"><b><%= item.getQuantity() %></b></td>
                            <td class="desc-cell"><%= item.getProduct().getDescription() %></td>
                            <td class="right"><span class="price-tag"><%= item.getProduct().getPriceCurrencyFormat() %></span></td>
                            <td class="right"><span class="amount-tag"><%= item.getTotalCurrencyFormat() %></span></td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="4" class="empty-state">
                                <div>No items in cart for checkout.</div>
                            </td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
            
            <% if (cart != null && cart.getItems() != null && !cart.getItems().isEmpty()) { %>
            <div class="total-summary-card">
                <div class="total-label">Total Amount:</div>
                <div class="total-value">
                    <%= java.text.NumberFormat.getCurrencyInstance(java.util.Locale.US).format(total) %>
                </div>
            </div>
            <% } %>
            
            <div class="actions-footer">
                <form action="cart" method="post">
                    <input type="hidden" name="action" value="shop">
                    <button type="submit" class="btn btn-secondary">
                        ← Continue Shopping
                    </button>
                </form>
                
                <% if (cart != null && cart.getItems() != null && !cart.getItems().isEmpty()) { %>
                <button type="button" class="btn btn-success btn-lg" onclick="alert('Order placed successfully! Thank you for purchasing.')">
                    ✓ Complete Order
                </button>
                <% } %>
            </div>
        </div>
    </body>
</html>
