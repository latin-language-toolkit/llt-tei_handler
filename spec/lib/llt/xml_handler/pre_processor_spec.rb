require 'spec_helper'

describe LLT::XmlHandler::PreProcessor do
  let(:pre_processor) { LLT::XmlHandler::PreProcessor }

  def load_fixture(filename)
    File.read(File.expand_path("../../../fixtures/#{filename}", __FILE__))
  end

  let(:embedded_tei_doc) do
    <<-EOF
      <?xml version="1.0" encoding="utf-8"?>
      <reply>
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
          <teiHeader>
            <xxx/>
          </teiHeader>
          <body>
            <head>TITLE</head>
            <p>Text <ref type='note'>Note</ref> resumed</p>
          </body>
        </TEI>
      </reply
    EOF
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

  describe "#new" do
    it "takes a xml document on initialization" do
      doc = <<-EOF
        <?xml version="1.0" encoding="utf-8"?>
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
        </TEI>
      EOF
      expect { pre_processor.new(doc) }.not_to raise_error
    end

    it "tries to find a root element, given as optional keyword param" do
      doc = <<-EOF
        <?xml version="1.0" encoding="utf-8"?>
        <reply>
          <custom_root>
            <teiHeader></teiHeader>
          </custom_root>
        </reply>
      EOF
      doc = pre_processor.new(doc, root: 'custom_root')
      doc.document.root.name.should == 'custom_root'
    end

    it "root element can have a namespace, given as optional keyword param" do

    end
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
