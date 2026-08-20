# frozen_string_literal: true

RSpec.describe TransactionalOutbox::Producer do
  shared_context "common cases" do |method_name|
    it "calls #{method_name} method of the null adapter" do
      expect_any_instance_of(TransactionalOutbox::Adapters::Producer::Null)
        .to receive(method_name)
        .once
        .and_call_original

      subject
    end

    context "when test invironment is disabled" do
      let(:test_environment) { false }

      context "when adapter is karafka" do
        let(:producer_adapter) { :karafka }

        it "calls correct method" do
          expect_any_instance_of(TransactionalOutbox::Adapters::Producer::Karafka)
            .to receive(method_name)
            .once

          subject
        end
      end

      context "when adapter is unknown" do
        let(:producer_adapter) { :unknown }

        it "raises an error" do
          expect { subject }.to raise_error TransactionalOutbox::Exceptions::UnknownAdapterError
        end
      end
    end
  end

  let(:test_environment) { true }
  let(:producer_adapter) { :null }

  before do
    allow(TransactionalOutbox.config).to receive(:test_environment).and_return(test_environment)
    allow(TransactionalOutbox.config.producer).to receive(:adapter).and_return(producer_adapter)
  end

  describe "#produce_batch" do
    subject { described_class.new.produce_batch(topic, batch) }

    let(:topic) { "test-topic" }
    let(:batch) { [{ "foo" => "bar" }] }

    include_context "common cases", :produce_batch
  end
end
