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
end
