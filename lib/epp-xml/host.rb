require 'client_transaction_id'

class EppXml
  class Host
    include ClientTransactionId

    XMLNS = 'urn:ietf:params:xml:ns:epp-1.0'.freeze

    def info(xml_params = {})
      build('info', xml_params)
    end

    def check(xml_params = {})
      build('check', xml_params)
    end

    def create(xml_params = {})
			build('create', xml_params)
    end

    def update(xml_params = {})
      xml = Builder::XmlMarkup.new

      xml.instruct!(:xml, standalone: 'no')
      xml.epp('xmlns' => XMLNS) do
        xml.command do
          xml.update do
            xml.tag!('host:update', 'xmlns:host' => generate_path) do
              EppXml.generate_xml_from_hash(xml_params, xml, 'host:')
            end
          end

          xml.clTRID(clTRID) if clTRID
        end
      end
    end

    def delete(xml_params = {}, verified = false)
			build('delete', xml_params)
    end

    private

    def generate_path
      "urn:ietf:params:xml:ns:host-1.0"
    end

    def build(command, xml_params)
      xml = Builder::XmlMarkup.new

      xml.instruct!(:xml, standalone: 'no')
      xml.epp('xmlns' => XMLNS) do
        xml.command do
          xml.tag!(command) do
            xml.tag!("host:#{command}", 'xmlns:host' => generate_path) do
              EppXml.generate_xml_from_hash(xml_params, xml, 'host:')
            end
          end

          xml.clTRID(clTRID) if clTRID
        end
      end
    end
  end
end
