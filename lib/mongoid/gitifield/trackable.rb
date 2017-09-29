module Mongoid
  module Gitifield
    module Trackable
      extend ActiveSupport::Concern

      module ClassMethods
        def gitifields_on(fields = [])
          options = {
            on: fields
          }

          include MyInstanceMethods

          before_update :create_gitifield_commit
          before_create :create_gitifield_commit
        end
      end

      module MyInstanceMethods
        def create_gitifield_commit
          Rails.logger.debug "===== create_gitifield_commit"
        end
      end
    end
  end
end