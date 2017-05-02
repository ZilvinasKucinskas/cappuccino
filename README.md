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
