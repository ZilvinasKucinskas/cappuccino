# Goal

Reactive EventSourcing demo application

## Installation instructions

```
bundle install
bundle exec rake db:create
bundle exec rake db:migrate db:test:prepare
```

## Running test suite

```
bundle exec rake rspec spec/
```

## Specific library usage described in depth

### Working with events

Firstly you have to define own event model extending EventStore::Event class.

```
class OrderPlaced < EventStore::Event
end

# or

OrderPlaced = Class.new(EventStore::Event)
```

Then you can create events via EventRepository:

```
stream_name = "order_1"
event = OrderPlaced.new(data: {
          order_data: "sample",
          product_id: 2
        })

# publishing event for specific stream

EventStore::EventRepository.new.create(event, stream_name: stream_name)
```

### Cappuccino usage

```

# Define events
AccountCreated = Class.new(EventStore::Event)
MoneyDeposited = Class.new(EventStore::Event)
MoneyWithdrawn = Class.new(EventStore::Event)

# Create Streams
account_stream = Cappuccino::Stream.new(AccountCreated, MoneyDeposited, MoneyWithdrawn).
  as_persistent_type(Account, %i(account_id)).
  init(-> (state) { state.balance = 0 })


# Publish event
stream_name = "account"
event = AccountCreated.new(data: {
          account_id: 1,
        })
EventStore::EventRepository.new.create(event, stream_name)

```

### Test working implementation

```
OrderPlaced = Class.new(EventStore::Event)

stream = Cappuccino::Stream.new(OrderPlaced)

```

### Merge example

# Create Streams
one_stream = Cappuccino::Stream.new(AccountCreated)
second_stream = Cappuccino::Stream.new(AccountCreated)

new_stream = Cappuccino::Stream.new(one_stream, second_stream)

account_stream = Cappuccino::Stream.new(AccountCreated, MoneyDeposited, MoneyWithdrawn).
  as_persistent_type(Account, %i(account_id)).
  init(-> (state) { state.balance = 0 })
