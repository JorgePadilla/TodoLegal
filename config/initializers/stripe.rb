Stripe.api_key = ENV['STRIPE_SECRET_KEY']

BASE_PRICE_MONTHLY = 40.00
MONTHLY_PRICE_ANNUALLY = 8.50
ENTERPRISE_PRICE = 250.00
BASE_PRICE_ANNUALLY = 102.00

if Rails.env.development?
  STRIPE_PUBLIC_KEY = "pk_test_51H0sbTJDCreTdC1MiTmXgtca69vY4PqnUcbBLHTufp3dG2csCmxSOYq24Iw3ukIc64XllTaubTM4IrnCxNYMlBqZ00fMpYKMTR"
  STRIPE_SUBSCRIPTION_PRODUCT = "prod_HmWdVtbJ5fEFkU"
  STRIPE_MONTH_SUBSCRIPTION_PRICE = "price_1HCxa9JDCreTdC1MjLhqrSeW"
  STRIPE_YEAR_SUBSCRIPTION_PRICE = "price_1HCxa9JDCreTdC1M2wVLCYG0"
elsif Rails.env.production?
  STRIPE_PUBLIC_KEY = ENV['STRIPE_PUBLIC_KEY']
  STRIPE_SUBSCRIPTION_PRODUCT = ENV['STRIPE_SUBSCRIPTION_PRODUCT']
  STRIPE_MONTH_SUBSCRIPTION_PRICE = ENV['STRIPE_MONTH_SUBSCRIPTION_PRICE']
  STRIPE_YEAR_SUBSCRIPTION_PRICE = ENV['STRIPE_YEAR_SUBSCRIPTION_PRICE']
end