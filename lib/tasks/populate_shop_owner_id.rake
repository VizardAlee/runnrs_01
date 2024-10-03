
namespace :negotiations do
  desc "Populate shop_owner_id for existing negotiations"
  task populate_shop_owner_id: :environment do
    Negotiation.includes(:store).find_each do |negotiation|
      if negotiation.store.present?
        negotiation.update(shop_owner_id: negotiation.store.user_id)
        puts "Updated shop_owner_id for negotiation ID: #{negotiation.id}"
      else
        puts "No store found for negotiation ID: #{negotiation.id}"
      end
    end
    puts "Completed updating shop_owner_id for all existing negotiations."
  end
end
