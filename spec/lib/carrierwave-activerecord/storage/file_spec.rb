require 'spec_helper'
require 'rspec/its'

module CarrierWave
  module Storage
    module ActiveRecord

      describe File do

        it { should respond_to(:url) }                                # Uploader::Base::Url
        it { should respond_to(:blank?, :identifier, :read, :size) }  # Uploader::Base::Proxy
        it { should respond_to(:content_type, :content_type=) }       # Uploader::Base::MimeTypes
        it { should respond_to(:destroy!) }                           # Uploader::Base::RMagick
        it { should respond_to(:original_filename, :size) }           # CarrierWave::SanitizedFile
        it { should respond_to(:filename) }                            # A convenience method.

        let(:uploader) do
          Class.new(CarrierWave::Uploader::Base) do
            configure do |config|
              storage_provider_class = 'CarrierWave::Storage::ActiveRecord::StorageProvider'
              config.storage_engines[:active_record] = storage_provider_class
            end
            storage :active_record
          end.new
        end

        let(:provider_file_class) { ::CarrierWave::Storage::ActiveRecord::File }
        let(:identifier)          { '/uploads/sample.png' }
        let(:active_record_file)  { double 'ActiveRecordFile stored.', file_properties.merge(save!: nil, update: nil) }
        let(:file_to_store)       { double 'File to store.',           file_properties.merge(save!: nil) }
        let(:file_properties)     { { medium_hash:      '/uploads/sample.png',
                                      binary:            'File content.',
                                      read:              'File content.' } }

        before(:each) { CarrierWave::Storage::ActiveRecord::File.delete_all }

        describe '#create!(file)' do

          it 'should create an ActiveRecordFile instance' do
            expect(ActiveRecordFile).to receive(:new).and_return(active_record_file)
            File.create!(uploader, file_to_store, identifier)
          end

          it 'should return a File instance' do
            expect(ActiveRecordFile).to receive(:new).and_return(active_record_file)
            stored_file = File.create!(uploader, file_to_store, identifier)
            expect(stored_file).to be_instance_of File
          end

          it 'should return a File instance with an associated ActiveRecordFile instance' do
            allow(ActiveRecordFile).to receive_message_chain(new: active_record_file)
            stored_file = File.create!(uploader, file_to_store, identifier)
            expect(stored_file.file).to eq active_record_file
          end

          it 'should create a record in the database' do
            expect { File.create!(uploader, file_to_store, identifier) }.to change(ActiveRecordFile, :count).by(1)
          end

          it 'should initialize the file instance' do
            stored_file = File.create!(uploader, file_to_store, identifier)

            file_properties.each do |property, value|
              expect(stored_file.file.send(property)).to eq value
            end
          end

          it 'should set the identifier on the file' do
            stored_file = File.create!(uploader, file_to_store, identifier).file
            expect(stored_file.identifier).to eq identifier
          end
        end


        describe '#fetch!(identifier)' do

          subject { File.fetch! identifier }

          context 'given the file exists in the database' do

            before :each do
              @stored_file = create_a_file_in_the_database file_properties
              expect(ActiveRecordFile.count).to eq(1)
            end

            it                      { should     be_instance_of provider_file_class }
            it                      { should_not be_blank }
            its(:read)              { should eq 'File content.' }
            its(:file)              { should eq @stored_file }
            its(:identifier)        { should eq identifier }
            its(:delete)            { should be_truthy }

            let(:retrieved_file) { File.fetch! identifier }

            it 'deletes the record' do
              expect { retrieved_file.delete }.to change( ActiveRecordFile, :count).by(-1)
            end

          end


          context 'given the file does not exist in the database' do

            let(:identifier) { 'non-existent-identifier' }

            it 'returns nil if file not found' do
              file = File.fetch!(identifier)
              expect(file.file).to eq(nil)
            end
          end
        end

      end # describe File do
    end # ActiveRecord
  end # Storage
end # CarrierWave
