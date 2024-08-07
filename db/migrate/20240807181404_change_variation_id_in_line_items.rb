class ChangeVariationIdInLineItems < ActiveRecord::Migration[7.1]
  def change
    change_column_null :line_items, :variation_id, true
  end
end
