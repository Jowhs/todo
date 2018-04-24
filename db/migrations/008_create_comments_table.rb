Sequel.migration do
  change do
    create_table :comments do
      primary_key :id
      foreign_key :user_id, :users, null: false
      foreign_key :list_id, :lists, null: false
      String :comment, length: 128, null: false
      DateTime :created_at
    end
  end
end
