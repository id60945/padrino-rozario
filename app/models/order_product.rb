# encoding: utf-8
class Order_product < ActiveRecord::Base
	#belongs_to :id, class_name: 'Order'
	attr_accessible :id, :product_id, :title, :tel, :price, :quantity, :typing, :date_from, :date_to, :surprise
	#scope :get_product_orders, -> { joins(:Order).joins('LEFT OUTER JOIN orders ON orders.id = order_products.order_id').where('orders.id = order_products.order_id')}
end
