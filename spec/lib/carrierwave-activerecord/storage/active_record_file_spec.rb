require 'spec_helper'

module CarrierWave
  module Storage
    module ActiveRecord

      describe 'ActiveRecordFile' do

        after :each, database: true do
          CarrierWave::Uploader::Base.reset_config

          active_record = Object.const_get(:CarrierWave).const_get(:Storage).const_get(:ActiveRecord)
          active_record.send(:remove_const, :ActiveRecordFile)
          load 'carrierwave-activerecord/storage/active_record_file.rb'

          expect(ActiveRecordFile.table_name).to eq 'carrier_wave_files'
        end

        it 'should use a custom table name', database: true do
          CarrierWave::Uploader::Base.active_record_tablename = 'custom_table_name'
          expect(ActiveRecordFile.table_name).to eq 'custom_table_name'
        end

        it 'should respond to the methods expected by CarrierWave' do
          required_attributes = [ :identifier,
                                  :original_filename,
                                  :content_type,
                                  :size,
                                  :binary,
                                  :delete,
                                  :read ]
          expect(ActiveRecordFile.new).to respond_to *required_attributes
        end
      end # ActiveRecordFile

    end # ActiveRecord
  end # Storage
end # CarrierWave
