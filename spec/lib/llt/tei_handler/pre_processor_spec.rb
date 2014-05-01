require 'spec_helper'

describe LLT::TeiHandler::PreProcessor do
  let(:pre_processor) { LLT::TeiHandler::PreProcessor }

  def load_fixture(filename)
    File.read(File.expand_path("../../../fixtures/#{filename}", __FILE__))
  end

  describe "#new" do
    it "takes a TEI xml document on initialization" do
      doc = <<-EOF
        <?xml version="1.0" encoding="utf-8"?>
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
        </TEI>
      EOF
      expect { pre_processor.new(doc) }.not_to raise_error
    end

    it "throws an error when the document is NOT TEI" do
      doc = <<-EOF
        <?xml version="1.0" encoding="utf-8"?>
        <doc>
        </doc>
      EOF

      expect { pre_processor.new(doc) }.to raise_error ArgumentError
    end
  end

  let(:tei_doc) do
    <<-EOF
      <?xml version="1.0" encoding="utf-8"?>
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <teiHeader>
          <xxx/>
        </teiHeader>
        <body>
          <head>TITLE</head>
          <p>Text <ref type='note'>Note</ref> resumed</p>
        </body>
      </TEI>
    EOF
  end

  describe "#ignore_nodes" do
    it "has the alias remove_nodes" do
      doc1 = pre_processor.new(tei_doc)
      doc2 = pre_processor.new(tei_doc)

      removed = doc1.remove_nodes('body').to_xml
      ignored = doc2.ignore_nodes('body').to_xml

      removed.should == ignored
    end

    def with_stripped_lines(string)
      string.lines.map(&:strip).join
    end

    it "takes out given nodes including all of their content" do
      doc = pre_processor.new(tei_doc)
      doc.ignore_nodes('teiHeader', 'head')
      result = with_stripped_lines(<<-EOF)
        <?xml version="1.0" encoding="utf-8"?>
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
          <body>
            <p>Text <ref type="note">Note</ref> resumed</p>
          </body>
        </TEI>
      EOF

      with_stripped_lines(doc.to_xml).should == result
    end
  end
end
