require File.join(File.dirname(__FILE__), "uuid_it", "uuid.rb")
require File.join(File.dirname(__FILE__), "ruby-uuid", "uuid.rb")

require 'rubygems'
require 'uuidtools'

module ActiveRecord
  module Acts

    module UuidIt
      # def self.included(base)
      #   @@classes ||= []
      #   binding.pry
      #   @@classes << self
      # end

      def uuid_it
        class_eval do
          attr_accessible :uuid
          send :include, InstanceMethods
          # has_one :uuid_object, :as => :uuidable, :class_name => "Uuid", :dependent => :destroy
          after_create :assign_uuid
        end
        # self.included(self)
      end

      # def uuid_classes
      #   @@classes.uniq
      # end

      # def find_by_uuid uuid
        # return Uuid.find_by_uuidable_type_and_uuid(self.name, uuid).try(:uuidable)
      # end

      module InstanceMethods
        def uuid
          assign_uuid unless self.read_attribute(:uuid).present?
          self.read_attribute(:uuid)
        end

        def uuid=(value)
          self[:uuid] = value
        end

        def assign_uuid
          if self.read_attribute(:uuid).present?
            self.save
          else
            # Use external library for building UUIDs
            self.uuid = ::UUIDTools::UUID.random_create.to_s
            self.save unless self.new_record?
          end
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  extend ActiveRecord::Acts::UuidIt
end
