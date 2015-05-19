DB_SCHEMA = lambda do |_|
  enable_extension :hstore

  drop_table :posts if connection.table_exists?(:posts)

  create_table :posts, force: true do |t|
    t.hstore :names
    t.hstore :addresses
    t.hstore :author
    t.string :brokens
  end
end
