<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>Kết quả thanh toán VNPAY - Murach Store</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="styles/main.css?v=1.1" type="text/css"/>
        <link rel="stylesheet" href="styles/vnpay.css?v=1.1" type="text/css"/>
    </head>
    <body>
        <div class="container container-return">
            <%
                Boolean isSuccess = (Boolean) request.getAttribute("isSuccess");
                Boolean isValidSignature = (Boolean) request.getAttribute("isValidSignature");
                String responseCode = request.getParameter("vnp_ResponseCode");
                String amountStr = request.getParameter("vnp_Amount");
                long amount = 0;
                if (amountStr != null) {
                    try {
                        amount = Long.parseLong(amountStr) / 100;
                    } catch (NumberFormatException e) {
                        amount = 0;
                    }
                }

                String txnRef = request.getParameter("vnp_TxnRef");
                String transactionNo = request.getParameter("vnp_TransactionNo");
                String bankCode = request.getParameter("vnp_BankCode");
                String orderInfo = request.getParameter("vnp_OrderInfo");
                String payDate = request.getParameter("vnp_PayDate");

                // Giải nghĩa mã lỗi VNPAY
                String message = "";
                if (isValidSignature != null && !isValidSignature) {
                    message = "Chữ ký bảo mật không hợp lệ (Sai Checksum). Dữ liệu có thể đã bị can thiệp!";
                } else if ("00".equals(responseCode)) {
                    message = "Giao dịch thanh toán đã được thực hiện thành công. Cảm ơn quý khách!";
                } else if ("07".equals(responseCode)) {
                    message = "Trừ tiền thành công. Giao dịch bị nghi ngờ (liên quan tới lừa đảo, giao dịch bất thường).";
                } else if ("09".equals(responseCode)) {
                    message = "Giao dịch không thành công do: Thẻ/Tài khoản chưa đăng ký InternetBanking.";
                } else if ("10".equals(responseCode)) {
                    message = "Giao dịch không thành công do: Xác thực thông tin thẻ/tài khoản không đúng quá 3 lần.";
                } else if ("11".equals(responseCode)) {
                    message = "Giao dịch không thành công do: Đã hết hạn chờ thanh toán.";
                } else if ("12".equals(responseCode)) {
                    message = "Giao dịch không thành công do: Thẻ/Tài khoản của quý khách bị khóa.";
                } else if ("13".equals(responseCode)) {
                    message = "Giao dịch không thành công do nhập sai mật khẩu OTP.";
                } else if ("24".equals(responseCode)) {
                    message = "Giao dịch không thành công do khách hàng đã bấm hủy giao dịch.";
                } else if ("51".equals(responseCode)) {
                    message = "Giao dịch không thành công do tài khoản không đủ số dư.";
                } else if ("65".equals(responseCode)) {
                    message = "Giao dịch không thành công do tài khoản vượt quá hạn mức trong ngày.";
                } else if ("75".equals(responseCode)) {
                    message = "Ngân hàng thanh toán đang bảo trì hệ thống.";
                } else {
                    message = "Giao dịch không thành công (Mã lỗi: " + responseCode + ").";
                }
            %>

            <!-- STATUS BANNER -->
            <% if (isSuccess != null && isSuccess) { %>
            <div class="status-banner success">
                <span class="status-icon">🎉</span>
                <div class="status-title">Thanh toán Thành công!</div>
                <div class="status-message"><%= message %></div>
            </div>
            <% } else { %>
            <div class="status-banner error">
                <span class="status-icon">⚠️</span>
                <div class="status-title">Thanh toán Thất bại!</div>
                <div class="status-message"><%= message %></div>
            </div>
            <% } %>

            <!-- INVOICE DETAILS CARD -->
            <div class="table-wrapper invoice-wrapper">
                <table class="invoice-table">
                    <tr>
                        <td class="invoice-label">Mã đơn hàng (TxnRef):</td>
                        <td class="invoice-value"><%= (txnRef != null) ? txnRef : "N/A" %></td>
                    </tr>
                    <tr>
                        <td class="invoice-label">Mã giao dịch tại VNPAY:</td>
                        <td class="invoice-value"><%= (transactionNo != null && !transactionNo.isEmpty()) ? transactionNo : "N/A" %></td>
                    </tr>
                    <tr>
                        <td class="invoice-label">Số tiền thanh toán:</td>
                        <td class="invoice-value invoice-amount">
                            <%= java.text.NumberFormat.getInstance(new java.util.Locale("vi", "VN")).format(amount) %> VND
                        </td>
                    </tr>
                    <tr>
                        <td class="invoice-label">Ngân hàng thanh toán:</td>
                        <td class="invoice-value"><%= (bankCode != null) ? bankCode : "VNPAY" %></td>
                    </tr>
                    <tr>
                        <td class="invoice-label">Nội dung thanh toán:</td>
                        <td class="invoice-value"><%= (orderInfo != null) ? orderInfo : "" %></td>
                    </tr>
                    <% if (payDate != null && payDate.length() == 14) { 
                        String formattedDate = payDate.substring(6, 8) + "/" + payDate.substring(4, 6) + "/" + payDate.substring(0, 4) 
                                + " " + payDate.substring(8, 10) + ":" + payDate.substring(10, 12) + ":" + payDate.substring(12, 14);
                    %>
                    <tr>
                        <td class="invoice-label">Thời gian giao dịch:</td>
                        <td class="invoice-value"><%= formattedDate %></td>
                    </tr>
                    <% } %>
                    <tr>
                        <td class="invoice-label">Trạng thái phản hồi:</td>
                        <td class="invoice-value">
                            <% if (isSuccess != null && isSuccess) { %>
                                <span class="badge-code badge-success">Mã 00 - Thành công</span>
                            <% } else { %>
                                <span class="badge-code badge-error">Mã <%= responseCode %> - Lỗi</span>
                            <% } %>
                        </td>
                    </tr>
                </table>
            </div>

            <!-- ACTION FOOTER -->
            <div class="actions-footer return-actions">
                <a href="cart?action=shop" class="btn btn-secondary">
                    ← Tiếp tục mua sắm
                </a>
                <a href="cart?action=cart" class="btn btn-primary">
                    🛒 Xem giỏ hàng
                </a>
            </div>
        </div>
    </body>
</html>
