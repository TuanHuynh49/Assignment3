<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="murach.business.Cart, murach.business.LineItem, murach.util.CookieUtil" %>
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
                        <div class="subtitle">Review your order details and session info</div>
                    </div>
                </div>
            </div>
            
            <%
                String userEmail = (String) session.getAttribute("userEmail");
                if (userEmail == null || userEmail.isEmpty()) {
                    userEmail = CookieUtil.getCookieValue(request.getCookies(), "userEmail");
                }
            %>
            
            <% if (userEmail != null && !userEmail.isEmpty()) { %>
                <div class="cookie-card">
                    <div class="cookie-badge">
                        <span>👋</span>
                        <span>Welcome back, <b><%= userEmail %></b> <i style="font-weight: normal; color: var(--slate-600);">(Loaded from Cookie)</i></span>
                    </div>
                    <form action="cart" method="post">
                        <input type="hidden" name="action" value="deleteCookie">
                        <button type="submit" class="btn btn-remove">Forget Me (Delete Cookie)</button>
                    </form>
                </div>
            <% } else { %>
                <div class="cookie-card" style="flex-direction: column; align-items: flex-start; gap: 12px;">
                    <div class="cookie-badge" style="color: var(--slate-800);">
                        <span>🍪</span>
                        <span><b>Save your session:</b> Enter email to remember your device using Persistent Cookie</span>
                    </div>
                    <form action="cart" method="post" style="width: 100%; gap: 10px;">
                        <input type="hidden" name="action" value="saveUser">
                        <input type="email" name="email" placeholder="Enter your email (e.g. user@example.com)" style="flex: 1; min-width: 260px;" required>
                        <button type="submit" class="btn btn-primary">Save Email</button>
                    </form>
                </div>
            <% } %>
            
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
