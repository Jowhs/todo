Sequel::Model.plugin :validation_helpers
# class Item
class Item < Sequel::Model
  set_primary_key :id

  many_to_one :user
  many_to_one :list

  def validate
    super
    validates_presence %i{name description due_date}, message: 'cannot be empty'
    validates_format /\A[A-Za-z]/, :name, message: 'is not a valid name'
  end
end
