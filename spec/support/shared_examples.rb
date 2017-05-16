RSpec.shared_examples "publish events" do
  AccountCreated = Class.new(EventStore::Event)
  MoneyDeposited = Class.new(EventStore::Event)
  MoneyWithdrawn = Class.new(EventStore::Event)

  let(:publish_account_created_event) do
    event = AccountCreated.new(
      data: {
        account_id: 'LT121000011101001000'
      }
    )
    EventStore::EventRepository.new.create(event, :account)
  end

  let(:publish_money_deposited_event) do
    event = MoneyDeposited.new(
      data: {
        account_id: 'LT121000011101001000',
        amount: 100
      }
    )
    EventStore::EventRepository.new.create(event, :account)
  end

  let(:publish_money_withdrawn_event) do
    event = MoneyWithdrawn.new(
      data: {
        account_id: 'LT121000011101001000',
        amount: 25
      }
    )
    EventStore::EventRepository.new.create(event, :account)
  end
end
