# frozen_string_literal: true

Sequel::Model.db = Sequel.sqlite

Sequel::Model.db.create_table!(:outbox_events) do
  String :id
  String :queue
  String :queue_extra_parameters
  String :status
  String :event_type
  String :aggregate_type
  String :aggregate_id
  String :payload
  String :headers
  DateTime :processing_started_at
  DateTime :created_at
  DateTime :updated_at

  primary_key [:id]
end

Sequel::Model.db.create_table!(:users) do
  String :id
  String :name

  primary_key [:id]
end

Sequel.default_timezone = :utc
