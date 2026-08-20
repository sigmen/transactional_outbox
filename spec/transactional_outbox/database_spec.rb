# frozen_string_literal: true

RSpec.describe TransactionalOutbox::Database do
  shared_context "common cases" do |method_name|
    it "calls #{method_name} method of the null adapter" do
      expect_any_instance_of(TransactionalOutbox::Adapters::Database::Null)
        .to receive(method_name)
        .once
        .and_call_original

      subject
    end

    context "when test invironment is disabled" do
      let(:test_environment) { false }

      context "when adapter is sequel" do
        let(:db_adapter) { :sequel }

        it "calls correct method" do
          expect_any_instance_of(TransactionalOutbox::Adapters::Database::Sequel)
            .to receive(method_name)
            .once

          subject
        end
      end

      context "when adapter is active_record" do
        let(:db_adapter) { :active_record }

        it "calls correct method" do
          expect_any_instance_of(TransactionalOutbox::Adapters::Database::ActiveRecord)
            .to receive(method_name)
            .once

          subject
        end
      end

      context "when adapter is unknown" do
        let(:db_adapter) { :unknown }

        it "raises an error" do
          expect { subject }.to raise_error TransactionalOutbox::Exceptions::UnknownAdapterError
        end
      end
    end
  end

  let(:test_environment) { true }
  let(:db_adapter) { :null }

  before do
    allow(TransactionalOutbox.config).to receive(:test_environment).and_return(test_environment)
    allow(TransactionalOutbox.config.db).to receive(:adapter).and_return(db_adapter)
  end

  describe "#transaction" do
    subject(:transaction) { described_class.new.transaction {} }

    include_context "common cases", :transaction
  end
end
