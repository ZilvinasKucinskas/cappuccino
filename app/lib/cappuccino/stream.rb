module Cappuccino
  class Stream
    include Observable

    def initialize(*sources)
      sources.each do |source|
        # source.extend(Cappuccino::Source).add_observer(self)
        source.add_observer(self)
      end
    end

    # The observers must implement a method called update to receive notifications.
    #
    # The observable object must:
    #
    # assert that it has #changed
    # call #notify_observers
    def update(event)
      occur(event)
    end

    protected

    def occur(value)
      changed
      notify_observers(value)
    end
  end
end
