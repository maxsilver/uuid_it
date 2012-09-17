require File.join(File.dirname(__FILE__), "uuid_it", "uuid.rb")
require File.join(File.dirname(__FILE__), "ruby-uuid", "uuid.rb")

require 'rubygems'
require 'uuidtools'

module ActiveRecord
  module Acts
    
    module UuidIt
      def uuid_it
        class_eval do
          send :include, InstanceMethods
          has_one :uuid_object, :as => :uuidable, :class_name => "Uuid", :dependent => :destroy
          after_create :assign_uuid
        end
      end
      
      def find_by_uuid uuid
        return Uuid.find_by_uuidable_type_and_uuid(self.name, uuid).try(:uuidable)
      end

      module InstanceMethods
        def uuid
          assign_uuid unless self.uuid_object
          self.uuid_object.uuid
        end

        def uuid=(value)
          if self.uuid_object.present?
            self.uuid_object.update_attributes(:uuid => value)
          else
            self.build_uuid_object(:uuid => value)
          end
        end

        def assign_uuid
          if self.uuid_object.present?
            self.uuid_object.save
          else
            # self.build_uuid_object(:uuid => UUID.create.to_s)
            # Use external library for building UUIDs
            self.build_uuid_object(:uuid => ::UUIDTools::UUID.random_create.to_s)
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
