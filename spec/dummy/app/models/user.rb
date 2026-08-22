# frozen_string_literal: true

class User < Sequel::Model(:users)
  unrestrict_primary_key
end
