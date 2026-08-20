# frozen_string_literal: true

RSpec.describe TransactionalOutbox::ExponentialBackoff do
  describe "#calculate_retry_delay" do
    subject(:calculate_retry_delay) { described_class.calculate_retry_delay(retry_num) }

    timings = {
      1 => 2,
      2 => 4,
      3 => 8,
      4 => 16,
      5 => 32
    }

    timings.each do |retry_n, delay|
      context "when retry is #{retry_n}" do
        let(:retry_num) { retry_n }

        it "returns correct delay" do
          expect(calculate_retry_delay).to eq delay
        end
      end
    end
  end
end
