# Product Catalog

A Flutter product catalog application built using the free DummyJSON REST API.

The application allows users to browse products, search for products, view product details, and load additional products through pagination.

---

## Tech Stack

- Flutter
- Dart
- DummyJSON REST API
- `http` package
- Flutter Web / Chrome for development and testing

---

## Features

### Product List

- Displays product title
- Displays product thumbnail
- Displays product price
- Tap a product to view its details

### Pagination

Products are loaded progressively as the user scrolls towards the bottom of the list.

The DummyJSON `skip` parameter is used to request subsequent pages.

### Product Details

The product detail screen displays:

- Product images
- Product title
- Product description
- Product price
- Product rating

### Search

Users can search for products using the search field.

Search requests are debounced by 400 milliseconds to avoid making an API request for every keystroke.

Search results also support pagination.

### UI States

The application handles and visually distinguishes:

- Loading
- Success
- Error
- Empty

The error state includes a Retry button.

### Pull-to-Refresh

The product list supports pull-to-refresh.

When refreshing:

- The normal product list reloads the first page.
- An active search reloads the current search query.

### Image Error Handling

Product images include basic error handling when an image cannot be loaded.

---

## API

This project uses the free DummyJSON API.

No API key is required.

### Product List

```text
GET https://dummyjson.com/products?limit=20&skip=0