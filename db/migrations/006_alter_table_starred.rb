Sequel.migration do
  change do
    alter_table(:items) do
      add_column :stars3, FalseClass, default: false
    end
  end
end
