class CreateBbsThreads < ActiveRecord::Migration
  def change
    create_table :bbs_threads do |t|
      t.string :title
      t.string :name
      t.text :email
      t.text :comment
      t.binary :image
      t.string :content_type
      t.binary :thumbnail
      t.string :delkey
      t.boolean :delflag
      t.boolean :imgdelflag

      t.timestamps
    end
  end
end
