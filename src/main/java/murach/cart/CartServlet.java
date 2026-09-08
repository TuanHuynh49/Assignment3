package murach.cart;

import java.io.IOException;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import murach.business.Cart;
import murach.business.LineItem;
import murach.business.Product;
import murach.data.ProductIO;
import murach.util.CookieUtil;

@WebServlet(name = "CartServlet", urlPatterns = {"/cart"})
public class CartServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        ServletContext sc = getServletContext();
        HttpSession session = request.getSession();
        
        // Check for existing userEmail cookie and sync with session
        Cookie[] cookies = request.getCookies();
        String userEmailCookie = CookieUtil.getCookieValue(cookies, "userEmail");
        if (!userEmailCookie.isEmpty() && session.getAttribute("userEmail") == null) {
            session.setAttribute("userEmail", userEmailCookie);
        }

        // Get current action
        String action = request.getParameter("action");
        if (action == null) {
            action = "cart";  // default action
        }

        // Perform action and set URL to appropriate page
        String url = "/index.html";
        if (action.equals("shop")) {
            url = "/index.html";
        } 
        else if (action.equals("cart")) {
            String productCode = request.getParameter("productCode");
            String quantityString = request.getParameter("quantity");

            Cart cart = (Cart) session.getAttribute("cart");
            if (cart == null) {
                cart = new Cart();
            }

            int quantity;
            try {
                quantity = Integer.parseInt(quantityString);
                if (quantity < 0) {
                    quantity = 1;
                }
            } catch (NumberFormatException nfe) {
                quantity = 1;
            }

            String path = sc.getRealPath("/WEB-INF/products.txt");
            Product product = ProductIO.getProduct(productCode, path);

            if (product != null) {
                LineItem lineItem = new LineItem();
                lineItem.setProduct(product);
                lineItem.setQuantity(quantity);
                if (quantity > 0) {
                    cart.addItem(lineItem);
                } else if (quantity <= 0) {
                    cart.removeItem(lineItem);
                }
            }

            // Store cart in session
            session.setAttribute("cart", cart);
            url = "/cart.jsp";
        }
        else if (action.equals("checkout")) {
            url = "/checkout.jsp";
        }
        else if (action.equals("saveUser")) {
            // Save user info into Cookie and Session
            String email = request.getParameter("email");
            if (email != null && !email.trim().isEmpty()) {
                Cookie c = new Cookie("userEmail", email.trim());
                c.setMaxAge(60 * 60 * 24 * 365 * 2); // 2 years
                c.setPath("/");
                response.addCookie(c);
                session.setAttribute("userEmail", email.trim());
            }
            url = "/checkout.jsp";
        }
        else if (action.equals("deleteCookie")) {
            // Delete cookie
            Cookie c = new Cookie("userEmail", "");
            c.setMaxAge(0);
            c.setPath("/");
            response.addCookie(c);
            session.removeAttribute("userEmail");
            url = "/checkout.jsp";
        }

        sc.getRequestDispatcher(url).forward(request, response);
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
