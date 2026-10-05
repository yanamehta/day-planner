"""Presentational row for one personal grocery item."""

import from ..main { GroceryItem }


def:pub GroceryRow(
    item: GroceryItem,
    onToggle: Callable[[], None],
    onDelete: Callable[[], None]
) -> JsxElement {
    return
        <div class="grocery-item">
            <input
                type="checkbox"
                checked={item.checked}
                onChange={onToggle}
            />

            <div class="grocery-info">
                <span
                    class={
                        "grocery-name " +
                        ("grocery-checked" if item.checked else "")
                    }
                >
                    {item.name}
                </span>

                <span class="grocery-quantity">
                    {item.quantity} {item.unit}
                </span>
            </div>

            <button
                class="btn-delete"
                onClick={onDelete}
            >
                X
            </button>
        </div>;
}