require "shrine"
require "down"
require "uri"

class Shrine
  module Storage
    class Fog
      attr_reader :connection, :directory, :prefix

      def initialize(directory:, prefix: nil, public: true, expires: 3600, connection: nil, **options)
        @connection = connection || ::Fog::Storage.new(options)
        @directory = @connection.directories.get(directory)
        @prefix = prefix
        @public = public
        @expires = expires
      end

      def upload(io, id, **upload_options)
        if copyable?(io)
          copy(io, id, **upload_options)
        else
          put(io, id, **upload_options)
        end
      end

      def download(id)
        Down.download(url(id))
      end

      def open(id)
        Down.open(url(id))
      end

      def read(id)
        get(id).body
      end

      def exists?(id)
        !!head(id)
      end

      def delete(id)
        file(id).destroy
      end

      def url(id, **options)
        signed_url = file(id).url(Time.now + @expires, **options)
        if @public
          uri = URI(signed_url)
          uri.query = nil
          uri.to_s
        else
          signed_url
        end
      end

      def clear!
        list.each(&:destroy)
      end

      def method_missing(name, *args)
        if name == :stream
          warn "Shrine::Storage::Fog#stream is deprecated, you should use Fog#open with #each_chunk instead."
          get(*args) do |chunk, _, content_length|
            yield chunk, content_length
          end
        end
      end

      protected

      def file(id)
        directory.files.new(key: path(id))
      end

      def get(id, &block)
        directory.files.get(path(id), &block)
      end

      def head(id)
        directory.files.head(path(id))
      end

      def provider
        connection.class
      end

      private

      def list
        directory.files.select { |file| file.key.start_with?(prefix.to_s) }
      end

      def path(id)
        [*prefix, id].join("/")
      end

      def put(io, id, shrine_metadata: {}, **upload_options)
        options = {key: path(id), body: io, public: @public}
        options[:content_type] = shrine_metadata["mime_type"]
        options.update(upload_options)

        directory.files.create(options)
      end

      def copy(io, id, **upload_options)
        io.storage.head(io.id).copy(directory.key, path(id))
      end

      def copyable?(io)
        io.respond_to?(:storage) &&
        io.storage.is_a?(Storage::Fog) &&
        io.storage.provider == provider
      end
    end
  end
end
