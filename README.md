# paypal-mass-payout-rails-example
A rails example app for Paypal Payoutr API calls using the gem [paypal-sdk-rest](https://github.com/paypal/PayPal-Ruby-SDK).

## Setup
### Edit your .env
```
$ cp .env.sample .env
```
Then edit `.env` and fill your Paypal Rest client id and secret.

### Setup the database
`rake db:setup`

## Use
### Payee
1. Create a new `Payee` with an email to send the payout notification.
2. Choose one currency.
3. Fill a balance value.

### Payout batch
1. Fill an email subject for new payout batch.
2. Select payees to send your batch
3. Click on *Post* at the bottom left of the payout batch details page.
4. Click on *Refresh* to update the status of your batch.

