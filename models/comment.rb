class Comment < Sequel::Model
  set_primary_key :id

  many_to_one :user
  many_to_one :list

  

  def del_comment
  end

end