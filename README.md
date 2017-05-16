[![Build Status](https://travis-ci.org/ZilvinasKucinskas/cappuccino.svg?branch=master)](https://travis-ci.org/ZilvinasKucinskas/cappuccino)

# Goal

Reactive EventSourcing demo application.

## Motivation

EventSourcing describes current state as series of events that occurred in a system. Events hold all information that is needed to recreate current state. This method allows to achieve high volume of transactions, and enables efficient replication. Whereas reactive programming lets implement reactive systems in declarative style, decomposing logic into smaller, easier to understand components. Thesis aims to create reactive programming program interface, incorporating both principles. Applying reactive programming in event-sourcing systems enables modelling not only instantaneous events, but also have their history. Furthermore, it enables focus on the solvable problem, regardless of low level realization details. Reactive operators enable read model creation without exposing realization details of operations with data storage.

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

## Project structure

* `app/lib/event_store` - files required for publishing events. Functionality is being taken from [rails_event_store_active_record](https://github.com/arkency/rails_event_store_active_record/blob/fc229f614aec7ff41f813f7c07adb249d16aa220/lib/rails_event_store_active_record/event_repository.rb) and slightly modified.
* `app/lib/cappuccino` - stream and reactive operators implementation. Modified version of [frappuccino](https://github.com/steveklabnik/frappuccino) gem.
* `spec/lib` - library tests

## Specific library usage described in depth

### Event definitions

```
# Define events
AccountCreated = Class.new(EventStore::Event)
MoneyDeposited = Class.new(EventStore::Event)
MoneyWithdrawn = Class.new(EventStore::Event)
```

Alternative definition:

```
class AccountCreated < EventStore::Event; end
class MoneyDeposited < EventStore::Event; end
class MoneyWithdrawn < EventStore::Event; end
```

### Create stream

We can define stream that is creating read model once in our app. Keep in mind that no database operations are present here.

```
one_stream = Cappuccino::Stream.new(AccountCreated)
second_stream = Cappuccino::Stream.new(AccountCreated)

new_stream = Cappuccino::Stream.new(one_stream, second_stream)

account_stream = Cappuccino::Stream.new(AccountCreated, MoneyDeposited, MoneyWithdrawn).
  as_persistent_type(Account, %i(account_id)).
  init(-> (state) { state.balance = 0 }).
  when(MoneyDeposited, -> (state, event) { state.balance += event.data[:amount] }).
  when(MoneyWithdrawn, -> (state, event) { state.balance -= event.data[:amount] })
```

Instead of passing `lambda` directly, we can also use a variable to save and reuse `lambda`:

```
account_initial_state_change_function = -> (state) { state.balance = 0 }
```

or even use a class that implements `call` method. We can structure our code with some kind of denormalizer for example:

```
class Denormalizers::ReadModelType::InitialState::Account
  def call(state)
    state.balance = 0
  end
end
```

### Publish events

We can create an account:

```
stream_name = "account"
event = AccountCreated.new(data: {
          account_id: 'LT121000011101001000'
        })
EventStore::EventRepository.new.create(event, stream_name)
```

Transfer some money (100$ for example) to the account:

```
stream_name = "account"
event = MoneyDeposited.new(data: {
          account_id: 'LT121000011101001000',
          amount: 100
        })
EventStore::EventRepository.new.create(event, stream_name)
```

Withdraw some money (25$ for example) from the account:

```
stream_name = "account"
event = MoneyWithdrawn.new(data: {
          account_id: 'LT121000011101001000',
          amount: 25
        })
EventStore::EventRepository.new.create(event, stream_name)
```

Now we can query read model like:

```
account = Account.find_by(account_id: 'LT121000011101001000')
puts account.balance # prints 75
```

## Available reactive operators

* `merge(another_stream)` - merge one stream to another.
* `filter(predicate_function)` - if predicate function returns false, event won't get propogated through the chain any more.
* `map(transform_function)` - applies transformation function and propogates event through the chain.
* `init(initial_state_change_function)` - applies initial state change function for the first event.
* `when(event_type, state_change_function)` - if event matches event type, record is being created or loaded, state change function is being applied for the record and transition state saved to database.
* `each(state_change_function)` - same as `when` operator, just does not check event type and applies state change function for each event.

## Implementation

Reactive operators were implemented using Observer design pattern, object oriented programming principles and introspection.

Transition state is being solved by applying metaprogramming (introspection, reflection) and using method chaining.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Possible improvements

* Make a gem
* Make demo application with UI. Controller should publish events. Event types and streams should be defined in some kind of initializer file for example.
* Improve error handling - could be bugs, because it's just prototype version.
* Refactor event publishing mechanics. We can borrow optimistic locking from [RailsEventStore](https://github.com/arkency/rails_event_store)
* More tests
