require 'spec_helper'
require 'rspec/its'

module CarrierWave
  module Storage
    module ActiveRecord

      describe StorageProvider do

        # Configure the uploader with our storage provider to ensure methods
        # proxy to us; else, they will proxy to the default storage provider.
        let(:uploader) do
          Class.new(CarrierWave::Uploader::Base) do
            configure do |config|
              storage_provider_class = 'CarrierWave::Storage::ActiveRecord::StorageProvider'
              config.storage_engines[:active_record] = storage_provider_class
            end

            storage :active_record
          end.new
        end

        let(:identifier)      { uploader.identifier }
        let(:storage)         { StorageProvider.new uploader }
        let(:file)            { double 'File to store.', file_properties }
        let(:file_properties) { { original_filename: 'o_sample.png',
                                  content_type:      'image/png',
                                  size:              123,
                                  binary:            'File content.',
                                  read:              'File content.' } }

        let(:mock_rails_url_helpers) do
          article = double 'Article 1'
          allow(article).to receive_message_chain('class.to_s').and_return('Article') # Avoid dynamic creation of a named class.

          url_helpers = double 'Rails URL helpers module'
          expect(url_helpers).to receive(:article_path).with(article).and_return('/articles/1')

          stub_const('::Rails', 'Rails')
          allow(Rails).to receive_message_chain('application.routes.url_helpers').and_return(url_helpers)

          expect(uploader).to receive(:model).and_return(article)
          expect(uploader).to receive(:mounted_as).and_return(:file)
        end

        let(:rails_url)            { '/articles/1/file' }
        let(:storage_provider_url) { [ uploader.download_path_prefix, identifier].join '/' }

        let(:uploader_default_url) { "/url/to/#{identifier}" }

        def add_default_url_to_uploader
          uploader.class.class_eval { def default_url ; "/url/to/#{identifier}" ; end }
        end

        describe '#store!(file)' do

          subject { storage.store! file }

          it        { should be_an_instance_of File }
          its(:url) { should eq storage_provider_url }

          it 'should create a File instance' do
            expect(File).to receive(:create!).with(uploader, file, identifier).and_call_original
            storage.store! file
          end

          it 'should ask the uploader for the filename' do
            expect(uploader).to receive(:filename).with(no_args)
            storage.store!(file)
          end

          context 'with ::Rails' do
            it 'should set the URL property on the returned file' do
              mock_rails_url_helpers
              expect(storage.store!(file).url).to eq rails_url
            end
          end

          context 'with a default_url defined in the uploader' do
            it 'should set the file URL to the default url' do
              add_default_url_to_uploader
              expect(storage.store!(file).url).to eq uploader_default_url
            end
          end

        end

        describe '#retrieve!(identifier)' do

          before(:each) { create_a_file_in_the_database file_properties }

          subject { storage.retrieve! identifier }

          it        { should be_a_kind_of File }
          its(:url) { should eq storage_provider_url }

          it 'should fetch a File instance' do
            expect(File).to receive(:fetch!).with(identifier).and_call_original
            storage.retrieve!(identifier)
          end

          context 'with ::Rails' do
            it 'should set the URL property on the returned file' do
              mock_rails_url_helpers
              expect(storage.retrieve!(identifier).url).to eq rails_url
            end
          end

          context 'with a default_url defined in the uploader' do
            it 'should set the file URL to the default url' do
              add_default_url_to_uploader
              expect(storage.store!(file).url).to eq uploader_default_url
            end
          end
        end

      end # describe StorageProvider do
    end # ActiveRecord
  end # Storage
end # CarrierWave
