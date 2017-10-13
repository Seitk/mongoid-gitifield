require 'mongoid/gitifield/version'
require 'mongoid/gitifield/commander'
require 'mongoid/gitifield/bundle'
require 'mongoid/gitifield/workspace'

module Mongoid
  module Gitifield
    extend ActiveSupport::Concern

    GITIFIELD_DATA_KEY = '%s_gitifield_data'.freeze
    GITIFIELD_WORKSPACE_KEY = '%s_gitifield'.freeze
    GITIFIELD_WORKSPACE_CACHE_KEY = '@_%s_gitifield'.freeze
    GITIFIELD_TRACKING_FLAT = 'gitifield_%s_tracking_enabled'.freeze

    module ClassMethods
      name.constantize.class_variable_set(:@@_gitifields, [])
      name.constantize.class_variable_set(:@@_state, {})

      def gitifields_on(fields = [])
        name.constantize.class_variable_set(:@@_gitifields, fields || [])
        name.constantize.class_variable_set(:@@_state, {})
        name.constantize.store[gitifield_tracking_key] = true

        include InstanceMethods

        fields.each do |field|
          define_method(GITIFIELD_WORKSPACE_KEY % [field]) do
            variable_name = (GITIFIELD_WORKSPACE_CACHE_KEY % [field]).to_sym
            workspace = instance_variable_get(variable_name)
            if workspace.nil?
              workspace = Workspace.new(data: self[(GITIFIELD_DATA_KEY % [field]).to_sym])
              instance_variable_set(variable_name, workspace)
            end
            workspace
          end
        end

        define_method('reload_gitifields!') do
          fields.each do |field|
            instance_variable_set((GITIFIELD_WORKSPACE_CACHE_KEY % [field]).to_sym, nil)
          end
          true
        end

        before_update :create_gitifield_commit
        before_create :create_gitifield_commit
      end

      def gitifields
        name.constantize.try(:class_variable_get,:@@_gitifields)
      end

      def store
        name.constantize.class_variable_get(:@@_state)
      end

      def store=(value)
        name.constantize.class_variable_set(:@@_state, value)
      end

      def suspend_tracking(&_block)
        store[gitifield_tracking_key] = false
        yield
      ensure
        store[gitifield_tracking_key] = true
      end

      def gitifield_tracking_key
        (GITIFIELD_TRACKING_FLAT % [name.underscore]).to_sym
      end

      def tracking_enabled?
        store[gitifield_tracking_key] == false
      end
    end

    module InstanceMethods
      def create_gitifield_commit
        return unless self.class.tracking_enabled?

        (self.class.gitifields || []).each do |field|
          workspace = self.send((GITIFIELD_WORKSPACE_KEY % [field]).to_sym)
          workspace.update(self[field.to_sym])
          write_attribute((GITIFIELD_DATA_KEY % [field]).to_sym, workspace.to_s)
        end
        reload_gitifields!
      end
    end
  end
end