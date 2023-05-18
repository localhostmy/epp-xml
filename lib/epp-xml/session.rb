require 'client_transaction_id'

class EppXml
  class Session
    include ClientTransactionId

    def login(xml_params = {})
      defaults = {
        clID: { value: 'user' },
        pw: { value: 'pw' },
        newPW: nil,
        options: {
          version: { value: '1.0' },
          lang: { value: 'en' }
        },
        svcs: {
          _objURIs: [
            { objURI: { value: 'urn:ietf:params:xml:ns:contact-1.0' } },
            { objURI: { value: 'urn:ietf:params:xml:ns:domain-1.0' } },
            { objURI: { value: 'urn:ietf:params:xml:ns:host-1.0' } }

          ],
          svcExtension: [
            { extURI: { value: 'urn:ietf:params:xml:ns:secDNS-1.1' } },
            { extURI: { value: 'urn:ietf:params:xml:ns:rgp-1.0' } },
            { extURI: { value: 'urn:ietf:params:xml:ns:idn-1.0' } },
            { extURI: { value: 'urn:ietf:params:xml:ns:launch-1.0' } },
            { extURI: { value: 'urn:ietf:params:xml:ns:fee-0.7' } }
          ]
        }
      }

      xml_params = defaults.deep_merge(xml_params)

      xml = Builder::XmlMarkup.new

      xml.instruct!(:xml, standalone: 'no')
      xml.epp(
        'xmlns' => 'urn:ietf:params:xml:ns:epp-1.0'
      ) do
        xml.command do
          xml.login do
            EppXml.generate_xml_from_hash(xml_params, xml)
          end
          xml.clTRID(clTRID) if clTRID
        end
      end
    end

    def logout
      xml = Builder::XmlMarkup.new
      xml.instruct!(:xml, standalone: 'no')
      xml.epp(
        'xmlns' => 'urn:ietf:params:xml:ns:epp-1.0'
      ) do
        xml.command do
          xml.logout
          xml.clTRID(clTRID) if clTRID
        end
      end
    end

    def poll(xml_params = {}, custom_params = {})
      defaults = {
        poll: { value: '', attrs: { op: 'req' } }
      }

      xml_params = defaults.deep_merge(xml_params)

      xml = Builder::XmlMarkup.new

      xml.instruct!(:xml, standalone: 'no')
      xml.epp('xmlns' => 'urn:ietf:params:xml:ns:epp-1.0') do
        xml.command do
          EppXml.generate_xml_from_hash(xml_params, xml)

          # EppXml.custom_ext(xml, custom_params)
          xml.clTRID(clTRID) if clTRID
        end
      end
    end
  end
end
