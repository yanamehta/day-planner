"""AI shopping list and personal grocery list workspace."""

import from ..main {
    ShoppingItem,
    GroceryItem,
    GenerateShoppingList,
    GetShoppingList,
    ClearShoppingList,
    AddGroceryItem,
    ListGroceryItems,
    ToggleGroceryItem,
    DeleteGroceryItem
}

import from .IngredientItem { IngredientItem }
import from .GroceryItem { GroceryRow }


def:pub ShoppingPanel -> JsxElement {
    has ingredients: list[ShoppingItem] = [],
        groceries: list[GroceryItem] = [],
        mealText: str = "",
        groceryText: str = "",
        generating: bool = False;

    async can with entry {
        shoppingResult = root spawn GetShoppingList();

        ingredients = (
            shoppingResult.reports[0]
            if shoppingResult.reports
            else []
        );

        groceryResult = root spawn ListGroceryItems();

        groceries = (
            groceryResult.reports[0]
            if groceryResult.reports
            else []
        );
    }

    async def generateList {
        if not mealText.strip() {
            return;
        }

        generating = True;

        result = root spawn GenerateShoppingList(
            meal_description=mealText.strip()
        );

        ingredients = (
            result.reports[0]
            if result.reports
            else []
        );

        generating = False;
    }

    async def clearGeneratedList {
        root spawn ClearShoppingList();

        ingredients = [];
        mealText = "";
    }

    async def addManualGrocery {
        if not groceryText.strip() {
            return;
        }

        response = root spawn AddGroceryItem(
            name=groceryText.strip()
        );

        if response.reports {
            groceries = groceries + [response.reports[0]];
            groceryText = "";
        }
    }

    async def addIngredientToGroceries(
        ingredient: ShoppingItem
    ) {
        response = root spawn AddGroceryItem(
            name=ingredient.name,
            quantity=ingredient.quantity,
            unit=ingredient.unit
        );

        if response.reports {
            groceries = groceries + [response.reports[0]];
        }
    }

    async def toggleGrocery(id: str) {
        response = root spawn ToggleGroceryItem(
            item_id=id
        );

        if response.reports {
            updated = response.reports[0];

            groceries = [
                updated if jid(item) == id else item
                for item in groceries
            ];
        }
    }

    async def deleteGrocery(id: str) {
        root spawn DeleteGroceryItem(
            item_id=id
        );

        groceries = [
            item
            for item in groceries
            if jid(item) != id
        ];
    }

    def handleMealKeyPress(e: KeyboardEvent) {
        if e.key == "Enter" and not generating {
            generateList();
        }
    }

    def handleGroceryKeyPress(e: KeyboardEvent) {
        if e.key == "Enter" {
            addManualGrocery();
        }
    }

    totalCost: float = 0.0;

    for ing in ingredients {
        totalCost = totalCost + ing.cost;
    }

    groceriesRemaining: int = len([
        item
        for item in groceries
        if not item.checked
    ]);

    return
        <div class="shopping-workspace">
            <section class="panel shopping-panel">
                <div class="panel-heading">
                    <h2>AI Shopping List</h2>

                    {
                        <button
                            class="btn-clear"
                            onClick={lambda {
                                clearGeneratedList();
                            }}
                        >
                            Clear
                        </button>
                        if len(ingredients) > 0
                        else None
                    }
                </div>

                <div class="shopping-input">
                    <input
                        class="input"
                        value={mealText}
                        onChange={lambda (e: ChangeEvent) {
                            mealText = e.target.value;
                        }}
                        onKeyPress={handleMealKeyPress}
                        placeholder="Describe a meal..."
                    />

                    <button
                        class="btn-generate"
                        onClick={lambda {
                            generateList();
                        }}
                        disabled={generating}
                    >
                        {("Generating..." if generating else "Generate")}
                    </button>
                </div>

                {
                    <div class="status-message">
                        Generating your shopping list...
                    </div>
                    if generating
                    else (
                        <div class="status-message">
                            Describe a meal to generate its ingredients.
                        </div>
                        if len(ingredients) == 0
                        else
                        <div class="ingredient-list">
                            {[
                                <IngredientItem
                                    key={jid(ing)}
                                    ing={ing}
                                    onAdd={lambda {
                                        addIngredientToGroceries(ing);
                                    }}
                                />
                                for ing in ingredients
                            ]}

                            <div class="shopping-total">
                                <span>Estimated total</span>
                                <strong>
                                    ${f"{totalCost:.2f}"}
                                </strong>
                            </div>
                        </div>
                    )
                }
            </section>

            <section class="panel grocery-panel">
                <h2>My Grocery List</h2>

                <div class="input-row">
                    <input
                        class="input"
                        value={groceryText}
                        onChange={lambda (e: ChangeEvent) {
                            groceryText = e.target.value;
                        }}
                        onKeyPress={handleGroceryKeyPress}
                        placeholder="Add a grocery item..."
                    />

                    <button
                        class="btn-add"
                        onClick={lambda {
                            addManualGrocery();
                        }}
                    >
                        Add
                    </button>
                </div>

                {
                    <div class="status-message">
                        Your grocery list is empty.
                    </div>
                    if len(groceries) == 0
                    else
                    <div class="grocery-list">
                        {[
                            <GroceryRow
                                key={jid(item)}
                                item={item}
                                onToggle={lambda {
                                    toggleGrocery(jid(item));
                                }}
                                onDelete={lambda {
                                    deleteGrocery(jid(item));
                                }}
                            />
                            for item in groceries
                        ]}
                    </div>
                }

                <div class="count">
                    {groceriesRemaining}
                    {
                        " item remaining"
                        if groceriesRemaining == 1
                        else " items remaining"
                    }
                </div>
            </section>
        </div>;
}