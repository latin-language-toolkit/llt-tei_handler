module LLT
  module TeiHandler
    class PreProcessor
      require 'nokogiri'

      def initialize(document)
        @document = Nokogiri::XML(document)
        raise ArgumentError.new('Document is no TEI XML') unless is_tei?
      end

      def to_xml
        without_duplicate_declaration(@document.to_xml).strip
      end

      def is_tei?
        @document.root.name == 'TEI'
      end

      def ignore_nodes(*nodes)
        @document.search(*nodes).each(&:remove)
        @document
      end

      alias_method :remove_nodes, :ignore_nodes

      private

      DUPLICATE_XML_VERSION = /<\?xml version=.*\?>\s*{2}/m
      def without_duplicate_declaration(doc)
        if doc.match(DUPLICATE_XML_VERSION)
          doc.sub(/^<\?xml version=.*\?>/, '')
        else
          doc
        end
      end
    end
  end
end
