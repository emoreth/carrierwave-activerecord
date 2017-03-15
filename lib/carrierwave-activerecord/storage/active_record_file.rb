module CarrierWave
  module Storage
    module ActiveRecord

      class ActiveRecordFile < ::ActiveRecord::Base
        # This need to be the same table , Maybe migration required ??
        self.table_name = CarrierWave::Uploader::Base.active_record_tablename

        alias_method    :delete, :destroy
        alias_attribute :read, :binary
        alias_attribute :identifier, :medium_hash

        def extension
          self.medium_hash.split('.').last if self.medium_hash
        end

      end # ActiveRecordFile

    end # ActiveRecord
  end # Storage
end # CarrierWave
