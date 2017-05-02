class Event < ApplicationRecord
  self.table_name = 'event_store_events'

  serialize :metadata
  serialize :data
end
