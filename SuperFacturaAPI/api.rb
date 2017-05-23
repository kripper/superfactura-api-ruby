# encoding: ISO-8859-1

require 'net/http'
require 'uri'
require 'zlib'
require 'stringio'
require 'base64'
require 'json'

class SuperFacturaAPI
	@version = '1.4-ruby'
	@user
	@password

	def initialize(user, password)
		@user = user
		@password = password
	end

	public
		def SendDTE(data, ambiente, options)
			options['ambiente'] = ambiente
			options['encoding'] = 'UTF-8'
			options['version'] = @version

			if options['savePDF']
				options['getPDF'] = 1
			end

			if options['saveXML']
				options['getXML'] = 1
			end

			# APIResult apiResult = new APIResult()

			output = ''
			obj = nil

			begin
				output = SendRequest(data, options)
				obj = JSON.parse(output)
				if obj['ack'] != 'ok'
					text = obj['response']['title'] != "" ? obj['response']['title'] + " - " : "" + obj['response']['message']
					raise "ERROR: " + text
				end
			#rescue Exception => e
			#	raise "API Error: " + e.message
			end

			appRes = obj['response']

			folio = appRes['folio']
			if appRes['ok'] == "1"
				savePDF = options['savePDF']
				if savePDF
					WriteFile(savePDF + ".pdf", DecodeBase64(appRes['pdf']));

					if appRes['pdfCedible']
						WriteFile(savePDF + "-cedible.pdf", DecodeBase64(appRes['pdfCedible']));
					end
				end

				saveXML = options['saveXML']
				if saveXML
					WriteFile(saveXML + ".xml", appRes['xml']);
				end
			else
				raise output
			end
			return appRes
		end

	private
		def SendRequest(data, options)
			response = Net::HTTP.post_form(URI.parse('https://superfactura.cl?a=json'),
			{
				'user' => @user,
				'pass' => @password,
				'content' => JSON.generate(data),
				'options' => JSON.generate(options)
			})
			return Decompress(response.body)
		end

		def Decompress(gzip)
			gz = Zlib::GzipReader.new(StringIO.new(gzip))
			return gz.read
		end

		def DecodeBase64(base64)
			return Base64.decode64(base64)
		end

		def WriteFile(filename, content)
			File.open(filename, 'wb') { |file| file.write(content) }
		end
end
