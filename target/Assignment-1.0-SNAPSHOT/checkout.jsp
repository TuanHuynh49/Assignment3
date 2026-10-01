<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="murach.business.Cart, murach.business.LineItem" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Checkout - Murach's Java Servlets and JSP</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="styles/main.css?v=1.3" type="text/css"/>
        <link rel="stylesheet" href="styles/vnpay.css?v=1.3" type="text/css"/>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <div class="header-title-group">
                    <div class="header-icon">💳</div>
                    <div>
                        <h1>Checkout Order Summary</h1>
                        <div class="subtitle">Review your items and complete payment via VNPAY</div>
                    </div>
                </div>
            </div>
            
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th class="center col-qty">Qty</th>
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
                                <div class="empty-state-icon">🛒</div>
                                <div>No items in cart for checkout.</div>
                            </td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
            
            <% if (cart != null && cart.getItems() != null && !cart.getItems().isEmpty()) { 
                long totalVND = Math.round(total * 25000);
            %>
            <div class="total-summary-card">
                <div>
                    <div class="total-label">Total Amount:</div>
                    <div class="exchange-rate-badge">Rate: 1 USD ≈ 25,000 VND</div>
                </div>
                <div class="total-value">
                    <div><%= java.text.NumberFormat.getCurrencyInstance(java.util.Locale.US).format(total) %></div>
                    <div class="total-summary-vnd">
                        ≈ <%= java.text.NumberFormat.getInstance(new java.util.Locale("vi", "VN")).format(totalVND) %> VND
                    </div>
                </div>
            </div>

            <!-- PAYMENT FORM VIA VNPAY -->
            <form action="cart" method="post" class="payment-card">
                <input type="hidden" name="action" value="vnpay_pay">
                
                <div class="payment-header">
                    <span class="payment-icon">🛡️</span>
                    <div>
                        <div class="payment-title">Cổng Thanh Toán Trực Tuyến VNPAY</div>
                        <div class="subtitle">Thanh toán an toàn, bảo mật qua thẻ ngân hàng, VNPAY-QR hoặc thẻ quốc tế</div>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label" for="bankCode">Phương thức thanh toán</label>
                    <select name="bankCode" id="bankCode" class="form-select">
                        <option value="">Cổng VNPAY (Khách hàng tự chọn phương thức)</option>
                        <option value="VNPAYQR">Thanh toán quét mã QR (VNPAY-QR App / Mobile Banking)</option>
                        <option value="VNBANK">Thẻ ATM / Tài khoản ngân hàng nội địa</option>
                        <option value="INTCARD">Thẻ thanh toán quốc tế (Visa, MasterCard, JCB)</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label">Ngôn ngữ hiển thị giao diện VNPAY</label>
                    <div class="radio-group">
                        <label class="radio-label">
                            <input type="radio" name="language" value="vn" checked> 🇻🇳 Tiếng Việt
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="language" value="en"> 🇬🇧 English
                        </label>
                    </div>
                </div>

                <div class="actions-footer">
                    <a href="cart?action=cart" class="btn btn-secondary">
                        ← Back to Cart
                    </a>
                    <button type="submit" class="btn vnpay-btn btn-lg">
                        Thanh toán qua VNPAY →
                    </button>
                </div>
            </form>
            <% } else { %>
            <div class="actions-footer">
                <a href="cart?action=shop" class="btn btn-secondary">
                    ← Continue Shopping
                </a>
            </div>
            <% } %>
        </div>
    </body>
</html>
