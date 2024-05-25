class Retail < ApplicationRecord
    validates :api_link, presence: true
    validates :api_key, presence: true


    def self.not_nil? 
        Retail.all.count > 0 ? true : false
    end

end
