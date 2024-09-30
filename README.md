
## **Runnr App**

### **Table of Contents**
- [Project Overview](#project-overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Setup and Installation](#setup-and-installation)
- [Database Setup](#database-setup)
- [Usage](#usage)
- [Testing](#testing)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [License](#license)


### **Project Overview**

This is a marketplace application built using Ruby on Rails, allowing individual store owners to create stores, list products, and manage orders. The app also allows regular users to browse and purchase products without creating an account. Payment integration is handled through Flutterwave, and various user roles dictate access and functionality across the platform.


### **Features**
- **User Authentication:** Integrated with Devise for store owners and customers.
- **User Roles:**
  - Regular users (customers)
  - Store owners
- **Store Management:** Store owners can create and manage their stores, add products, and view orders.
- **Product Listings:** Both signed-in users and guests can browse products.
- **Shopping Cart:** Session-based for guests, user-based for signed-in users.
- **Payments:** Integration with Flutterwave for secure payments.
- **Pagination:** Product listings paginated using `will_paginate` and styled with Tailwind CSS.
- **Responsive Design:** Tailwind CSS for layout and form styling.
- **Flash Messaging:** Integrated with Toastr for flash message notifications.
- **Charts:** Display store-specific sales data for store owners.
- **User Profile:** Order history and logo management for registered users.
- **Message Negotiation:** Users can send negotiation messages directly from the product page.
  

### **Tech Stack**

- **Frontend:**
  - Tailwind CSS (via `tailwindcss-rails`)
  - Toastr for flash messages
- **Backend:**
  - Ruby on Rails (Devise for authentication, ActiveRecord)
- **Database:**
  - PostgreSQL
- **Payments:**
  - Flutterwave integration (with test webhooks in development)
- **Other Libraries/Tools:**
  - `will_paginate` for pagination
  - `toastr-rails` for notifications


### **Setup and Installation**

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

2. **Install dependencies:**
   ```bash
   bundle install
   yarn install
   ```

3. **Configure environment variables:**
   - Add your Flutterwave API keys and other necessary configurations in `.env` or `credentials.yml`.

4. **Setup the database:**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```


### **Database Setup**

Ensure PostgreSQL is installed and running. You can configure the database in `config/database.yml`:

```yaml
development:
  adapter: postgresql
  encoding: unicode
  database: runnr_development
  pool: 5
  username: <your-username>
  password: <your-password>

test:
  adapter: postgresql
  encoding: unicode
  database: runnr_test
  pool: 5
  username: <your-username>
  password: <your-password>

production:
  adapter: postgresql
  encoding: unicode
  database: runnr_production
  pool: 5
  username: <your-username>
  password: <your-password>
```


### **Usage**

To start the Rails server:

```bash
bin/dev
```

Visit `http://localhost:3000` to view the app locally.


### **Testing**

- To run tests, use:
   ```bash
   rails test
   ```
   Ensure that you add more tests as you continue developing the app, especially for crucial functionalities like payments, user authentication, and cart management.


### **Deployment**

1. **Render Deployment:**
   - Follow Render's deployment steps, including configuring environment variables for production.
   - Make sure you have SSL verification enabled for Flutterwave in production.


### **Contributing**

- Fork the repository.
- Create a new branch for your feature or bug fix.
- Submit a pull request for review.

### **License**

[MIT License](LICENSE)

