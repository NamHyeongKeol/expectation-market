class Order < ActiveRecord::Base
  belongs_to :seller, class_name: :User#, foreign_key: :sell_order
  belongs_to :buyer, class_name: :User#, foreign_key: :buy_order
  belongs_to :card
  belongs_to :buy_team, class_name: :Team
end
