package murach.cart;

import java.io.IOException;
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

        // 5. Chuyển hướng đến trang tương ứng
        sc.getRequestDispatcher(url).forward(request, response);
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
