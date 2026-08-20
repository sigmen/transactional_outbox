# frozen_string_literal: true

RSpec.describe TransactionalOutbox::Adapters::Database do
  subject(:resolve) { described_class.resolve(adapter_name) }
  subject(:register) { described_class.register(adapter_name, adapter_class) }

  let(:adapter_name) { :test }
  let(:adapter_class) { Class.new }

  after do
    clear_database_adapters_container
  end

  describe "#resolve" do
    context "when an adapter exists" do
      before { register }

      it "returns an adapter class" do
        expect(resolve).to eq adapter_class
      end
    end

    context "when the adapter doesnt exist" do
      it "returns an error" do
        expect { resolve }.to raise_error TransactionalOutbox::UnknownAdapterError
      end
    end
  end

  describe "#register" do
    context "when adapter doesnt not exist" do
      it "registers an adapter" do
        register

        expect(resolve).to eq adapter_class
      end
    end

    context "when trying to register an adapter twice" do
      it "raises an error" do
        register

        expect { register }.to raise_error TransactionalOutbox::AdapterAlreadyExistsError
      end
    end
  end
end
