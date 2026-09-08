package murach.business;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class Cart implements Serializable {

    private List<LineItem> items;

    public Cart() {
        items = new ArrayList<>();
    }

    public List<LineItem> getItems() {
        return items;
    }

    public int getCount() {
        return items.size();
    }

    public void addItem(LineItem item) {
        if (item == null || item.getProduct() == null) {
            return;
        }
        String code = item.getProduct().getCode();
        int quantity = item.getQuantity();
        for (int i = 0; i < items.size(); i++) {
            LineItem lineItem = items.get(i);
            if (lineItem.getProduct().getCode().equalsIgnoreCase(code)) {
                // Khi trùng sản phẩm thì cộng dồn số lượng
                lineItem.setQuantity(lineItem.getQuantity() + quantity);
                return;
            }
        }
        items.add(item);
    }

    public void updateItem(String productCode, int quantity) {
        if (productCode == null) {
            return;
        }
        for (int i = 0; i < items.size(); i++) {
            LineItem lineItem = items.get(i);
            if (lineItem.getProduct().getCode().equalsIgnoreCase(productCode)) {
                if (quantity <= 0) {
                    items.remove(i);
                } else {
                    lineItem.setQuantity(quantity);
                }
                return;
            }
        }
    }

    public void removeItem(LineItem item) {
        if (item == null || item.getProduct() == null) {
            return;
        }
        String code = item.getProduct().getCode();
        removeItemByCode(code);
    }

    public void removeItemByCode(String code) {
        if (code == null) {
            return;
        }
        for (int i = 0; i < items.size(); i++) {
            LineItem lineItem = items.get(i);
            if (lineItem.getProduct().getCode().equalsIgnoreCase(code)) {
                items.remove(i);
                return;
            }
        }
    }
}
