class Refgo < ApplicationRecord
    validates :api_link, presence: true
    validates :api_login, presence: true
    validates :api_password, presence: true

    def self.not_nil? 
        Refgo.all.count > 0 ? true : false
    end

end
