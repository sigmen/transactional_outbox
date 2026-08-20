# frozen_string_literal: true

RSpec.describe TransactionalOutbox::Event::Contextable do
  describe "#validate_context!" do
    subject(:validate_context) { klass.new.validate_context!(context) }

    let(:klass) do
      Class.new do
        extend TransactionalOutbox::Event::Contextable

        context do
          required(:foo).filled(:string)
        end
      end
    end

    let(:context) { { foo: "bar" } }

    context "when context is valid" do
      it { is_expected.to be_truthy }
    end

    context "when context is invalid" do
      let(:context) { {} }

      it "raises an error" do
        expect { validate_context }.to raise_error TransactionalOutbox::InvalidContextError
      end
    end

    context "when context schema is not set" do
      let(:klass) do
        Class.new do
          extend TransactionalOutbox::Event::Contextable
        end
      end

      it { is_expected.to be_truthy }
    end
  end
end
