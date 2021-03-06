# frozen_string_literal: true

class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :title
      t.string :lead
      t.string :text

      t.timestamps
    end
  end
end
