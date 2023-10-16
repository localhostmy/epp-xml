require 'client_transaction_id'

class EppXml
  class Domain
    include ClientTransactionId

		DEFAULT_SCHEMA_PREFIX = 'domain-eis'.freeze
		DEFAULT_SCHEMA_VERSION = '1.0'.freeze

    XMLNS         = 'urn:ietf:params:xml:ns:epp-1.0'.freeze

    XMLNS_SECDNS  = 'urn:ietf:params:xml:ns:secDNS-1.1'.freeze

    XMLNS_EIS     = 'https://epp.tld.ee/schema/eis-1.0.xsd'.freeze

    def info(xml_params = {}, custom_params = {})
      build('info', xml_params, custom_params)
    end

    def check(xml_params = {}, custom_params = {})
      build('check', xml_params, custom_params)
    end

    def renew(xml_params = {}, custom_params = {})
      build('renew', xml_params, custom_params)
    end

    def create(xml_params = {}, dnssec_params = {}, custom_params = {})
      xml = Builder::XmlMarkup.new

      xml.instruct!(:xml, standalone: 'no')
      xml.epp('xmlns' => XMLNS) do
        xml.command do
          xml.create do
            xml.tag!('domain:create', 'xmlns:domain' => generate_path) do
              EppXml.generate_xml_from_hash(xml_params, xml, 'domain:')
            end
          end

          xml.extension do
            xml.tag!('secDNS:create', 'xmlns:secDNS' => XMLNS_SECDNS) do
              EppXml.generate_xml_from_hash(dnssec_params, xml, 'secDNS:')
            end if dnssec_params.any?

            build_custom_ext(xml, custom_params) if custom_params.any?
          end if dnssec_params.any? || custom_params.any?

          xml.clTRID(clTRID) if clTRID
        end
      end
    end

    def update(xml_params = {}, dnssec_params = {}, custom_params = {})
      xml = Builder::XmlMarkup.new

      xml.instruct!(:xml, standalone: 'no')
      xml.epp('xmlns' => XMLNS) do
        xml.command do
          xml.update do
            xml.tag!('domain:update', 'xmlns:domain' => generate_path) do
              EppXml.generate_xml_from_hash(xml_params, xml, 'domain:')
            end
          end

          xml.extension do
            xml.tag!('secDNS:update', 'xmlns:secDNS' => XMLNS_SECDNS) do
              EppXml.generate_xml_from_hash(dnssec_params, xml, 'secDNS:')
            end

            build_custom_ext(xml, custom_params) if custom_params.any?
          end if dnssec_params.any? || custom_params.any?

          xml.clTRID(clTRID) if clTRID
        end
      end
    end

    def transfer(xml_params = {}, op = 'query', custom_params = {})
      xml = Builder::XmlMarkup.new

      xml.instruct!(:xml, standalone: 'no')
      xml.epp('xmlns' => XMLNS) do
        xml.command do
          xml.transfer('op' => op) do
            xml.tag!('domain:transfer', 'xmlns:domain' => generate_path) do
              EppXml.generate_xml_from_hash(xml_params, xml, 'domain:')
            end
          end

          build_custom_ext(xml, custom_params) if custom_params.any?
          xml.clTRID(clTRID) if clTRID
        end
      end
    end

    def delete(xml_params = {}, custom_params = {})
      xml = Builder::XmlMarkup.new

      xml.instruct!(:xml, standalone: 'no')
      xml.epp('xmlns' => XMLNS) do
        xml.command do
          xml.delete do
            xml.tag!("domain:delete", 'xmlns:domain' => generate_path) do
              EppXml.generate_xml_from_hash(xml_params, xml, 'domain:')
            end
          end

          build_custom_ext(xml, custom_params) if custom_params.any?
          xml.clTRID(clTRID) if clTRID
        end
      end
    end

    private

    def generate_path
      prefix = schema_prefix || DEFAULT_SCHEMA_PREFIX
      version = schema_version || DEFAULT_SCHEMA_VERSION

      # "https://epp.tld.ee/schema/#{prefix}-#{version}.xsd"
      "urn:ietf:params:xml:ns:domain-1.0"
    end

    def build_custom_ext(xml, custom_params)
      custom_params.values.flatten!.each do |custom|
        if custom.keys.include?(:fee)
          custom[:fee].each do |k, v|
            xml.tag!("fee:#{k}",
            "xmlns:fee" => "urn:ietf:params:xml:ns:fee-0.7") do
              EppXml.generate_xml_from_hash(v, xml, "fee:")
            end
          end
        else
          xml.tag!("eis:extdata",
            "xmlns:eis" => XMLNS_EIS) do
            EppXml.generate_xml_from_hash(custom, xml, "eis:")
          end
        end
      end
    end

    def build(command, xml_params, custom_params)
      xml = Builder::XmlMarkup.new

      xml.instruct!(:xml, standalone: 'no')
      xml.epp('xmlns' => XMLNS) do
        xml.command do
          xml.tag!(command) do
            xml.tag!("domain:#{command}", 'xmlns:domain' => generate_path) do
              EppXml.generate_xml_from_hash(xml_params, xml, 'domain:')
            end
          end

          EppXml.check_fee_ext(xml, xml_params) if command == "check"
          EppXml.custom_ext(xml, custom_params)
          xml.clTRID(clTRID) if clTRID
        end
      end
    end
  end
end
