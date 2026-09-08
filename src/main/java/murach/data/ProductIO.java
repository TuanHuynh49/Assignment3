package murach.data;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;
import murach.business.Product;

public class ProductIO {

    public static Product getProduct(String code, String filepath) {
        if (code == null) {
            return null;
        }

        if (filepath != null) {
            try {
                File file = new File(filepath);
                if (file.exists()) {
                    try (BufferedReader in = new BufferedReader(new FileReader(file))) {
                        String line = in.readLine();
                        while (line != null) {
                            StringTokenizer t = new StringTokenizer(line, "|");
                            if (t.countTokens() >= 3) {
                                String productCode = t.nextToken().trim();
                                if (code.equalsIgnoreCase(productCode)) {
                                    String description = t.nextToken().trim();
                                    double price = Double.parseDouble(t.nextToken().trim());
                                    return new Product(productCode, description, price);
                                }
                            }
                            line = in.readLine();
                        }
                    }
                }
            } catch (IOException | NumberFormatException e) {
                System.err.println("Error reading products file: " + e.getMessage());
            }
        }

        return getProductByCodeFallback(code);
    }

    public static List<Product> getProducts(String filepath) {
        List<Product> products = new ArrayList<>();
        if (filepath != null) {
            try {
                File file = new File(filepath);
                if (file.exists()) {
                    try (BufferedReader in = new BufferedReader(new FileReader(file))) {
                        String line = in.readLine();
                        while (line != null) {
                            StringTokenizer t = new StringTokenizer(line, "|");
                            if (t.countTokens() >= 3) {
                                String productCode = t.nextToken().trim();
                                String description = t.nextToken().trim();
                                double price = Double.parseDouble(t.nextToken().trim());
                                products.add(new Product(productCode, description, price));
                            }
                            line = in.readLine();
                        }
                    }
                    if (!products.isEmpty()) {
                        return products;
                    }
                }
            } catch (IOException | NumberFormatException e) {
                System.err.println("Error reading products file: " + e.getMessage());
            }
        }

        // Fallback default list
        products.add(new Product("8601", "86 (the band) - True Life Songs and Pictures", 14.95));
        products.add(new Product("pf01", "Paddlefoot - The first CD", 12.95));
        products.add(new Product("pf02", "Paddlefoot - The second CD", 14.95));
        products.add(new Product("jr01", "Joe Rut - Genuine Wood Grained Finish", 14.95));
        return products;
    }

    private static Product getProductByCodeFallback(String code) {
        if ("8601".equalsIgnoreCase(code)) {
            return new Product("8601", "86 (the band) - True Life Songs and Pictures", 14.95);
        } else if ("pf01".equalsIgnoreCase(code)) {
            return new Product("pf01", "Paddlefoot - The first CD", 12.95);
        } else if ("pf02".equalsIgnoreCase(code)) {
            return new Product("pf02", "Paddlefoot - The second CD", 14.95);
        } else if ("jr01".equalsIgnoreCase(code)) {
            return new Product("jr01", "Joe Rut - Genuine Wood Grained Finish", 14.95);
        }
        return null;
    }
}
