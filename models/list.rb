require 'sequel'
require 'pry'
require 'pry-byebug'

Sequel::Model.plugin :validation_helpers
# class List
class List < Sequel::Model
  set_primary_key :id

  one_to_many :items, eager: [:user]
  one_to_many :permissions
  one_to_many :logs
  one_to_many :comments

  def self.new_list(name, items, user)
    list = List.create name: name, created_at: Time.now
    items.each do |item|
      Item.create(name: item[:name], description: item[:description], list: list, user: user, created_at: Time.now,\
                  updated_at: Time.now, due_date: item[:due_date])
    end
    Permission.create(list: list, user: user, permission_level: 'read_write',\
                      created_at: Time.now, updated_at: Time.now)
    list
  end

  def self.edit_list(id, name, items, user)
    list = List[id: id]
    list.name = name
    # list.updated_at = Time.now
    list.save
    # binding.pry
    items.each do |item|
      if item[:deleted]
        Item.first(id: item[:id].to_i).destroy
        next
      end
      i = Item[item[:id].to_i]
      if i.nil?
        Item.create(name: item[:name], description: item[:description], list: list, user: user, created_at: Time.now,\
                    updated_at: Time.now, starred: item[:starred], due_date: item[:due_date])
      else
        i.name = item[:name]
        i.description = item[:description]
        i.starred = if item[:starred].nil?
                      false
                    else
                      item[:starred]
                    end
        i.due_date = item[:due_date]
        # i.updated_at = Time.now
        i.save
      end
    end
  end

  def self.del(list_id)
    Item.where(list_id: list_id).delete
    Permission.where(list_id: list_id).delete
    List.where(id: list_id).delete
  end

  def validate
    super
    validates_presence %i{name created_at}
    validates_unique :name
    validates_format /\A[A-Za-z]/, :name, message: 'is not a valid name'
  end
end
