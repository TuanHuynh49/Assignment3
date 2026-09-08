<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="murach.business.Cart, murach.business.LineItem" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Your Cart - Murach's Java Servlets and JSP</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="styles/main.css" type="text/css"/>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <div class="header-title-group">
                    <div class="header-icon">🛒</div>
                    <div>
                        <h1>Your Shopping Cart</h1>
                        <div class="subtitle">Manage items and review your order</div>
                    </div>
                </div>
            </div>
            
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th style="width: 190px;">Quantity</th>
                            <th>Description</th>
                            <th class="right" style="width: 110px;">Price</th>
                            <th class="right" style="width: 110px;">Amount</th>
                            <th class="center" style="width: 150px;">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Cart cart = (Cart) session.getAttribute("cart");
                            double totalAmount = 0.0;
                            if (cart != null && cart.getItems() != null && !cart.getItems().isEmpty()) {
                                for (LineItem item : cart.getItems()) {
                                    totalAmount += item.getTotal();
                        %>
                        <tr>
                            <td>
                                <form action="cart" method="post" class="qty-input-group">
                                    <input type="hidden" name="action" value="update">
                                    <input type="hidden" name="productCode" value="<%= item.getProduct().getCode() %>">
                                    <input type="number" name="quantity" value="<%= item.getQuantity() %>" min="1" class="qty-field" required>
                                    <button type="submit" class="btn btn-update">Update</button>
                                </form>
                            </td>
                            <td class="desc-cell"><%= item.getProduct().getDescription() %></td>
                            <td class="right"><span class="price-tag"><%= item.getProduct().getPriceCurrencyFormat() %></span></td>
                            <td class="right"><span class="amount-tag"><%= item.getTotalCurrencyFormat() %></span></td>
                            <td class="center">
                                <form action="cart" method="post">
                                    <input type="hidden" name="action" value="remove">
                                    <input type="hidden" name="productCode" value="<%= item.getProduct().getCode() %>">
                                    <button type="submit" class="btn btn-remove">✕ Remove</button>
                                </form>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="5" class="empty-state">
                                <div class="empty-state-icon">🛒</div>
                                <div>Your shopping cart is currently empty.</div>
                            </td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
            
            <% if (cart != null && cart.getItems() != null && !cart.getItems().isEmpty()) { %>
            <div class="note-box">
                💡 <span><b>Tip:</b> To change the quantity, enter the new number and click <b>Update</b>.</span>
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
                <form action="cart" method="post">
                    <input type="hidden" name="action" value="checkout">
                    <button type="submit" class="btn btn-success btn-lg">
                        Proceed to Checkout →
                    </button>
                </form>
                <% } %>
            </div>
        </div>
    </body>
</html>
