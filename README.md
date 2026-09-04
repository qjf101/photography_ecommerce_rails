# Photography Ecommerce Rails

A Ruby on Rails e-commerce app for selling photography prints, with guest and
registered checkout, Stripe-powered payments, order/refund management, and an
admin portal.

## Tech stack

- Ruby 3.3.11 / Rails 8.1
- Postgres (via the `pg` gem) for the primary database in every environment; SQLite for the
  `solid_queue`/`solid_cache`/`solid_cable` databases in production
- Stripe (Checkout Sessions + webhooks) for payments
- Active Storage (local disk in development) for product images
- Action Mailer for order confirmation emails
- `bcrypt` (`has_secure_password`) for authentication
- Minitest for the test suite

## Setup

1. Install dependencies:
   ```
   bundle install
   ```
2. Make sure Postgres is installed and running locally, then create a role
   for the app (only needs to be done once):
   ```
   psql -U postgres -c "CREATE ROLE photography_ecommerce_rails WITH LOGIN PASSWORD 'devpassword' CREATEDB;"
   ```
   The role also needs `SUPERUSER` locally — not for anything the app itself
   does, but because Rails' test fixture loader needs to temporarily disable
   foreign-key checking (fixture files reference each other regardless of
   insert order), and Postgres only allows that for a superuser:
   ```
   psql -U postgres -c "ALTER ROLE photography_ecommerce_rails WITH SUPERUSER;"
   ```
3. Copy `.env.example` to `.env` and fill in real values:
   ```
   cp .env.example .env
   ```
   `DB_PASSWORD` should match whatever you set when creating the role above.
   Get the Stripe keys from your [Stripe dashboard](https://dashboard.stripe.com/test/apikeys)
   in test mode. The webhook secret comes from running the Stripe CLI locally
   (see below) — it prints one each time `stripe listen` starts.
   `.env` is gitignored and never committed; `.env.example` is the template
   that is.
4. Set up the database (this creates both the development database and its
   separate `_test` counterpart, and seeds some sample products plus a dev
   admin account — see below):
   ```
   bin/rails db:setup
   ```

## Running the app locally

You'll want three things running at once in development:

```
bin/rails server                                        # the app itself
stripe listen --forward-to localhost:3000/stripe/webhooks # forwards Stripe events
mailcatcher                                              # catches order confirmation emails
```

- The app runs at `http://localhost:3000`.
- Stripe test card `4242 4242 4242 4242` (any future expiry, any CVC) simulates
  a successful payment — see [Stripe's testing docs](https://docs.stripe.com/testing)
  for more test cards (declines, etc.).
- MailCatcher's web UI is at `http://localhost:1080` by default — order
  confirmation emails are sent there instead of a real inbox in development.

`bin/rails db:seed` creates a dev-only admin account (`admin@example.com` /
`password123`, seeded only in the `development` environment) so you can reach
`/admin` right away. There's no self-service way to promote a *different*
account to admin (by design) — if you want to make some other account an
admin, do it via the console:
```
bin/rails runner "User.find_by(email: 'you@example.com').update!(admin: true)"
```

## Running the tests

```
bin/rails test
```

## Features

**Customers**
- Browse products, add to cart (guest or logged in), adjust quantities
- Guest or registered checkout via Stripe Checkout, with shipping address
  and cost collected by Stripe
- Order confirmation email, and an order lookup flow for guests (by email +
  order number)
- "My Account" — profile management, and order history for registered users
- Request a refund on a paid order

**Admin** (`/admin`, requires an admin account)
- Manage products: create/edit, upload images, enable/disable listings
- Manage orders: view, mark complete, process refunds
- Manage users: view accounts, remove them

## Deployment

Deploys via [Kamal](https://kamal-deploy.org) (`bin/kamal deploy`). The
production primary database is Postgres, connected to via `DB_HOST`, `DB_NAME`,
`DB_USER`, and `DB_PASSWORD` — these must be set as real environment variables
in the shell you run `bin/kamal deploy` from (Kamal reads them at deploy time
to inject into the container and to populate `.kamal/secrets`); having them in
your local `.env` is not enough, since `.env` is only loaded by the app itself
in development/test, not read by Kamal.

## Notable design decisions

- Cart/checkout data isn't destroyed until Stripe confirms payment via
  webhook — not at the point of starting checkout — so an abandoned checkout
  doesn't lose the customer's cart.
- Order line items snapshot the product's price at the time of purchase,
  independent of the live product price.
- Order URLs use a random confirmation token rather than the database id.
