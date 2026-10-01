package murach.cart;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import murach.business.Cart;
import murach.business.LineItem;
import murach.business.Product;
import murach.data.ProductIO;

@WebServlet(name = "CartServlet", urlPatterns = {"/cart"})
public class CartServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        ServletContext sc = getServletContext();
        
        // 1. Khởi tạo / lấy Session
        HttpSession session = request.getSession();

        // 2. Lấy đối tượng Cart từ Session (nếu chưa có thì tạo mới)
        Cart cart = (Cart) session.getAttribute("cart");
        if (cart == null) {
            cart = new Cart();
        }

        // 3. Lấy action từ request
        String action = request.getParameter("action");
        if (action == null) {
            action = "cart";  // default action
        }

        // 4. Xử lý các action nghiệp vụ
        String url = "/index.html";
        if (action.equals("shop")) {
            url = "/index.html";
        } 
        else if (action.equals("cart")) {
            // Thêm sản phẩm vào giỏ hàng
            String productCode = request.getParameter("productCode");
            String quantityString = request.getParameter("quantity");

            int quantity = 1;
            if (quantityString != null) {
                try {
                    quantity = Integer.parseInt(quantityString);
                    if (quantity < 1) {
                        quantity = 1;
                    }
                } catch (NumberFormatException nfe) {
                    quantity = 1;
                }
            }

            String path = sc.getRealPath("/WEB-INF/products.txt");
            Product product = ProductIO.getProduct(productCode, path);

            if (product != null) {
                LineItem lineItem = new LineItem();
                lineItem.setProduct(product);
                lineItem.setQuantity(quantity);
                cart.addItem(lineItem);
            }

            // Lưu giỏ hàng vào Session
            session.setAttribute("cart", cart);
            url = "/cart.jsp";
        }
        else if (action.equals("update")) {
            // Cập nhật lại số lượng trong giỏ hàng
            String productCode = request.getParameter("productCode");
            String quantityString = request.getParameter("quantity");

            int quantity = 1;
            try {
                quantity = Integer.parseInt(quantityString);
            } catch (NumberFormatException nfe) {
                quantity = 1;
            }

            cart.updateItem(productCode, quantity);
            
            // Cập nhật lại Session
            session.setAttribute("cart", cart);
            url = "/cart.jsp";
        }
        else if (action.equals("remove") || action.equals("removeItem")) {
            // Xóa sản phẩm khỏi giỏ hàng
            String productCode = request.getParameter("productCode");
            cart.removeItemByCode(productCode);
            
            // Cập nhật lại Session
            session.setAttribute("cart", cart);
            url = "/cart.jsp";
        }
        else if (action.equals("checkout")) {
            url = "/checkout.jsp";
        }
        else if (action.equals("vnpay_pay")) {
            // === XỬ LÝ KHỞI TẠO THANH TOÁN VNPAY ===
            if (cart.getItems() == null || cart.getItems().isEmpty()) {
                response.sendRedirect("cart?action=cart");
                return;
            }

            // Tỷ giá quy đổi giả định: 1 USD = 25,000 VND
            double exchangeRate = 25000.0;
            long amountVND = Math.round(cart.getTotalAmount() * exchangeRate);
            long vnpAmount = amountVND * 100; // VNPAY yêu cầu nhân 100 (để khử phần thập phân)

            String vnp_Version = "2.1.0";
            String vnp_Command = "pay";
            String vnp_TxnRef = VNPayConfig.getRandomNumber(8);
            String vnp_IpAddr = VNPayConfig.getIpAddress(request);
            String vnp_TmnCode = VNPayConfig.vnp_TmnCode;
            String vnp_OrderType = "other";
            String vnp_OrderInfo = "Thanh toan don hang #" + vnp_TxnRef;

            Map<String, String> vnp_Params = new HashMap<>();
            vnp_Params.put("vnp_Version", vnp_Version);
            vnp_Params.put("vnp_Command", vnp_Command);
            vnp_Params.put("vnp_TmnCode", vnp_TmnCode);
            vnp_Params.put("vnp_Amount", String.valueOf(vnpAmount));
            vnp_Params.put("vnp_CurrCode", "VND");
            vnp_Params.put("vnp_TxnRef", vnp_TxnRef);
            vnp_Params.put("vnp_OrderInfo", vnp_OrderInfo);
            vnp_Params.put("vnp_OrderType", vnp_OrderType);

            // Phương thức thanh toán ngân hàng (nếu người dùng chọn)
            String bankCode = request.getParameter("bankCode");
            if (bankCode != null && !bankCode.trim().isEmpty()) {
                vnp_Params.put("vnp_BankCode", bankCode);
            }

            // Ngôn ngữ giao diện (mặc định 'vn')
            String language = request.getParameter("language");
            if (language != null && !language.trim().isEmpty()) {
                vnp_Params.put("vnp_Locale", language);
            } else {
                vnp_Params.put("vnp_Locale", "vn");
            }

            // Xây dựng dynamic Return URL hỗ trợ cả Localhost và Reverse Proxy trên Render/Cloud
            String scheme = request.getHeader("X-Forwarded-Proto");
            if (scheme == null || scheme.isEmpty()) {
                scheme = request.getScheme();
            }
            String host = request.getHeader("X-Forwarded-Host");
            if (host == null || host.isEmpty()) {
                host = request.getServerName();
                int port = request.getServerPort();
                if (("http".equalsIgnoreCase(scheme) && port != 80) || ("https".equalsIgnoreCase(scheme) && port != 443)) {
                    host += ":" + port;
                }
            }
            String returnUrl = scheme + "://" + host + request.getContextPath() + "/cart?action=vnpay_return";
            vnp_Params.put("vnp_ReturnUrl", returnUrl);
            vnp_Params.put("vnp_IpAddr", vnp_IpAddr);

            // Định dạng thời gian CHÍNH XÁC theo múi giờ Việt Nam (Asia/Ho_Chi_Minh GMT+7)
            Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));
            SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
            formatter.setTimeZone(TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));
            String vnp_CreateDate = formatter.format(cld.getTime());
            vnp_Params.put("vnp_CreateDate", vnp_CreateDate);

            // Hết hạn sau 15 phút
            cld.add(Calendar.MINUTE, 15);
            String vnp_ExpireDate = formatter.format(cld.getTime());
            vnp_Params.put("vnp_ExpireDate", vnp_ExpireDate);

            // Sắp xếp các trường dữ liệu theo bảng chữ cái
            List<String> fieldNames = new ArrayList<>(vnp_Params.keySet());
            Collections.sort(fieldNames);
            StringBuilder hashData = new StringBuilder();
            StringBuilder query = new StringBuilder();
            Iterator<String> itr = fieldNames.iterator();
            while (itr.hasNext()) {
                String fieldName = itr.next();
                String fieldValue = vnp_Params.get(fieldName);
                if ((fieldValue != null) && (fieldValue.length() > 0)) {
                    // Build Hash Data
                    hashData.append(fieldName);
                    hashData.append('=');
                    hashData.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                    // Build Query String
                    query.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII.toString()));
                    query.append('=');
                    query.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                    if (itr.hasNext()) {
                        query.append('&');
                        hashData.append('&');
                    }
                }
            }

            String queryUrl = query.toString();
            String vnp_SecureHash = VNPayConfig.hmacSHA512(VNPayConfig.vnp_HashSecret, hashData.toString());
            queryUrl += "&vnp_SecureHash=" + vnp_SecureHash;
            String paymentUrl = VNPayConfig.vnp_PayUrl + "?" + queryUrl;

            // Chuyển hướng người dùng sang VNPAY
            response.sendRedirect(paymentUrl);
            return;
        }
        else if (action.equals("vnpay_return")) {
            // === XỬ LÝ KẾT QUẢ PHẢN HỒI TỪ VNPAY ===
            Map<String, String> fields = new HashMap<>();
            for (Enumeration<String> params = request.getParameterNames(); params.hasMoreElements();) {
                String fieldName = params.nextElement();
                String fieldValue = request.getParameter(fieldName);
                if ((fieldValue != null) && (fieldValue.length() > 0)) {
                    fields.put(fieldName, fieldValue);
                }
            }

            String vnp_SecureHash = request.getParameter("vnp_SecureHash");
            fields.remove("vnp_SecureHashType");
            fields.remove("vnp_SecureHash");

            // Sắp xếp và băm để kiểm tra chữ ký Checksum
            List<String> fieldNames = new ArrayList<>(fields.keySet());
            Collections.sort(fieldNames);
            StringBuilder hashData = new StringBuilder();
            Iterator<String> itr = fieldNames.iterator();
            while (itr.hasNext()) {
                String fieldName = itr.next();
                String fieldValue = fields.get(fieldName);
                if ((fieldValue != null) && (fieldValue.length() > 0)) {
                    hashData.append(fieldName);
                    hashData.append('=');
                    hashData.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                    if (itr.hasNext()) {
                        hashData.append('&');
                    }
                }
            }

            String signValue = VNPayConfig.hmacSHA512(VNPayConfig.vnp_HashSecret, hashData.toString());
            boolean isSuccess = false;
            boolean isValidSignature = signValue.equalsIgnoreCase(vnp_SecureHash);

            if (isValidSignature) {
                String responseCode = request.getParameter("vnp_ResponseCode");
                if ("00".equals(responseCode)) {
                    isSuccess = true;
                    // Xóa giỏ hàng khi thanh toán thành công
                    cart.clear();
                    session.setAttribute("cart", cart);
                }
            }

            request.setAttribute("isValidSignature", isValidSignature);
            request.setAttribute("isSuccess", isSuccess);
            url = "/vnpay_return.jsp";
        }

        // 5. Chuyển hướng đến trang tương ứng
        sc.getRequestDispatcher(url).forward(request, response);
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
