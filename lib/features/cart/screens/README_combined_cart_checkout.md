# Combined Cart & Checkout Screen

This new screen combines the cart and checkout functionality into a single page with two tabs, similar to the design shown in the screenshots.

## Features

- **Two Rounded Tabs**: "Your Order" and "Delivery & Payment"
- **Orange Primary Color**: Consistent with the app's theme
- **Sleek Design**: Modern, clean interface with proper spacing and shadows
- **Clear Cart Functionality**: Button to clear the entire cart/order
- **Progress Indicator**: Shows current step in the checkout process

## Usage

### Navigation

To navigate to the combined cart/checkout screen:

```dart
// Navigate to the combined screen
Get.toNamed(RouteHelper.getCombinedCartCheckoutRoute());

// With parameters
Get.toNamed(RouteHelper.getCombinedCartCheckoutRoute(
  fromReorder: false,
  fromDineIn: false,
));
```

### Replacing Existing Cart Navigation

To use the new combined screen instead of the old cart screen, replace:

```dart
// Old way
Get.toNamed(RouteHelper.getCartRoute(fromDineIn: fromDineIn));

// New way
Get.toNamed(RouteHelper.getCombinedCartCheckoutRoute(fromDineIn: fromDineIn));
```

## Screen Structure

### Your Order Tab
- Restaurant information with logo and name
- Cart items list with quantity controls
- Add more items button
- Clear cart button with confirmation dialog

### Delivery & Payment Tab
- Delivery details section with PIN confirmation notice
- Delivery address display
- Note for rider option
- Payment summary with itemized costs
- Payment method selection
- Place order button

## Key Components

1. **Progress Indicator**: Shows completion status of both steps
2. **Rounded Tab Bar**: Clean tab switching with orange active state
3. **Card-based Layout**: Each section is contained in a card with shadows
4. **Consistent Styling**: Orange primary color throughout
5. **Responsive Design**: Works on different screen sizes

## Integration

The screen integrates with existing controllers:
- `CartController`: For cart management
- `RestaurantController`: For restaurant information
- `CheckoutController`: For checkout functionality

## Customization

The screen can be easily customized by modifying:
- Colors in the `_buildTabBar()` method
- Layout in individual tab builders
- Button styles and interactions
- Card decorations and shadows
