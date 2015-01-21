# encoding: utf-8
require_relative "test_helper"

describe "Simple" do
  def assert_chardet_spec_detect(file, expected)
    content = File.open("test/simple_assets/#{file}.txt", 'rb'){|io| io.read }
    detected = CharDet.detect(content)
    assert_equal expected, detected
    assert_equal detected['confidence'].class, Float
  end

  def pending
    yield
  rescue StandardError
    skip
  else
    raise "Fixed"
  end

  it "detects EUC_JP" do 
    assert_chardet_spec_detect 'EUC-JP', {
      "encoding" => 'EUC-JP', "confidence" => 0.99
    }
  end

  it "detects Shift_JIS" do
    assert_chardet_spec_detect 'Shift_JIS', {
      "encoding" => 'SHIFT_JIS', "confidence" => (RUBY_VERSION > "1.9.3" ? 0.99 : 1.0) # TODO the 1.9 value might be wrong but I cannot find any bug
    }
  end

  it "detects UTF_8" do
    assert_chardet_spec_detect 'UTF-8' , {
      "encoding" => 'utf-8', "confidence" => 0.99
    }
  end

  it "detects eucJP_ms" do
    assert_chardet_spec_detect 'eucJP-ms' , {
      "encoding" => 'EUC-JP', "confidence" => 0.99
    }
  end
  
  it "detects UTF_16BE" do
    assert_chardet_spec_detect 'UTF-16BE' , {
      "encoding" => 'UTF-16BE', "confidence" => 1.0
    }
  end

  it "detects UTF_16LE" do
    assert_chardet_spec_detect 'UTF-16LE' , {
      "encoding" => 'UTF-16LE', "confidence" => 1.0
    }
  end  

  it "detects ISO_2022_JP" do
    assert_chardet_spec_detect  'ISO-2022-JP'  , {
      "encoding" => 'ISO-2022-JP', "confidence" => 0.99
    }
  end

  it "detects big5" do
    assert_chardet_spec_detect  'big5'  , {
      "encoding" => 'Big5', "confidence" => 0.99
    }
  end

  it "detects windows-1252" do
    assert_chardet_spec_detect  'windows-1252'  , {
      # not perfect, but better than detecting nil
      "encoding" => 'windows-1252', "confidence" => 0.36875
    }
  end

  it "detects russian" do
    # this failed when using $KCODE='u' on 1.8 ... just making sure it stays put
    CharDet.detect("Toto je zpr\xE1va ve form\xE1tu MIME s n\xECkolika \xE8\xE1stmi.\n")["encoding"].must_equal "windows-1251"
  end

  it "does not blow up on invalid encoding" do
    bad = "bad encoding: \xc3\x28"
    CharDet.detect(bad)["encoding"].must_equal "ISO-8859-2"
    bad.encoding.must_equal Encoding::UTF_8
  end

  it "does not blow up on multibyte UTF-8 chars" do
    accented = "Juan Pérez"
    CharDet.detect(accented)["encoding"].must_equal "ISO-8859-2"
    accented.encoding.must_equal Encoding::UTF_8
  end
end
