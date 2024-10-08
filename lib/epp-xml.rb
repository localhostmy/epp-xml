require 'active_support'
require 'builder'
require 'epp-xml/session'
require 'epp-xml/domain'
require 'epp-xml/host'
require 'epp-xml/contact'
require 'epp-xml/keyrelay'
require 'client_transaction_id'

class EppXml
  include ClientTransactionId

  def domain
    @cached_domain ||= EppXml::Domain.new(cl_trid: cl_trid,
                                          cl_trid_prefix: cl_trid_prefix,
                                          schema_version: schema_version,
                                          schema_prefix: schema_prefix)
  end

  def contact
    @cached_contact ||= EppXml::Contact.new(cl_trid: cl_trid,
                                            cl_trid_prefix: cl_trid_prefix,
                                            schema_version: schema_version,
                                            schema_prefix: schema_prefix)
  end

  def session
    @cached_session ||= EppXml::Session.new(cl_trid: cl_trid, cl_trid_prefix: cl_trid_prefix)
  end

  def keyrelay
    @cached_keyrelay ||= EppXml::Keyrelay.new(cl_trid: cl_trid, cl_trid_prefix: cl_trid_prefix)
  end

  class << self
    def generate_xml_from_hash(xml_params, xml, ns = '')
      xml_params.each do |k, v|
        # Value is a hash which has string type value
        if v.is_a?(Hash) && v[:value].is_a?(String)
          xml.tag!("#{ns}#{k}", v[:value], v[:attrs])
        # Value is a hash which is nested
        elsif v.is_a?(Hash)
          attrs = v.delete(:attrs)
          value = v.delete(:value) || v
          xml.tag!("#{ns}#{k}", attrs) do
            generate_xml_from_hash(value, xml, ns)
          end
        # Value is an array
        elsif v.is_a?(Array)
          if k.to_s.start_with?('_')
            v.each do |x|
              generate_xml_from_hash(x, xml, ns)
            end
          else
            xml.tag!("#{ns}#{k}") do
              v.each do |x|
                generate_xml_from_hash(x, xml, ns)
              end
            end
          end
        end
      end
    end

    def custom_ext(xml, custom_params)
      if custom_params.any?
        if custom_params.keys.include?(:manual)
          head = custom_params.dig(:manual, :head)
          body = custom_params.dig(:manual, :body)

          xml.tag!("#{head[:type]}:#{head[:op]}",
            "xmlns:#{head[:type]}" => head[:xmlns]) do
            EppXml.generate_xml_from_hash(body, xml, "#{head[:type]}:")
          end
        else
          xml.extension do
            if custom_params.any?
              xml.tag!('eis:extdata',
                      'xmlns:eis' => 'https://epp.tld.ee/schema/eis-1.0.xsd') do
                EppXml.generate_xml_from_hash(custom_params, xml, 'eis:')
              end
            end
          end
        end
      end
    end

    def check_fee_ext(xml, xml_params, extra_params)
      domain_name = xml_params.values.flatten
      command = extra_params.dig(:command, :value)
      xml.tag!('fee:check', 'xmlns:fee' => 'urn:ietf:params:xml:ns:fee-0.7') do
        if domain_name.is_a?(Array)
          domain_name.each do |domain|
            if command == "all"
              %w[create renew transfer restore].each do |action|
                custom_params = generate_fee_ext(domain, action)
                EppXml.generate_xml_from_hash(custom_params, xml, 'fee:')
              end
            else
              custom_params = generate_fee_ext(domain, command)
              EppXml.generate_xml_from_hash(custom_params, xml, 'fee:')
            end
          end
        end
      end
    end

    def generate_fee_ext(domain, command)
      {
        domain: {
          name: { value: domain[:name][:value] },
          currency: { value: domain[:currency] || "USD" },
          command: { value: command },
          period: {
            attrs: { unit: "y" },
            value: domain[:year]
          }
        }
      }
    end
  end
end
