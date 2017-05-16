require 'spec_helper'

module Cappuccino
  describe Init do
    include_examples "publish events"

    before(:all) do
      Cappuccino::Stream.new(AccountCreated, MoneyDeposited).
        as_persistent_type(Account, %i(account_id)).
        init(-> (state) { state.balance = 0 }).
        when(MoneyDeposited, -> (state, event) { state.balance += event[:data][:amount] })
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
