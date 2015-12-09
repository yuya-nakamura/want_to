class CreateCaFlvInfos < ActiveRecord::Migration
  def change
    create_table :ca_flv_infos do |t|
      t.string :smid, null: false
      t.string :ms, null: false
      t.string :thread_id, null: false
      t.integer :deleted
      t.boolean :error

      t.timestamps null: false
    end
  end
end
