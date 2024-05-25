class Refgo < ApplicationRecord
    validates :api_link, presence: true
    validates :api_login, presence: true
    validates :api_password, presence: true
end
