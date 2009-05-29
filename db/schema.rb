ActiveRecord::Schema.define(:version => 1) do
  
  create_table "mappables", :force => true do |t|
    t.float   "lat"
    t.float   "lng"
    t.integer "attachable_id"
    t.string  "attachable_type"
    t.timestamps
  end
  
end