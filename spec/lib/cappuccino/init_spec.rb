require 'spec_helper'

module Cappuccino
  describe Init do
    AccountCreated = Class.new(EventStore::Event)
    MoneyDeposited = Class.new(EventStore::Event)

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

    before(:all) do
      Cappuccino::Stream.new(AccountCreated, MoneyDeposited).
        as_persistent_type(Account, %i(account_id)).
        init(-> (state) { state.balance = 0 }).
        when(Cappuccino::MoneyDeposited, -> (state, event) { state.balance += event[:data][:amount] })
    end

    describe 'transition state' do
      context 'with first event' do
        before { publish_account_created_event }

        it { expect(Account.first.present?).to be_truthy }
        it { expect(Account.first.balance).to be_zero }
      end

      context 'with other events modifying state' do
        before do
          publish_account_created_event
          publish_money_deposited_event
          publish_account_created_event
        end

        it { expect(Account.first.present?).to be_truthy }
        it { expect(Account.count).to eq(1) }
        it { expect(Account.first.balance).to eq(100) }
      end
    end
  end
end
