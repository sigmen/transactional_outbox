# frozen_string_literal: true

RSpec.describe TransactionalOutbox::Event::Contextable do
  describe "#build_payload" do
    subject(:build_payload) { klass.new.build_payload(context) }

    let(:klass) do
      Class.new do
        extend TransactionalOutbox::Event::Payloadable

        prepare_payload do |context|
          {
            foo: context[:foo],
            bar: "foo"
          }
        end
      end
    end

    let(:context) { { foo: "bar" } }
    let(:result) { { foo: "bar", bar: "foo" } }

    it "returns correct result" do
      expect(build_payload).to eq result
    end

    context "when payload pipe block is not defined" do
      let(:klass) do
        Class.new do
          extend TransactionalOutbox::Event::Payloadable
        end
      end

      it "returns itself" do
        expect(build_payload).to eq context
      end
    end
  end
end
