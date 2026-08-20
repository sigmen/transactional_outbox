# frozen_string_literal: true

module TransactionalOutbox
  class ExponentialBackoff
    def self.calculate_retry_delay(retry_num) = 2**retry_num
  end
end
