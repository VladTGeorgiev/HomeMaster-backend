class Home < ApplicationRecord
    has_many :users
    has_many :bills
    has_many :tasks
    has_many :essentials
    has_many :bill_splits, through: :bills
    default_scope -> { order(id: :asc) }
end
