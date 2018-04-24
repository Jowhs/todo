Sequel::Model.plugin :validation_helpers
# class Item
class Item < Sequel::Model
  set_primary_key :id

  many_to_one :user
  many_to_one :list
end
