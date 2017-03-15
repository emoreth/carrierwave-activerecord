module CarrierWave
  module Storage
    module ActiveRecord

      class File

        def self.create!(uploader, new_file, identifier)
          attributes = {
            :medium_hash       => identifier,
            :original_filename => new_file.original_filename,
            :content_type      => new_file.content_type,
            :size              => new_file.size,
            :binary            => new_file.read
          }

          if uploader.model
            attributes.merge!({
              foreign_id:    uploader.model.id,
              foreign_class_name: uploader.model.class.to_s
            })
          end

          record = ActiveRecordFile.where(medium_hash: identifier).first
          record = ActiveRecordFile.new if record.blank?
          record.update_attributes(attributes)

          self.new record
        end

        def self.fetch! identifier
          self.new ActiveRecordFile.where(medium_hash: identifier).first
        end

        def self.delete_all
          ActiveRecordFile.delete_all
        end


        attr_reader   :file
        attr_accessor :url

        def initialize(file = nil)
          @file = file
        end

        def blank?
          file.nil?
        end

        def read
          file.binary if file
        end

        def size
          file.size if file
        end

        def extension
          file.identifier.split('.').last if file
        end

        def content_type
          file.content_type if file
        end

        def content_type= content_type
          if file
            file.content_type =  content_type
            file.save
          end
        end

        def identifier
          file.identifier if file
        end

        def original_filename
          file.original_filename if file
        end
        alias_method :filename, :original_filename

        def delete
          if file
            file.destroy
          else
            false
          end
        end
        alias_method :destroy!, :delete

        def foreign_id
          @file.foreign_id
        end

        def foreign_class_name
          @file.foreign_class_name
        end

      end # File

    end # ActiveRecord
  end # Storage
end # CarrierWave
