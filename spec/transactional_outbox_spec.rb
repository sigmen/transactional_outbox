# frozen_string_literal: true

RSpec.describe TransactionalOutbox do
  it "has a version number" do
    expect(TransactionalOutbox::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
