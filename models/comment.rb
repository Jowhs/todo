class Comment < Sequel::Model
  set_primary_key :id

  many_to_one :user
  many_to_one :list

  def self.new_comment(list_id, user_id, comment)
    comment = Comment.create(list_id: list_id, user_id: user_id, comment: comment, created_at: Time.now)
    comment
  end

  def self.del_comment(comment_id)
    Comment.where(id: comment_id).delete
  end
end
